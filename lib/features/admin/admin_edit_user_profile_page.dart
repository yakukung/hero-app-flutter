import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hero_app_flutter/core/config/api_connect.dart';
import 'package:hero_app_flutter/core/controllers/admin_controller.dart';
import 'package:hero_app_flutter/core/models/user_model.dart'; // Ensure UserModel is imported
import 'package:hero_app_flutter/core/models/upload_state.dart';
import 'package:hero_app_flutter/core/services/users_service.dart';
import 'package:hero_app_flutter/features/admin/admin_change_username_page.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart'; // Needed for showCustomDialog if used, or standard dialogs
import 'package:hero_app_flutter/shared/widgets/upload/upload_progress_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/constants/app_assets.dart';

class AdminEditUserProfilePage extends StatefulWidget {
  final UserModel user;

  const AdminEditUserProfilePage({super.key, required this.user});

  @override
  State<AdminEditUserProfilePage> createState() =>
      _AdminEditUserProfilePageState();
}

class _AdminEditUserProfilePageState extends State<AdminEditUserProfilePage> {
  final AdminController _adminController = Get.find<AdminController>();
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

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
    final String currentUid = GetStorage().read('uid')?.toString() ?? '';
    if (currentUid.isEmpty || currentUid != _currentUser.id) {
      showCustomDialog(
        title: 'ยังไม่รองรับ',
        message:
            'แบ็กเอนด์เวอร์ชันปัจจุบันยังไม่รองรับให้แอดมินเปลี่ยนรูปโปรไฟล์ของผู้ใช้อื่น',
      );
      return;
    }

    final stateNotifier = ValueNotifier(const UploadState(isUploading: true));
    if (mounted) {
      UploadProgressDialog.show(stateNotifier: stateNotifier);
    }

    try {
      final result = await UsersService.updateProfileImage(
        uid: _currentUser.id,
        imageFile: imageFile,
      );

      if (result.success) {
        if (!mounted) return;
        final updatedUser = await _adminController.fetchUserById(
          _currentUser.id,
        );

        if (updatedUser != null) {
          setState(() {
            _currentUser = updatedUser;
            _pickedImage =
                null; // Reset picked image as we now have the updated network image
          });
        }

        stateNotifier.value = stateNotifier.value.copyWith(
          isUploading: false,
          isSuccess: true,
          progress: 1.0,
        );
      } else {
        stateNotifier.value = stateNotifier.value.copyWith(
          isUploading: false,
          isSuccess: false,
          errorMessage: result.message,
        );
      }
    } catch (e) {
      debugPrint('Error updating user profile image (admin): $e');
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'แก้ไขข้อมูลผู้ใช้ (Admin)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () =>
              Get.back(result: _currentUser), // Return updated user
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
                          : (_currentUser.profileImage != null &&
                                        _currentUser.profileImage!.isNotEmpty
                                    ? NetworkImage(
                                        _currentUser.profileImage!.startsWith(
                                              'http',
                                            )
                                            ? _currentUser.profileImage!
                                            : '$apiEndpoint/${_currentUser.profileImage}',
                                      )
                                    : const AssetImage(AppAssets.defaultAvatar))
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
              onPressed: () async {
                final String currentUid =
                    GetStorage().read('uid')?.toString() ?? '';
                if (currentUid.isEmpty || currentUid != _currentUser.id) {
                  showCustomDialog(
                    title: 'ยังไม่รองรับ',
                    message:
                        'แบ็กเอนด์เวอร์ชันปัจจุบันยังไม่รองรับให้แอดมินเปลี่ยนชื่อผู้ใช้ของผู้ใช้อื่น',
                  );
                  return;
                }

                final result = await Get.to(
                  () => AdminChangeUsernamePage(
                    userId: _currentUser.id,
                    currentUsername: _currentUser.username ?? '',
                  ),
                );

                if (result == true) {
                  if (!context.mounted) return;
                  final updatedUser = await _adminController.fetchUserById(
                    _currentUser.id,
                  );
                  if (updatedUser != null && mounted) {
                    setState(() {
                      _currentUser = updatedUser;
                    });
                  }
                }
              },
            ),
            Opacity(
              opacity: 0.5,
              child: _buildMenuButton(
                title: 'เปลี่ยนอีเมล (ยังไม่เปิดใช้งาน)',
                icon: Icons.email_outlined,
                onPressed: () {
                  showCustomDialog(
                    title: 'แจ้งเตือน',
                    message: 'ฟีเจอร์นี้ยังไม่เปิดใช้งานสำหรับ Admin',
                  );
                },
              ),
            ),
            Opacity(
              opacity: 0.5,
              child: _buildMenuButton(
                title: 'เปลี่ยนรหัสผ่าน (ยังไม่เปิดใช้งาน)',
                icon: Icons.lock_outline_rounded,
                onPressed: () {
                  showCustomDialog(
                    title: 'แจ้งเตือน',
                    message: 'ฟีเจอร์นี้ยังไม่เปิดใช้งานสำหรับ Admin',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
