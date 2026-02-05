import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'pages/intro.dart';
import 'pages/user/community.dart';
import 'pages/user/favorite.dart';
import 'pages/user/home.dart';
import 'pages/user/profile.dart';
import 'pages/user/upload.dart';
import 'services/app_data.dart';
import 'services/navigation_service.dart';
import 'services/sheets.service.dart';
import 'widgets/layout/main_sidebar.dart';
import 'widgets/navigation/navbar.dart';
import 'widgets/navigation/navbottom.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Appdata()),
        ChangeNotifierProvider(create: (_) => SheetData()),
      ],
      child: GetMaterialApp(
        title: 'heroapp Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          fontFamily: 'SukhumvitSet',
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
    return appData.uid.isEmpty ? const IntroPage() : const MainPage();
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
