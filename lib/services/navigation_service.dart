import 'dart:developer';
import 'package:get/get.dart';

class NavigationService extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      log('เปลี่ยนไปหน้า index: $index');
    } else {
      log('กดซ้ำที่หน้าเดิม index: $index');
    }
  }
}
