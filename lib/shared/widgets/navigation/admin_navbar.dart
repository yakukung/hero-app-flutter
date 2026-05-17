import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_assets.dart';
import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:get/get.dart';

class AdminNavbar extends GetView<AppController>
    implements PreferredSizeWidget {
  const AdminNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppBar(
        backgroundColor: AdminColors.background,
        surfaceTintColor: AdminColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: AdminColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: AdminColors.border),
                ),
              ),
              icon: const Icon(
                Icons.dashboard_rounded,
                color: AdminColors.text,
                size: 28,
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
                    color: AdminColors.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'ผู้ดูแลระบบ ${controller.username}',
                  style: const TextStyle(
                    color: AdminColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            InkWell(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: CircleAvatar(
                radius: 21,
                backgroundColor: AdminColors.surface,
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
      ),
    );
  }
}
