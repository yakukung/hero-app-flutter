import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/constants/app_assets.dart';
import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';

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
            GestureDetector(
              onTap: () {
                navCtrl.changeIndex(4);
              },
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
}
