import 'package:get/get.dart';
import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/services/notification_service.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupUnreadWatcher();
  }

  void _setupUnreadWatcher() {
    try {
      final sheetsCtrl = Get.find<SheetsController>();
      ever(sheetsCtrl.sheets, (_) => refreshUnreadCount());
    } catch (_) {}
  }

  void refreshUnreadCount() {
    final lastSeen = NotificationPreferences.lastSeenAt;
    if (lastSeen == null) {
      unreadCount.value = 0;
      return;
    }
    try {
      final sheets = Get.find<SheetsController>().sheets;
      unreadCount.value = NotificationService.countUnreadSheets(
        lastSeenAt: lastSeen,
        sheets: sheets,
      );
    } catch (_) {
      unreadCount.value = 0;
    }
  }

  void changeIndex(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
    }
  }

  void reset() {
    currentIndex.value = 0;
  }
}
