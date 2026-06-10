class AppConstants {
  AppConstants._();

  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String notificationsCollection = 'notifications';
  static const String likesCollection = 'likes';

  static const int postPageSize = 10;
  static const int commentsPageSize = 20;
  static const int notificationsPageSize = 20;

  static const double borderRadius = 12.0;
  static const double cardRadius = 16.0;
  static const double avatarRadius = 20.0;
  static const double avatarRadiusLarge = 40.0;

  static const Duration animationDuration = Duration(milliseconds: 300);
}
