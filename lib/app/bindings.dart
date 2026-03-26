import 'package:get/get.dart';
import 'package:flutter_application_1/core/controllers/app_controller.dart';
import 'package:flutter_application_1/core/controllers/sheets_controller.dart';
import 'package:flutter_application_1/core/controllers/navigation_controller.dart';
import 'package:flutter_application_1/core/controllers/admin_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AppController>(AppController(), permanent: true);
    Get.put<SheetsController>(SheetsController(), permanent: true);
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<AdminController>(AdminController(), permanent: true);
  }
}
