import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/models/notification_model.dart';
import '../../../../core/constants/app_constants.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationsBloc({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const NotificationsInitial()) {
    on<NotificationsLoadRequested>(_onLoaded);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationsAllMarkedRead>(_onAllMarkedRead);
  }

  Future<void> _onLoaded(
      NotificationsLoadRequested event, Emitter<NotificationsState> emit) async {
    emit(const NotificationsLoading());
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(const NotificationsError('Not authenticated'));
        return;
      }
      final snapshot = await _firestore
          .collection(AppConstants.notificationsCollection)
          .where('recipientId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.notificationsPageSize)
          .get();

      final notifications =
          snapshot.docs.map(NotificationModel.fromFirestore).toList();
      final unread = notifications.where((n) => !n.isRead).length;

      emit(NotificationsLoaded(notifications: notifications, unreadCount: unread));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkedRead(
      NotificationMarkedRead event, Emitter<NotificationsState> emit) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    final updated = currentState.notifications.map((n) {
      if (n.id == event.notificationId) {
        return NotificationModel(
          id: n.id,
          recipientId: n.recipientId,
          senderId: n.senderId,
          senderUsername: n.senderUsername,
          senderPhotoUrl: n.senderPhotoUrl,
          type: n.type,
          postId: n.postId,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();

    emit(NotificationsLoaded(
      notifications: updated,
      unreadCount: updated.where((n) => !n.isRead).length,
    ));

    await _firestore
        .collection(AppConstants.notificationsCollection)
        .doc(event.notificationId)
        .update({'isRead': true});
  }

  Future<void> _onAllMarkedRead(
      NotificationsAllMarkedRead event, Emitter<NotificationsState> emit) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    final batch = _firestore.batch();
    for (final n in currentState.notifications.where((n) => !n.isRead)) {
      batch.update(
        _firestore
            .collection(AppConstants.notificationsCollection)
            .doc(n.id),
        {'isRead': true},
      );
    }
    await batch.commit();

    final updated = currentState.notifications
        .map((n) => NotificationModel(
              id: n.id,
              recipientId: n.recipientId,
              senderId: n.senderId,
              senderUsername: n.senderUsername,
              senderPhotoUrl: n.senderPhotoUrl,
              type: n.type,
              postId: n.postId,
              isRead: true,
              createdAt: n.createdAt,
            ))
        .toList();

    emit(NotificationsLoaded(notifications: updated, unreadCount: 0));
  }
}
