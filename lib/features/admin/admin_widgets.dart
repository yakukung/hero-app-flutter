import 'package:flutter/material.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';

class AdminSectionHeader extends StatelessWidget {
  const AdminSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AdminColors.text,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: AdminColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class AdminInfoText extends StatelessWidget {
  const AdminInfoText({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 4),
        Flexible(
          child: Text(text, style: const TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }
}

class AdminInlineEmptyState extends StatelessWidget {
  const AdminInlineEmptyState({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AdminColors.border),
        borderRadius: BorderRadius.circular(24),
        color: AdminColors.surfaceAlt,
      ),
      child: Text(text, style: const TextStyle(color: AdminColors.muted)),
    );
  }
}

class AdminEmptyStatePage extends StatelessWidget {
  const AdminEmptyStatePage({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
    this.onRefresh,
  });

  final String title;
  final IconData icon;
  final String message;
  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AdminColors.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AdminColors.text,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AdminColors.muted, fontSize: 15),
            ),
          ],
        ),
      ),
    );

    final refreshCallback = onRefresh;
    if (refreshCallback == null) {
      return content;
    }

    return RefreshIndicator(
      onRefresh: refreshCallback,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: content,
              ),
            ],
          );
        },
      ),
    );
  }
}
