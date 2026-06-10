part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationsEvent {
  const NotificationsLoadRequested();
}

class NotificationMarkedRead extends NotificationsEvent {
  final String notificationId;
  const NotificationMarkedRead(this.notificationId);
  @override
  List<Object> get props => [notificationId];
}

class NotificationsAllMarkedRead extends NotificationsEvent {
  const NotificationsAllMarkedRead();
}
