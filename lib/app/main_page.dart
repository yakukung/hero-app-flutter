import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/features/user/community/community_page.dart';
import 'package:hero_app_flutter/features/user/favorite/favorite_page.dart';
import 'package:hero_app_flutter/features/user/home/home_page.dart';
import 'package:hero_app_flutter/features/user/profile/profile_page.dart';
import 'package:hero_app_flutter/features/user/upload/upload_page.dart';
import 'package:hero_app_flutter/shared/widgets/layout/main_sidebar.dart';
import 'package:hero_app_flutter/shared/widgets/navigation/navbottom.dart';
import 'package:hero_app_flutter/shared/widgets/navigation/navbar.dart';

class MainPage extends GetView<NavigationController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = const [
      HomePage(),
      FavoritePage(),
      UploadPage(),
      CommunityPage(),
      ProfilePage(),
    ];

    return Obx(
      () => Scaffold(
        appBar: const NavbarUser(),
        drawer: const MainSidebar(),
        extendBody: true,
        body: pages[controller.currentIndex.value],
        bottomNavigationBar: const NavBottom(),
      ),
    );
  }
}
