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
        margin: const EdgeInsets.only(bottom: 30, left: 10, right: 10),
        decoration: BoxDecoration(
          // color removed, applied inside
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: Colors.white.withOpacity(0.1),
              padding: const EdgeInsets.all(6.0),
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
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
                          offset: const Offset(-4, -4),
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
