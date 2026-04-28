import 'package:flutter/material.dart';

import 'package:hero_app_flutter/constants/app_colors.dart';

class PreviewSheetBottomActionBar extends StatelessWidget {
  const PreviewSheetBottomActionBar({
    super.key,
    required this.canReadFull,
    required this.hasQuestions,
    required this.onReadPreview,
    required this.onReadFull,
    required this.onBuy,
    required this.onQuiz,
  });

  final bool canReadFull;
  final bool hasQuestions;
  final VoidCallback onReadPreview;
  final VoidCallback onReadFull;
  final VoidCallback onBuy;
  final VoidCallback onQuiz;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 40,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: canReadFull
            ? _PurchasedActions(
                hasQuestions: hasQuestions,
                onReadFull: onReadFull,
                onQuiz: onQuiz,
              )
            : _PreviewActions(onReadPreview: onReadPreview, onBuy: onBuy),
      ),
    );
  }
}

class _PurchasedActions extends StatelessWidget {
  const _PurchasedActions({
    required this.hasQuestions,
    required this.onReadFull,
    required this.onQuiz,
  });

  final bool hasQuestions;
  final VoidCallback onReadFull;
  final VoidCallback onQuiz;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: ElevatedButton(
            onPressed: onReadFull,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'อ่านฉบับเต็ม',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasQuestions) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: OutlinedButton(
              onPressed: onQuiz,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'ทำโจทย์บทนี้',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PreviewActions extends StatelessWidget {
  const _PreviewActions({required this.onReadPreview, required this.onBuy});

  final VoidCallback onReadPreview;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: OutlinedButton(
            onPressed: onReadPreview,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'เริ่มอ่านตัวอย่าง',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'ซื้อ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
