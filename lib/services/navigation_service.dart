import 'package:get/get.dart';

class NavigationService extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
    }
  }
}
