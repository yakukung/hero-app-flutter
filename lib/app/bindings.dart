import 'package:get/get.dart';
import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/core/controllers/admin_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AppController>(AppController(), permanent: true);
    Get.put<SheetsController>(SheetsController(), permanent: true);
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<AdminController>(AdminController(), permanent: true);
  }
}
