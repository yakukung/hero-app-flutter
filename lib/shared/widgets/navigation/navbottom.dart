import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/core/controllers/navigation_controller.dart';

class NavBottom extends StatelessWidget {
  const NavBottom({super.key});

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
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home, size: 32),
                      label: 'หน้าหลัก',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.star_rate_rounded, size: 32),
                      label: 'ชีตโปรด',
                    ),
                    BottomNavigationBarItem(
                      icon: SizedBox(
                        height: 50,
                        child: Transform.translate(
                          offset: const Offset(-4, -3),
                          child: const Icon(Icons.add_circle, size: 80),
                        ),
                      ),
                      label: '',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.people_alt_rounded, size: 32),
                      label: 'คอมมูนิตี้',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.person_rounded, size: 32),
                      label: 'โปรไฟล์',
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
