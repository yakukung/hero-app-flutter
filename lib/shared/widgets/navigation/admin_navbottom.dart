import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';

class AdminNavBottom extends StatelessWidget {
  const AdminNavBottom({super.key});

  void _navigateToPage(int index) {
    final navigationController = Get.find<NavigationController>();
    navigationController.changeIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(42),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 30),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.white.withValues(alpha: 0.3),
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  currentIndex: navigationController.currentIndex.value,
                  onTap: _navigateToPage,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: Colors.black.withValues(alpha: 0.4),
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedLabelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.people_alt_rounded, size: 32),
                      label: 'ชุมชน',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.report_problem_rounded, size: 32),
                      label: 'รายงาน',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.supervisor_account_rounded, size: 32),
                      label: 'ผู้ใช้',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
