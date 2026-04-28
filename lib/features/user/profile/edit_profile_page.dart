import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_assets.dart';
import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/core/models/upload_state.dart';
import 'package:hero_app_flutter/core/services/users_service.dart';
import 'package:hero_app_flutter/features/user/profile/change_email_page.dart';
import 'package:hero_app_flutter/features/user/profile/change_password_page.dart';
import 'package:hero_app_flutter/features/user/profile/change_username_page.dart';
import 'package:hero_app_flutter/shared/widgets/upload/upload_progress_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AppController _appController = Get.find<AppController>();
  final ImagePicker _picker = ImagePicker();

  File? _pickedImage;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      await _uploadProfileImage(File(image.path));
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    final stateNotifier = ValueNotifier(const UploadState(isUploading: true));
    if (mounted) {
      UploadProgressDialog.show(stateNotifier: stateNotifier);
    }

    try {
      final result = await UsersService.updateProfileImage(
        uid: _appController.uid,
        imageFile: imageFile,
        onProgress: (bytes, total) {
          stateNotifier.value = stateNotifier.value.copyWith(
            progress: total == 0 ? 0 : bytes / total,
          );
        },
      );

      if (result.success) {
        if (result.profileImage != null && result.profileImage!.isNotEmpty) {
          _appController.setProfileImage(result.profileImage!);
        } else {
          await _appController.fetchUserData();
        }
        stateNotifier.value = stateNotifier.value.copyWith(
          isUploading: false,
          isSuccess: true,
          progress: 1.0,
        );
        setState(() {
          _pickedImage = imageFile;
        });
      } else {
        stateNotifier.value = stateNotifier.value.copyWith(
          isUploading: false,
          isSuccess: false,
          errorMessage: result.message,
        );
      }
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      stateNotifier.value = stateNotifier.value.copyWith(
        isUploading: false,
        isSuccess: false,
        errorMessage: 'อัปเดตรูปภาพไม่สำเร็จ: ${e.toString()}',
      );
    }
  }

  Widget _buildMenuButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Color(0xFFC4C4C4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isGoogle = _appController.provider == 'GOOGLE';

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'แก้ไขข้อมูลส่วนตัว',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (_appController.profileImage.isNotEmpty
                                      ? NetworkImage(
                                          _appController.profileImage,
                                        )
                                      : const AssetImage(
                                          AppAssets.defaultAvatar,
                                        ))
                                  as ImageProvider,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'แตะเพื่อเปลี่ยนรูปโปรไฟล์',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              _buildMenuButton(
                title: 'เปลี่ยนชื่อผู้ใช้',
                icon: Icons.person_outline_rounded,
                onPressed: () {
                  Get.to(() => const ChangeUsernamePage());
                },
              ),
              if (isGoogle) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/logo/google-icon-logo.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.g_mobiledata, size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'เชื่อมต่อผ่าน Google',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'บัญชีนี้เชื่อมต่อกับ Google แล้ว',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF2AB950),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _buildMenuButton(
                  title: 'เปลี่ยนอีเมล',
                  icon: Icons.email_outlined,
                  onPressed: () {
                    Get.to(() => const ChangeEmailPage());
                  },
                ),
                _buildMenuButton(
                  title: 'เปลี่ยนรหัสผ่าน',
                  icon: Icons.lock_outline_rounded,
                  onPressed: () {
                    Get.to(() => const ChangePasswordPage());
                  },
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
