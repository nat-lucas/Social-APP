import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/create_post/presentation/bloc/create_post_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';

class SocialApp extends StatelessWidget {
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            auth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          )..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => HomeBloc(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
          ),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
          ),
        ),
        BlocProvider(
          create: (_) => CreatePostBloc(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
            storage: FirebaseStorage.instance,
          ),
        ),
        BlocProvider(
          create: (_) => NotificationsBloc(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'SocialApp',
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
