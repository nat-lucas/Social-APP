import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/models/post_model.dart';
import '../../../../core/constants/app_constants.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HomeBloc({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const HomeInitial()) {
    on<HomeFeedLoaded>(_onFeedLoaded);
    on<HomePostLiked>(_onPostLiked);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onFeedLoaded(HomeFeedLoaded event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _loadFeed(emit);
  }

  Future<void> _onRefreshRequested(
      HomeRefreshRequested event, Emitter<HomeState> emit) async {
    await _loadFeed(emit);
  }

  Future<void> _loadFeed(Emitter<HomeState> emit) async {
    try {
      final uid = _auth.currentUser?.uid;
      final snapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.postPageSize)
          .get();

      final posts = await Future.wait(snapshot.docs.map((doc) async {
        bool isLiked = false;
        if (uid != null) {
          final likeDoc = await _firestore
              .collection(AppConstants.postsCollection)
              .doc(doc.id)
              .collection(AppConstants.likesCollection)
              .doc(uid)
              .get();
          isLiked = likeDoc.exists;
        }
        return PostModel.fromFirestore(doc, isLiked: isLiked);
      }));

      emit(HomeLoaded(posts));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onPostLiked(HomePostLiked event, Emitter<HomeState> emit) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final currentState = state;
    if (currentState is! HomeLoaded) return;

    final updatedPosts = currentState.posts.map((post) {
      if (post.id == event.postId) {
        return post.copyWith(
          isLiked: !event.isLiked,
          likesCount: event.isLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
      }
      return post;
    }).toList();
    emit(HomeLoaded(updatedPosts));

    try {
      final likeRef = _firestore
          .collection(AppConstants.postsCollection)
          .doc(event.postId)
          .collection(AppConstants.likesCollection)
          .doc(uid);
      final postRef = _firestore
          .collection(AppConstants.postsCollection)
          .doc(event.postId);

      if (event.isLiked) {
        await likeRef.delete();
        await postRef.update({'likesCount': FieldValue.increment(-1)});
      } else {
        await likeRef.set({'userId': uid, 'createdAt': FieldValue.serverTimestamp()});
        await postRef.update({'likesCount': FieldValue.increment(1)});
      }
    } catch (_) {
      emit(currentState);
    }
  }
}
