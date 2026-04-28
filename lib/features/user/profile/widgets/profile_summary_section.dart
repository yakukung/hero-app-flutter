import 'package:flutter/material.dart';

import 'package:hero_app_flutter/constants/app_assets.dart';
import 'package:hero_app_flutter/constants/app_colors.dart';

class ProfileSummarySection extends StatelessWidget {
  const ProfileSummarySection({
    super.key,
    required this.profileImage,
    required this.username,
    required this.email,
    required this.followersCount,
    required this.followingsCount,
    required this.onEditAvatar,
  });

  final String profileImage;
  final String username;
  final String email;
  final int followersCount;
  final int followingsCount;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          GestureDetector(
            onTap: onEditAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: profileImage.isNotEmpty
                        ? Image.network(
                            profileImage,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            AppAssets.defaultAvatar,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username.isNotEmpty ? username : 'ชื่อผู้ใช้',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ProfileStatItem(label: 'ผู้ติดตาม', count: followersCount),
                    Container(
                      height: 12,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.grey[300],
                    ),
                    _ProfileStatItem(
                      label: 'กำลังติดตาม',
                      count: followingsCount,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatItem extends StatelessWidget {
  const _ProfileStatItem({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
