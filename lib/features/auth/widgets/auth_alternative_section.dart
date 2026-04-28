import 'package:flutter/material.dart';

import 'package:hero_app_flutter/constants/app_colors.dart';

class AuthAlternativeSection extends StatelessWidget {
  const AuthAlternativeSection({super.key, required this.onGoogleTap});

  final VoidCallback onGoogleTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Text(
              'หรือ ดำเนินต่อด้วยวิธีอื่น',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onGoogleTap,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 24,
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo/google-icon-logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
