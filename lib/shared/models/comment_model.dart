import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String userDisplayName;
  final String? userPhotoUrl;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.userDisplayName,
    this.userPhotoUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userDisplayName: data['userDisplayName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'postId': postId,
        'userId': userId,
        'username': username,
        'userDisplayName': userDisplayName,
        'userPhotoUrl': userPhotoUrl,
        'content': content,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  @override
  List<Object?> get props => [id, postId, userId, content];
}
