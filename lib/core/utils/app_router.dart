import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/create_post/presentation/pages/create_post_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../shared/widgets/main_scaffold.dart';

class AppRouter {
  AppRouter._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/';
  static const String profile = '/profile';
  static const String createPost = '/create-post';
  static const String notifications = '/notifications';
  static const String userProfile = '/user/:userId';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isAuthenticated = user != null;
      final isAuthRoute =
          state.matchedLocation == login || state.matchedLocation == signup;

      if (!isAuthenticated && !isAuthRoute) return login;
      if (isAuthenticated && isAuthRoute) return home;
      return null;
    },
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: signup,
        builder: (context, state) => const SignUpPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: notifications,
            builder: (context, state) => const NotificationsPage(),
          ),
        ],
      ),
      GoRoute(
        path: createPost,
        builder: (context, state) => const CreatePostPage(),
      ),
      GoRoute(
        path: userProfile,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfilePage(userId: userId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}
