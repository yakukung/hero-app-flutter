import 'package:flutter/material.dart';

class AuthPageHeader extends StatelessWidget {
  const AuthPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.subtitleFontSize = 24,
  });

  final String title;
  final String subtitle;
  final double subtitleFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF6E6E6E),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
