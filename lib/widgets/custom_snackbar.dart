import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  Get.snackbar(
    isError ? 'เกิดข้อผิดพลาด' : 'สำเร็จ',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: isError
        ? const Color(0xFFF92A47)
        : const Color(0xFF2AB950),
    colorText: Colors.white,
    margin: const EdgeInsets.all(10),
    borderRadius: 10,
    duration: const Duration(seconds: 2),
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
  );
}
