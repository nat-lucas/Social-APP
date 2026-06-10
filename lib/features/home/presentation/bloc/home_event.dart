part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeFeedLoaded extends HomeEvent {
  const HomeFeedLoaded();
}

class HomePostLiked extends HomeEvent {
  final String postId;
  final bool isLiked;
  const HomePostLiked({required this.postId, required this.isLiked});
  @override
  List<Object> get props => [postId, isLiked];
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}
