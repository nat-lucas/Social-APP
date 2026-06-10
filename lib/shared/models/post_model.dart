import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String userDisplayName;
  final String? userPhotoUrl;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userDisplayName,
    this.userPhotoUrl,
    required this.content,
    this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc, {bool isLiked = false}) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userDisplayName: data['userDisplayName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      isLiked: isLiked,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'username': username,
        'userDisplayName': userDisplayName,
        'userPhotoUrl': userPhotoUrl,
        'content': content,
        'imageUrl': imageUrl,
        'likesCount': likesCount,
        'commentsCount': commentsCount,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  PostModel copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    String? imageUrl,
  }) =>
      PostModel(
        id: id,
        userId: userId,
        username: username,
        userDisplayName: userDisplayName,
        userPhotoUrl: userPhotoUrl,
        content: content,
        imageUrl: imageUrl ?? this.imageUrl,
        likesCount: likesCount ?? this.likesCount,
        commentsCount: commentsCount ?? this.commentsCount,
        isLiked: isLiked ?? this.isLiked,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, userId, content, likesCount, commentsCount, isLiked];
}
