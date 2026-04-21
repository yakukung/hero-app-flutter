import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/controllers/app_controller.dart';
import 'package:flutter_application_1/core/models/upload_state.dart';
import 'package:flutter_application_1/core/services/users_service.dart';
import 'package:flutter_application_1/features/auth/intro.dart';
import 'package:flutter_application_1/features/user/edit_profile.dart';
import 'package:flutter_application_1/features/user/user_sheets.dart';
import 'package:flutter_application_1/core/session/session_store.dart';
import 'package:flutter_application_1/shared/widgets/upload/upload_progress_dialog.dart';
import 'package:flutter_application_1/shared/widgets/custom_dialog.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/constants/app_assets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AppController _appController = Get.find<AppController>();
  final ImagePicker _picker = ImagePicker();

  final fontButtonSize = 14;

  Future<void> _uploadProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      final stateNotifier = ValueNotifier(const UploadState(isUploading: true));
      if (mounted) {
        UploadProgressDialog.show(stateNotifier: stateNotifier);
      }

      try {
        final file = File(image.path);
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('ไฟล์รูปภาพใหญ่เกิน 5MB');
        }

        final result = await UsersService.updateProfileImage(
          uid: _appController.uid,
          imageFile: file,
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
        } else {
          stateNotifier.value = stateNotifier.value.copyWith(
            isUploading: false,
            isSuccess: false,
            errorMessage: result.message,
          );
        }
      } catch (e) {
        debugPrint('Error uploading profile image: $e');
        stateNotifier.value = stateNotifier.value.copyWith(
          isUploading: false,
          isSuccess: false,
          errorMessage: 'อัปโหลดรูปภาพไม่สำเร็จ: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () async {
            await _appController.fetchUserData();
          },
          child: ListView(
            children: [
              SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _uploadProfileImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: _appController.profileImage.isNotEmpty
                                  ? Image.network(
                                      _appController.profileImage,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      AppAssets.defaultAvatar,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _appController.username.isNotEmpty
                                ? _appController.username
                                : 'ชื่อผู้ใช้',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_appController.email.isNotEmpty)
                            Text(
                              _appController.email,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),

                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildStatItem(
                                context,
                                'ผู้ติดตาม',
                                _appController.followersCount,
                              ),
                              Container(
                                height: 12,
                                width: 1,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                color: Colors.grey[300],
                              ),
                              _buildStatItem(
                                context,
                                'กำลังติดตาม',
                                _appController.followingsCount,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD4E1FF),
                              minimumSize: const Size(0, 86),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            label: Text(
                              'แก้ไขข้อมูลส่วนตัว',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontButtonSize.toDouble(),
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onPressed: () {
                              Get.to(() => const EditProfilePage());
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD4E1FF),
                              minimumSize: const Size(0, 86),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            label: Text(
                              'แก้ไขแพ็กเกจสมาชิกของคุณ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontButtonSize.toDouble(),
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onPressed: () {
                              _showSubscriptionPackages(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD4E1FF),
                              minimumSize: const Size(0, 86),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            label: Text(
                              'ยอดเงินคงเหลือ\n${_appController.wallet} บาท',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontButtonSize.toDouble(),
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD4E1FF),
                              minimumSize: const Size(0, 86),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            label: Text(
                              'รายการชีต\nทั้งหมดของคุณ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontButtonSize.toDouble(),
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onPressed: () =>
                                _openUserSheets(_appController.uid),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
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
                        onPressed: () => _showLogoutConfirmation(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showCustomDialog(
      title: 'ยืนยันออกจากระบบ',
      message: 'คุณต้องการออกจากระบบใช่ไหม?',
      isConfirm: true,
      onOk: () async {
        await SessionStore().eraseAll();
        Get.offAll(() => const IntroPage());
      },
    );
  }

  void _openUserSheets(String userId) {
    if (userId.isEmpty) {
      showCustomDialog(
        title: 'ไม่พบข้อมูลผู้ใช้',
        message: 'กรุณาเข้าสู่ระบบใหม่แล้วลองอีกครั้ง',
      );
      return;
    }

    Get.to(() => UserSheetsPage(userId: userId));
  }

  void _showSubscriptionPackages(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'แพ็กเกจสมาชิกพรีเมียม',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildPackageCard(
                        title: 'รายเดือน',
                        price: '฿79.00/เดือน',
                        buttonText: 'ชำระเงินในราคา ฿79.00',
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPackageCard(
                        title: 'ราย 3 เดือน',
                        price: '฿229.00/3เดือน',
                        subtitles: ['ประหยัดลง 8 บาท เมื่อเทียบกับรายเดือน'],
                        buttonText: 'ชำระเงินในราคา ฿229.00',
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPackageCard(
                        title: 'รายปี',
                        price: '฿879.00/ปี',
                        subtitles: [
                          'ประหยัดลง 69 บาท เมื่อเทียบกับรายเดือน',
                          'ประหยัดลง 37 บาท เมื่อเทียบกับราย3เดือน',
                        ],
                        buttonText: 'ชำระเงินในราคา ฿879.00',
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String price,
    List<String>? subtitles,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (subtitles != null && subtitles.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...subtitles.map(
              (text) => Text(
                text,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF2A5DB9,
                ), // Blue color from screenshot
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int count) {
    return Row(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
