import 'package:get/get.dart';
import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/core/controllers/admin_controller.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/app_session_coordinator.dart';
import 'package:hero_app_flutter/features/auth/login_page.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AppController>(AppController(), permanent: true);
    Get.put<SheetsController>(SheetsController(), permanent: true);
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<AdminController>(AdminController(), permanent: true);
    ApiClient.configureSessionExpiredHandler(() async {
      await AppSessionCoordinator().expireSession();
      if (Get.context != null) {
        Get.offAll(() => const LoginPage());
      }
    });
  }
}
