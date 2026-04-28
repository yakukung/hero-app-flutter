import 'package:flutter/material.dart';

class ProfileActionGrid extends StatelessWidget {
  const ProfileActionGrid({
    super.key,
    required this.wallet,
    required this.onEditProfile,
    required this.onShowSubscriptions,
    required this.onOpenUserSheets,
    this.fontButtonSize = 14,
  });

  final double wallet;
  final VoidCallback onEditProfile;
  final VoidCallback onShowSubscriptions;
  final VoidCallback onOpenUserSheets;
  final int fontButtonSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ProfileActionButton(
                  label: 'แก้ไขข้อมูลส่วนตัว',
                  fontButtonSize: fontButtonSize,
                  onPressed: onEditProfile,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileActionButton(
                  label: 'แก้ไขแพ็กเกจสมาชิกของคุณ',
                  fontButtonSize: fontButtonSize,
                  onPressed: onShowSubscriptions,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ProfileActionButton(
                  label: 'ยอดเงินคงเหลือ\n${wallet.toStringAsFixed(0)} บาท',
                  fontButtonSize: fontButtonSize,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileActionButton(
                  label: 'รายการชีต\nทั้งหมดของคุณ',
                  fontButtonSize: fontButtonSize,
                  onPressed: onOpenUserSheets,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    required this.fontButtonSize,
    required this.onPressed,
  });

  final String label;
  final int fontButtonSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFD4E1FF),
        minimumSize: const Size(0, 86),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      label: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontButtonSize.toDouble(),
          color: Colors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
