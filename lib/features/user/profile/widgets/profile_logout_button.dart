import 'package:flutter/material.dart';

class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({
    super.key,
    required this.onPressed,
    this.fontButtonSize = 14,
  });

  final VoidCallback onPressed;
  final int fontButtonSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.logout, color: Colors.black),
        label: Text(
          'ออกจากระบบ',
          style: TextStyle(
            fontSize: fontButtonSize.toDouble(),
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
