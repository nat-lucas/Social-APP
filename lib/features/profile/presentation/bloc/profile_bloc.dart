import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/post_model.dart';
import '../../../../core/constants/app_constants.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileBloc({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoaded);
    on<ProfileFollowToggled>(_onFollowToggled);
    on<ProfileUpdated>(_onProfileUpdated);
  }

  Future<void> _onProfileLoaded(
      ProfileLoadRequested event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      final currentUid = _auth.currentUser?.uid;
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(event.userId)
          .get();

      if (!userDoc.exists) {
        emit(const ProfileError('User not found'));
        return;
      }

      final user = UserModel.fromFirestore(userDoc);

      final postsSnapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .where('userId', isEqualTo: event.userId)
          .orderBy('createdAt', descending: true)
          .get();

      final posts = postsSnapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();

      bool isFollowing = false;
      if (currentUid != null && currentUid != event.userId) {
        final followDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(event.userId)
            .collection('followers')
            .doc(currentUid)
            .get();
        isFollowing = followDoc.exists;
      }

      emit(ProfileLoaded(
        user: user,
        posts: posts,
        isFollowing: isFollowing,
        isCurrentUser: currentUid == event.userId,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onFollowToggled(
      ProfileFollowToggled event, Emitter<ProfileState> emit) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileLoaded(
      user: currentState.user,
      posts: currentState.posts,
      isFollowing: !event.isFollowing,
      isCurrentUser: currentState.isCurrentUser,
    ));

    try {
      final targetRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(event.targetUserId);
      final currentRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUid);

      if (event.isFollowing) {
        await targetRef.collection('followers').doc(currentUid).delete();
        await currentRef.collection('following').doc(event.targetUserId).delete();
        await targetRef.update({'followersCount': FieldValue.increment(-1)});
        await currentRef.update({'followingCount': FieldValue.increment(-1)});
      } else {
        await targetRef
            .collection('followers')
            .doc(currentUid)
            .set({'userId': currentUid, 'createdAt': FieldValue.serverTimestamp()});
        await currentRef
            .collection('following')
            .doc(event.targetUserId)
            .set({'userId': event.targetUserId, 'createdAt': FieldValue.serverTimestamp()});
        await targetRef.update({'followersCount': FieldValue.increment(1)});
        await currentRef.update({'followingCount': FieldValue.increment(1)});
      }
    } catch (_) {
      emit(currentState);
    }
  }

  Future<void> _onProfileUpdated(
      ProfileUpdated event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'displayName': event.displayName, 'bio': event.bio});
      emit(ProfileLoaded(
        user: currentState.user
            .copyWith(displayName: event.displayName, bio: event.bio),
        posts: currentState.posts,
        isFollowing: currentState.isFollowing,
        isCurrentUser: currentState.isCurrentUser,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
