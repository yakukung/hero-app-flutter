import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';

class AdminColors {
  const AdminColors._();

  static const background = Colors.white;
  static const surface = Colors.white;
  static const surfaceAlt = Color(0xFFF7F9FE);
  static const border = Color(0xFFDDE5F1);
  static const text = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const success = Color(0xFF1B7F3A);
  static const warning = Color(0xFFB26A00);
  static const danger = Color(0xFFC62828);
  static const primary = AppColors.primary;
}

class AdminCard extends StatelessWidget {
  const AdminCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      color: AdminColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AdminColors.border),
        borderRadius: BorderRadius.circular(26),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (margin == null) return card;
    return Padding(padding: margin!, child: card);
  }
}

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AdminColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: AdminColors.primary),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppFonts.sukhumvit,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AdminColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: AppFonts.sukhumvit,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.muted,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class AdminStatusPill extends StatelessWidget {
  const AdminStatusPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.sukhumvit,
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
