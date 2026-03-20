import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/core/services/admin_service.dart';
import 'package:flutter_application_1/core/services/app_data.dart';
import 'package:flutter_application_1/core/services/navigation_service.dart';
import 'package:flutter_application_1/core/services/sheets.service.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Appdata()),
        ChangeNotifierProvider(create: (_) => SheetData()),
        ChangeNotifierProvider(create: (_) => AdminService()),
      ],
      child: GetMaterialApp(
        title: 'heroapp Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          fontFamily: AppFonts.sukhumvit,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Appdata>(context, listen: false).fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<Appdata>(context);

    if (appData.isLoading && appData.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (appData.uid.isEmpty) {
      return const IntroPage();
    }
    if (appData.user?.roleName == 'ADMIN') {
      return const AdminHomePage();
    }
    return const MainPage();
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationService navService = Get.find<NavigationService>();
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
        body: pages[navService.currentIndex.value],
        bottomNavigationBar: const NavBottom(),
      ),
    );
  }
}
