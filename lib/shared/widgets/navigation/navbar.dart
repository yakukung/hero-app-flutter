import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/constants/app_assets.dart';
import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/core/session/app_session_coordinator.dart';
import 'package:hero_app_flutter/features/auth/intro_page.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';

class NavbarUser extends GetView<AppController> implements PreferredSizeWidget {
  const NavbarUser({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final NavigationController navCtrl = Get.find<NavigationController>();
    return Obx(() {
      return AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.dashboard_rounded,
                color: Colors.black87,
                size: 32,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'ยินดีต้อนรับ',
                  style: TextStyle(
                    color: Color(0xFFB2B2B2),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  controller.username,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            PopupMenuButton<String>(
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              elevation: 8,
              onSelected: (value) {
                if (value == 'profile') {
                  navCtrl.changeIndex(4);
                } else if (value == 'logout') {
                  _showLogoutConfirmation();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: Colors.grey[700],
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'หน้าโปรไฟล์',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.red[400],
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'ออกจากระบบ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.red[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: controller.profileImage.isNotEmpty
                      ? Image.network(
                          controller.profileImage,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          AppAssets.defaultAvatar,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _showLogoutConfirmation() async {
    await showCustomDialog(
      title: 'ยืนยันออกจากระบบ',
      message: 'คุณต้องการออกจากระบบใช่ไหม?',
      isConfirm: true,
      isDanger: true,
      okButtonLabel: 'ออกจากระบบ',
      onOk: () async {
        final sessionCoordinator = AppSessionCoordinator();
        await sessionCoordinator.logout();
        Get.offAll(() => const IntroPage());
      },
    );
  }
}

