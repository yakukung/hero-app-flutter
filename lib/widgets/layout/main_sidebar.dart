import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/intro.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/widgets/layout/sidebar_menu_item.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = Get.find<NavigationService>();

    return Drawer(
      backgroundColor: Color(0xFFF5F6FA),
      child: SafeArea(
        child: Consumer<Appdata>(
          builder: (context, appData, child) {
            return Column(
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: appData.profileImage.isNotEmpty
                                  ? Image.network(
                                      appData.profileImage,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/default/avatar.png',
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appData.username.isNotEmpty
                                ? appData.username
                                : 'ชื่อผู้ใช้',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appData.email.isNotEmpty
                                ? appData.email
                                : 'example@email.com',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(90),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                // Search Box
                if (appData.user?.roleName != 'ADMIN')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.09),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        style: const TextStyle(
                          fontFamily: 'SukhumvitSet',
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ค้นหาชีต',
                          hintStyle: const TextStyle(
                            fontFamily: 'SukhumvitSet',
                            color: Color(0xFFB0B0B0),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF2A5DB9),
                            size: 26,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Menu List
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      if (appData.user?.roleName == 'ADMIN') ...[
                        SidebarMenuItem(
                          icon: Icons.people_alt_rounded,
                          label: 'ชุมชน',
                          selected: navigationService.currentIndex.value == 0,
                          onTap: () {
                            navigationService.changeIndex(0);
                            Get.back();
                          },
                        ),
                        SidebarMenuItem(
                          icon: Icons.report_problem_rounded,
                          label: 'รายงานแจ้งปัญหา',
                          selected: navigationService.currentIndex.value == 1,
                          onTap: () {
                            navigationService.changeIndex(1);
                            Get.back();
                          },
                        ),
                        SidebarMenuItem(
                          icon: Icons.supervisor_account_rounded,
                          label: 'จัดการผู้ใช้',
                          selected: navigationService.currentIndex.value == 2,
                          onTap: () {
                            navigationService.changeIndex(2);
                            Get.back();
                          },
                        ),
                      ] else ...[
                        SidebarMenuItem(
                          icon: Icons.home_rounded,
                          label: 'หน้าหลัก',
                          selected: navigationService.currentIndex.value == 0,
                          onTap: () {
                            navigationService.changeIndex(0);
                            Get.back();
                          },
                        ),
                        SidebarMenuItem(
                          icon: Icons.star_rounded,
                          label: 'ชีตโปรด',
                          selected: navigationService.currentIndex.value == 1,
                          onTap: () {
                            navigationService.changeIndex(1);
                            Get.back();
                          },
                        ),
                        SidebarMenuItem(
                          icon: Icons.upload_rounded,
                          label: 'อัปโหลดชีต',
                          selected: navigationService.currentIndex.value == 2,
                          onTap: () {
                            navigationService.changeIndex(2);
                            Get.back();
                          },
                        ),
                        SidebarMenuItem(
                          icon: Icons.people_alt_rounded,
                          label: 'คอมมูนิตี้',
                          selected: navigationService.currentIndex.value == 3,
                          badge: 6,
                          onTap: () {
                            navigationService.changeIndex(3);
                            Get.back();
                          },
                        ),
                        SidebarMenuItem(
                          icon: Icons.person_rounded,
                          label: 'โปรไฟล์ของฉัน',
                          selected: navigationService.currentIndex.value == 4,
                          onTap: () {
                            navigationService.changeIndex(4);
                            Get.back();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                // Logout
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16,
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF92A47),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'ออกจากระบบ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _showLogoutConfirmation(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: const SizedBox(),
            ),
          ),
          Container(
            height: 350,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 60),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const Text(
                  'ยืนยันออกจากระบบ',
                  style: TextStyle(
                    fontFamily: 'SukhumvitSet',
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'คุณต้องการออกจากระบบใช่ไหม?',
                  style: TextStyle(
                    fontFamily: 'SukhumvitSet',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF6E6E6E),
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'ยกเลิก',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        GetStorage().erase();
                        Get.offAll(() => IntroPage());
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'ออกจากระบบ',
                          style: TextStyle(
                            fontFamily: 'SukhumvitSet',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFF92A47),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
