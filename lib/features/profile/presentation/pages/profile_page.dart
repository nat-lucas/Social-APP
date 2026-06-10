import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/models/post_model.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;
  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final String _targetUserId;

  @override
  void initState() {
    super.initState();
    _targetUserId =
        widget.userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<ProfileBloc>().add(ProfileLoadRequested(_targetUserId));
  }

  void _showEditDialog(BuildContext context, String displayName, String bio) {
    final nameCtrl = TextEditingController(text: displayName);
    final bioCtrl = TextEditingController(text: bio);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioCtrl,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(ProfileUpdated(
                    displayName: nameCtrl.text.trim(),
                    bio: bioCtrl.text.trim(),
                  ));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded && state.isCurrentUser) {
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditDialog(
                    context,
                    state.user.displayName,
                    state.user.bio ?? '',
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is ProfileError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: AppColors.error)));
          }
          if (state is ProfileLoaded) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, state)),
                SliverPadding(
                  padding: const EdgeInsets.all(1),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildPostThumbnail(state.posts[i]),
                      childCount: state.posts.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 1,
                      crossAxisSpacing: 1,
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileLoaded state) {
    final user = state.user;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: user.photoUrl != null
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(
                        label: AppStrings.posts,
                        value: user.postsCount.toString()),
                    _StatColumn(
                        label: AppStrings.followers,
                        value: user.followersCount.toString()),
                    _StatColumn(
                        label: AppStrings.following,
                        value: user.followingCount.toString()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(user.displayName,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary)),
          Text('@${user.username}',
              style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(user.bio!,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
          ],
          const SizedBox(height: 16),
          if (!state.isCurrentUser)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.read<ProfileBloc>().add(
                      ProfileFollowToggled(
                        targetUserId: user.id,
                        isFollowing: state.isFollowing,
                      ),
                    ),
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      state.isFollowing ? Colors.transparent : AppColors.primary,
                  side: BorderSide(
                    color: state.isFollowing
                        ? AppColors.divider
                        : AppColors.primary,
                  ),
                ),
                child: Text(
                  state.isFollowing ? AppStrings.following : AppStrings.follow,
                  style: TextStyle(
                    color: state.isFollowing
                        ? AppColors.textPrimary
                        : Colors.white,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.divider),
        ],
      ),
    );
  }

  Widget _buildPostThumbnail(PostModel post) {
    if (post.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: post.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Container(color: AppColors.surfaceVariant),
        errorWidget: (context, url, err) => _textThumbnail(post),
      );
    }
    return _textThumbnail(post);
  }

  Widget _textThumbnail(PostModel post) {
    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.all(6),
      child: Text(
        post.content,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textPrimary)),
        Text(label,
            style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
      ],
    );
  }
}
