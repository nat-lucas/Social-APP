part of 'create_post_bloc.dart';

abstract class CreatePostEvent extends Equatable {
  const CreatePostEvent();
  @override
  List<Object?> get props => [];
}

class CreatePostSubmitted extends CreatePostEvent {
  final String content;
  final String? imagePath;
  const CreatePostSubmitted({required this.content, this.imagePath});
  @override
  List<Object?> get props => [content, imagePath];
}

class CreatePostReset extends CreatePostEvent {
  const CreatePostReset();
}
