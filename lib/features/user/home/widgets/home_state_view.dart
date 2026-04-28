import 'package:flutter/material.dart';

import 'package:hero_app_flutter/constants/app_colors.dart';

class HomeStateView extends StatelessWidget {
  const HomeStateView.loading({super.key})
    : icon = null,
      title = '',
      message = '',
      actionLabel = null,
      isError = false,
      onAction = null,
      _isLoading = true;

  const HomeStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.isError = false,
    this.onAction,
  }) : _isLoading = false;

  final IconData? icon;
  final String title;
  final String message;
  final String? actionLabel;
  final bool isError;
  final VoidCallback? onAction;
  final bool _isLoading;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 64, color: Colors.grey),
          if (icon != null) const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: isError ? Colors.red : Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (message.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: isError ? Colors.red : Colors.grey[700],
                fontSize: 14,
                fontWeight: isError ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
