import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showCustomDialog({
  required String title,
  required String message,
  Widget? content,
  bool isSuccess = false,
  bool isConfirm = false,
  VoidCallback? onOk,
  VoidCallback? onCancel,
}) async {
  await Get.defaultDialog(
    title: '',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSuccess
                ? const Color(0xFFE7F9EE)
                : isConfirm
                ? const Color(0xFFE7F0F9)
                : const Color(0xFFFDEEEF),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(18),
          child: Icon(
            isSuccess
                ? Icons.check_circle_outline
                : isConfirm
                ? Icons.help_outline
                : Icons.error_outline,
            color: isSuccess
                ? const Color(0xFF2AB950)
                : isConfirm
                ? const Color(0xFF2A5DB9)
                : const Color(0xFFF92A47),
            size: 48,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SukhumvitSet',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          message,
          style: const TextStyle(
            fontFamily: 'SukhumvitSet',
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        if (content != null) ...[const SizedBox(height: 20), content],
        const SizedBox(height: 28),
        if (isConfirm)
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    onCancel?.call();
                  },
                  child: const Text('ยกเลิก'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A5DB9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontFamily: 'SukhumvitSet',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    onOk?.call();
                  },
                  child: const Text('ตกลง'),
                ),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: isSuccess
                    ? const Color(0xFF2AB950)
                    : const Color(0xFFF92A47),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontFamily: 'SukhumvitSet',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Get.back();
                onOk?.call();
              },
              child: const Text('ตกลง'),
            ),
          ),
      ],
    ),
    radius: 45,
    backgroundColor: Colors.white,
    barrierDismissible: false,
  );
}
