part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  const ProfileLoadRequested(this.userId);
  @override
  List<Object> get props => [userId];
}

class ProfileFollowToggled extends ProfileEvent {
  final String targetUserId;
  final bool isFollowing;
  const ProfileFollowToggled({required this.targetUserId, required this.isFollowing});
  @override
  List<Object> get props => [targetUserId, isFollowing];
}

class ProfileUpdated extends ProfileEvent {
  final String displayName;
  final String bio;
  const ProfileUpdated({required this.displayName, required this.bio});
  @override
  List<Object> get props => [displayName, bio];
}
