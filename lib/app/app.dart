import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_application_1/app/bindings.dart';
import 'package:flutter_application_1/features/admin/home.dart';
import 'package:flutter_application_1/features/auth/intro.dart';
import 'package:flutter_application_1/features/user/community.dart';
import 'package:flutter_application_1/features/user/favorite.dart';
import 'package:flutter_application_1/features/user/home.dart';
import 'package:flutter_application_1/features/user/profile.dart';
import 'package:flutter_application_1/features/user/upload.dart';
import 'package:flutter_application_1/shared/widgets/layout/main_sidebar.dart';
import 'package:flutter_application_1/shared/widgets/navigation/navbar.dart';
import 'package:flutter_application_1/shared/widgets/navigation/navbottom.dart';
import 'package:flutter_application_1/constants/app_fonts.dart';
import 'package:flutter_application_1/core/controllers/app_controller.dart';
import 'package:flutter_application_1/core/controllers/navigation_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'heroapp Demo',
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
        drawer: const SideBar(),
        extendBody: true,
        body: pages[controller.currentIndex.value],
        bottomNavigationBar: const NavBottom(),
      ),
    );
  }
}
