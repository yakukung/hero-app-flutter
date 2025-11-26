import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:get/get.dart';

class NavBottom extends StatelessWidget {
  const NavBottom({super.key});

  void _navigateToPage(int index) {
    final navService = Get.find<NavigationService>();
    navService.changeIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final navService = Get.find<NavigationService>();
    return Obx(
      () => Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.7)),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: navService.currentIndex.value,
              onTap: _navigateToPage,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF2A5DB9),
              unselectedItemColor: const Color(0xFFBDBDBD),
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
                  icon: Icon(Icons.home, size: 32),
                  label: 'หน้าหลัก',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star_rate_rounded, size: 32),
                  label: 'ชีตโปรด',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: 50,
                    child: Icon(Icons.add_circle, size: 80),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_rounded, size: 32),
                  label: 'คอมมูนิตี้',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded, size: 32),
                  label: 'โปรไฟล์',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
