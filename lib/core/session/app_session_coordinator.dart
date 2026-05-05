import 'package:get/get.dart';

import 'package:hero_app_flutter/core/controllers/admin_controller.dart';
import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';

enum SessionDestination { intro, memberHome, adminHome }

class AppSessionCoordinator {
  AppSessionCoordinator({
    AppController? appController,
    SheetsController? sheetsController,
    AdminController? adminController,
    NavigationController? navigationController,
    SessionStore? sessionStore,
  }) : _appController = appController ?? Get.find<AppController>(),
       _sheetsController = sheetsController ?? Get.find<SheetsController>(),
       _adminController = adminController ?? Get.find<AdminController>(),
       _navigationController =
           navigationController ?? Get.find<NavigationController>(),
       _sessionStore = sessionStore ?? SessionStore();

  final AppController _appController;
  final SheetsController _sheetsController;
  final AdminController _adminController;
  final NavigationController _navigationController;
  final SessionStore _sessionStore;

  String get currentUserId => _appController.uid;

  bool get isAuthenticated =>
      _appController.hasUser && _appController.uid.isNotEmpty;

  Future<SessionDestination> completeLogin({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    _appController.updateFromMap({...userData, 'uid': uid});
    _sheetsController.resetState();
    _adminController.resetState();
    _navigationController.reset();

    final roleName = _appController.user.value?.roleName?.toUpperCase() ?? '';
    return roleName == 'ADMIN'
        ? SessionDestination.adminHome
        : SessionDestination.memberHome;
  }

  Future<SessionDestination> logout() async {
    await _sessionStore.eraseAll();
    _resetAppState(tokenExpired: false);
    return SessionDestination.intro;
  }

  Future<void> expireSession() async {
    _sessionStore.clearSession();
    _resetAppState(tokenExpired: true);
  }

  void _resetAppState({required bool tokenExpired}) {
    _appController.clearUserData(tokenExpired: tokenExpired);
    _sheetsController.resetState();
    _adminController.resetState();
    _navigationController.reset();
  }
}
