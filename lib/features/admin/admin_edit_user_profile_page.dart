import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hero_app_flutter/core/config/api_connect.dart';
import 'package:hero_app_flutter/core/controllers/admin_controller.dart';
import 'package:hero_app_flutter/core/models/user_model.dart'; // Ensure UserModel is imported
import 'package:hero_app_flutter/core/models/upload_state.dart';
import 'package:hero_app_flutter/core/services/users_service.dart';
import 'package:hero_app_flutter/features/admin/admin_change_username_page.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart'; // Needed for showCustomDialog if used, or standard dialogs
import 'package:hero_app_flutter/shared/widgets/upload/upload_progress_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
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

  Future<void> _refreshCurrentUser() async {
    final updatedUser = await _adminController.fetchUserById(_currentUser.id);
    if (updatedUser == null || !mounted) return;
    setState(() {
      _currentUser = updatedUser;
      _pickedImage = null;
    });
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
    return AdminCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      onTap: onPressed,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AdminColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: AdminColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AdminColors.text,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: AdminColors.muted),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text(
          'แก้ไขข้อมูลผู้ใช้',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AdminColors.text,
          ),
        ),
        centerTitle: true,
        backgroundColor: AdminColors.background,
        surfaceTintColor: AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AdminColors.text),
          onPressed: () =>
              Get.back(result: _currentUser), // Return updated user
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          children: [
            AdminCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AdminColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image(
                            image: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (_currentUser.profileImage != null &&
                                              _currentUser
                                                  .profileImage!
                                                  .isNotEmpty
                                          ? NetworkImage(
                                              _currentUser.profileImage!
                                                      .startsWith('http')
                                                  ? _currentUser.profileImage!
                                                  : '$apiEndpoint/${_currentUser.profileImage}',
                                            )
                                          : const AssetImage(
                                              AppAssets.defaultAvatar,
                                            ))
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AdminColors.primary,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _currentUser.username ?? 'ไม่ระบุชื่อ',
                    style: const TextStyle(
                      color: AdminColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'แตะรูปเพื่อเปลี่ยนโปรไฟล์',
                    style: TextStyle(
                      color: AdminColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                  await _refreshCurrentUser();
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
