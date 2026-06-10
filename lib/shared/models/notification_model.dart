import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum NotificationType { like, comment, follow }

class NotificationModel extends Equatable {
  final String id;
  final String recipientId;
  final String senderId;
  final String senderUsername;
  final String? senderPhotoUrl;
  final NotificationType type;
  final String? postId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.senderUsername,
    this.senderPhotoUrl,
    required this.type,
    this.postId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderUsername: data['senderUsername'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.like,
      ),
      postId: data['postId'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'recipientId': recipientId,
        'senderId': senderId,
        'senderUsername': senderUsername,
        'senderPhotoUrl': senderPhotoUrl,
        'type': type.name,
        'postId': postId,
        'isRead': isRead,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  String get message {
    switch (type) {
      case NotificationType.like:
        return 'liked your post';
      case NotificationType.comment:
        return 'commented on your post';
      case NotificationType.follow:
        return 'started following you';
    }
  }

  @override
  List<Object?> get props => [id, recipientId, senderId, type, isRead];
}
