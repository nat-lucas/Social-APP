import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';

part 'create_post_event.dart';
part 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  CreatePostBloc({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        super(const CreatePostInitial()) {
    on<CreatePostSubmitted>(_onSubmitted);
    on<CreatePostReset>(_onReset);
  }

  Future<void> _onSubmitted(
      CreatePostSubmitted event, Emitter<CreatePostState> emit) async {
    if (event.content.trim().isEmpty && event.imagePath == null) return;
    emit(const CreatePostLoading());

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const CreatePostError('Not authenticated'));
        return;
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>;

      String? imageUrl;
      if (event.imagePath != null) {
        final ref = _storage
            .ref()
            .child('posts/${const Uuid().v4()}.jpg');
        await ref.putFile(File(event.imagePath!));
        imageUrl = await ref.getDownloadURL();
      }

      final postId = const Uuid().v4();
      final postData = {
        'userId': user.uid,
        'username': userData['username'] ?? '',
        'userDisplayName': userData['displayName'] ?? '',
        'userPhotoUrl': userData['photoUrl'],
        'content': event.content.trim(),
        'imageUrl': imageUrl,
        'likesCount': 0,
        'commentsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .set(postData);

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({'postsCount': FieldValue.increment(1)});

      emit(const CreatePostSuccess());
    } catch (e) {
      emit(CreatePostError(e.toString()));
    }
  }

  void _onReset(CreatePostReset event, Emitter<CreatePostState> emit) {
    emit(const CreatePostInitial());
  }
}
