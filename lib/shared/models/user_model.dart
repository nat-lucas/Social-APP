import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      postsCount: data['postsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'username': username,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'bio': bio,
        'followersCount': followersCount,
        'followingCount': followingCount,
        'postsCount': postsCount,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    int? followersCount,
    int? followingCount,
    int? postsCount,
  }) =>
      UserModel(
        id: id,
        email: email,
        username: username,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        bio: bio ?? this.bio,
        followersCount: followersCount ?? this.followersCount,
        followingCount: followingCount ?? this.followingCount,
        postsCount: postsCount ?? this.postsCount,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, email, username, displayName, photoUrl, bio];
}
