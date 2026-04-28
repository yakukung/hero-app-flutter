import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/app/bindings.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/features/admin/admin_home_page.dart';
import 'package:hero_app_flutter/features/auth/intro_page.dart';
import 'package:hero_app_flutter/features/user/community/community_page.dart';
import 'package:hero_app_flutter/features/user/favorite/favorite_page.dart';
import 'package:hero_app_flutter/features/user/home/home_page.dart';
import 'package:hero_app_flutter/features/user/profile/profile_page.dart';
import 'package:hero_app_flutter/features/user/upload/upload_page.dart';
import 'package:hero_app_flutter/shared/widgets/layout/main_sidebar.dart';
import 'package:hero_app_flutter/shared/widgets/navigation/navbottom.dart';
import 'package:hero_app_flutter/shared/widgets/navigation/navbar.dart';

class HeroApp extends StatelessWidget {
  const HeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hero App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        fontFamily: AppFonts.sukhumvit,
      ),
      home: const AuthWrapper(),
      initialBinding: AppBindings(),
    );
  }
}

class AuthWrapper extends GetView<AppController> {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final roleName = controller.user.value?.roleName?.toUpperCase() ?? '';

      if (!controller.isReady.value ||
          (controller.isLoading.value && !controller.hasUser)) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (controller.uid.isEmpty || !controller.hasUser) {
        return const IntroPage();
      }
      if (roleName == 'ADMIN') {
        return const AdminHomePage();
      }
      return const MainPage();
    });
  }
}

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
