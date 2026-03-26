import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/post_model.dart';
import 'package:flutter_application_1/constants/app_colors.dart';

class CommunityPostCard extends StatelessWidget {
  final PostModel post;
  final String formattedDate;
  final ImageProvider? avatarProvider;
  final VoidCallback onUserTap;
  final VoidCallback onReportTap;
  final VoidCallback? onSheetTap;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.formattedDate,
    required this.avatarProvider,
    required this.onUserTap,
    required this.onReportTap,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    this.onSheetTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onUserTap,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      avatarProvider ??
                      const NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/847/847969.png',
                          )
                          as ImageProvider,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onUserTap,
                      child: Text(
                        post.author.username ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onReportTap,
                child: const Icon(Icons.more_vert, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(post.content, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              if (post.sheetId != null)
                GestureDetector(
                  onTap: onSheetTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ดูสินค้า',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              const Spacer(),
              _ActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${post.likeCount}',
                color: post.isLiked ? AppColors.primary : Colors.white,
                textColor: post.isLiked ? Colors.white : Colors.black54,
                isActive: post.isLiked,
                onTap: onLikeTap,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post.commentCount}',
                color: Colors.white,
                isActive: false,
                onTap: onCommentTap,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.share,
                label: '${post.shareCount}',
                color: Colors.white,
                isActive: false,
                onTap: onShareTap,
              ),
            ],
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
  final bool isActive;
  final Color? textColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.isActive = false,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : textColor ?? Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
