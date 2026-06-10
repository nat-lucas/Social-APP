part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final List<PostModel> posts;
  final bool isFollowing;
  final bool isCurrentUser;
  const ProfileLoaded({
    required this.user,
    required this.posts,
    required this.isFollowing,
    required this.isCurrentUser,
  });
  @override
  List<Object> get props => [user, posts, isFollowing, isCurrentUser];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}
