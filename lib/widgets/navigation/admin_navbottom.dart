import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/navigation_service.dart';
import 'package:get/get.dart';

class AdminNavBottom extends StatelessWidget {
  const AdminNavBottom({super.key});

  void _navigateToPage(int index) {
    final navService = Get.find<NavigationService>();
    navService.changeIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final navService = Get.find<NavigationService>();
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(42),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              color: Colors.white.withOpacity(0.3),
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
                  unselectedItemColor: Colors.black.withOpacity(0.4),
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
