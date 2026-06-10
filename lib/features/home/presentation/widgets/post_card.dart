import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/post_model.dart';
import 'comment_sheet.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final String currentUserId;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (post.content.isNotEmpty) _buildContent(context),
          if (post.imageUrl != null) _buildImage(),
          _buildActions(context),
          const Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: post.userPhotoUrl != null
                ? CachedNetworkImageProvider(post.userPhotoUrl!)
                : null,
            child: post.userPhotoUrl == null
                ? Text(
                    post.userDisplayName.isNotEmpty
                        ? post.userDisplayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userDisplayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '@${post.username} · ${timeago.format(post.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (post.userId == currentUserId)
            IconButton(
              icon: const Icon(Icons.more_horiz, color: AppColors.textHint),
              onPressed: () {},
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        post.content,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildImage() {
    return CachedNetworkImage(
      imageUrl: post.imageUrl!,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 200,
        color: AppColors.surfaceVariant,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 200,
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.broken_image, color: AppColors.textHint),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _ActionButton(
            icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
            label: post.likesCount.toString(),
            color: post.isLiked ? AppColors.like : AppColors.textHint,
            onTap: onLike,
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: post.commentsCount.toString(),
            color: AppColors.textHint,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => CommentSheet(post: post),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textHint, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
