import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/app/bindings.dart';
import 'package:hero_app_flutter/app/main_page.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/features/admin/admin_home_page.dart';
import 'package:hero_app_flutter/features/auth/intro_page.dart';
import 'package:hero_app_flutter/features/auth/login_page.dart';

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
        if (controller.wasSessionExpired.value) {
          return const LoginPage();
        }
        return const IntroPage();
      }
      if (roleName == 'ADMIN') {
        return const AdminHomePage();
      }
      return const MainPage();
    });
  }
}
