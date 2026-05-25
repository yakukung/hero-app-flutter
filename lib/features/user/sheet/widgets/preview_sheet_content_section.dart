import 'package:flutter/material.dart';

import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/core/config/api_connect.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/shared/widgets/profile_avatar.dart';

class PreviewSheetContentSection extends StatelessWidget {
  const PreviewSheetContentSection({
    super.key,
    required this.sheet,
    this.onAuthorTap,
  });

  final SheetModel sheet;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final price = sheet.price ?? 0;
    final isFree = price == 0;

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        transform: Matrix4.translationValues(0, -20, 0),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    sheet.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isFree ? 'ฟรี' : '${sheet.price}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isFree ? Colors.green : AppColors.primary,
                      ),
                    ),
                    if (!isFree)
                      const Text(
                        'บาท',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ProfileAvatar(
                  uid: sheet.authorId,
                  username: sheet.authorName,
                  imageUrl: sheet.authorAvatar,
                  size: 32,
                  apiEndpoint: apiEndpoint,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onAuthorTap,
                  child: Text(
                    sheet.authorName ?? 'ไม่ระบุ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC107),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${sheet.rating ?? 0.0}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
            const SizedBox(height: 32),
            const Divider(height: 1),
            const SizedBox(height: 24),
            const Text(
              'รายละเอียด',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              sheet.description ?? 'ไม่มีรายละเอียด',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF555555),
                height: 1.6,
              ),
            ),
            if (sheet.categoryNames != null &&
                sheet.categoryNames!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'หมวดหมู่',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: sheet.categoryNames!
                    .map((name) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3B5E8C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
            if (sheet.keywordNames != null &&
                sheet.keywordNames!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'คีย์เวิร์ด',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: sheet.keywordNames!
                    .map((name) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
