import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';

Future<void> showCustomDialog({
  required String title,
  required String message,
  Widget? content,
  bool isSuccess = false,
  bool isConfirm = false,
  bool isDanger = false,
  String? okButtonLabel,
  VoidCallback? onOk,
  VoidCallback? onCancel,
}) async {
  final buttonLabel = okButtonLabel ?? (isConfirm ? title : 'ตกลง');
  final actionColor = isDanger
      ? const Color(0xFFF92A47)
      : isSuccess
          ? const Color(0xFF2AB950)
          : const Color(0xFF2A5DB9);

  final context = Get.overlayContext;
  if (context == null) return;

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Stack(
      children: [
        // ── Backdrop blur ──
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: const SizedBox(),
          ),
        ),

        // ── Sheet content ──
        Container(
          height: content != null ? 420 : 350,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Drag handle ──
              Container(
                width: 80,
                height: 6,
                margin: const EdgeInsets.only(bottom: 60),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              // ── Title ──
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppFonts.sukhumvit,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // ── Message ──
              Text(
                message,
                style: const TextStyle(
                  fontFamily: AppFonts.sukhumvit,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF6E6E6E),
                ),
                textAlign: TextAlign.center,
              ),

              // ── Optional content widget ──
              if (content != null) ...[
                const SizedBox(height: 20),
                content,
              ],

              const SizedBox(height: 50),

              // ── Buttons ──
              if (isConfirm)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        onCancel?.call();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'ยกเลิก',
                          style: TextStyle(
                            fontFamily: AppFonts.sukhumvit,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        onOk?.call();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          buttonLabel,
                          style: TextStyle(
                            fontFamily: AppFonts.sukhumvit,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: actionColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Center(
                  child: TextButton(
                    onPressed: () {
                      Get.back();
                      onOk?.call();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        buttonLabel,
                        style: TextStyle(
                          fontFamily: AppFonts.sukhumvit,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: actionColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
