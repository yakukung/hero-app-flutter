import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hero_app_flutter/features/auth/intro_page.dart';
import 'package:hero_app_flutter/features/user/profile/controllers/profile_page_controller.dart';
import 'package:hero_app_flutter/features/user/profile/edit_profile_page.dart';
import 'package:hero_app_flutter/features/user/profile/user_sheets_page.dart';
import 'package:hero_app_flutter/features/user/profile/widgets/profile_action_grid.dart';
import 'package:hero_app_flutter/features/user/profile/widgets/profile_logout_button.dart';
import 'package:hero_app_flutter/features/user/profile/widgets/profile_subscription_sheet.dart';
import 'package:hero_app_flutter/features/user/profile/widgets/profile_summary_section.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:hero_app_flutter/shared/widgets/upload/upload_progress_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.controller});

  final ProfilePageController? controller;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfilePageController _controller;
  final ImagePicker _picker = ImagePicker();

  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ProfilePageController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) {
      return;
    }

    UploadProgressDialog.show(stateNotifier: _controller.uploadStateNotifier);
    await _controller.uploadProfileImage(File(image.path));
  }

  Future<void> _showLogoutConfirmation() async {
    await showCustomDialog(
      title: 'ยืนยันออกจากระบบ',
      message: 'คุณต้องการออกจากระบบใช่ไหม?',
      isConfirm: true,
      onOk: () async {
        await _controller.logout();
        Get.offAll(() => const IntroPage());
      },
    );
  }

  void _openUserSheets() {
    final validationMessage = _controller.validateUserSheetsAccess();
    if (validationMessage != null) {
      showCustomDialog(title: 'ไม่พบข้อมูลผู้ใช้', message: validationMessage);
      return;
    }

    Get.to(() => UserSheetsPage(userId: _controller.appController.uid));
  }

  void _showSubscriptionPackages() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileSubscriptionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appController = _controller.appController;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => RefreshIndicator(
          onRefresh: _controller.refresh,
          child: ListView(
            children: [
              const SizedBox(height: 32),
              ProfileSummarySection(
                profileImage: appController.profileImage,
                username: appController.username,
                email: appController.email,
                followersCount: appController.followersCount,
                followingsCount: appController.followingsCount,
                onEditAvatar: _pickProfileImage,
              ),
              const SizedBox(height: 24),
              ProfileActionGrid(
                wallet: appController.wallet,
                onEditProfile: () {
                  Get.to(() => const EditProfilePage());
                },
                onShowSubscriptions: _showSubscriptionPackages,
                onOpenUserSheets: _openUserSheets,
              ),
              const SizedBox(height: 10),
              ProfileLogoutButton(onPressed: _showLogoutConfirmation),
            ],
          ),
        ),
      ),
    );
  }
}
