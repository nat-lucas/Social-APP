import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_router.dart';
import '../bloc/home_bloc.dart';
import '../widgets/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeFeedLoaded());
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.appName,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: AppColors.primary),
            onPressed: () => context.push(AppRouter.createPost),
            tooltip: 'Create Post',
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<HomeBloc>().add(const HomeFeedLoaded()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is HomeLoaded) {
            if (state.posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.feed_outlined,
                        color: AppColors.textHint, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.noPostsYet,
                      style: TextStyle(color: AppColors.textHint, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push(AppRouter.createPost),
                      child: const Text('Create First Post'),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                context.read<HomeBloc>().add(const HomeRefreshRequested());
              },
              child: ListView.separated(
                itemCount: state.posts.length,
                separatorBuilder: (context, i) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final post = state.posts[i];
                  return PostCard(
                    post: post,
                    currentUserId: currentUserId,
                    onLike: () => context.read<HomeBloc>().add(
                          HomePostLiked(
                            postId: post.id,
                            isLiked: post.isLiked,
                          ),
                        ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
