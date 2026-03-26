import 'package:get/get.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;

  void changeIndex(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
    }
  }

  void reset() {
    currentIndex.value = 0;
  }
}
