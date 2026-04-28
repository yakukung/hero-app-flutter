import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:hero_app_flutter/core/controllers/admin_controller.dart';
import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/session/app_session_coordinator.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';

import 'fake_path_provider.dart';

class TestAppDependencies {
  TestAppDependencies({
    required this.storage,
    required this.sessionStore,
    required this.appController,
    required this.sheetsController,
    required this.adminController,
    required this.navigationController,
    required this.sessionCoordinator,
  });

  final GetStorage storage;
  final SessionStore sessionStore;
  final AppController appController;
  final SheetsController sheetsController;
  final AdminController adminController;
  final NavigationController navigationController;
  final AppSessionCoordinator sessionCoordinator;
}

Future<TestAppDependencies> createTestAppDependencies(
  String storageKey, {
  Map<String, dynamic>? userData,
}) async {
  PathProviderPlatform.instance = FakePathProviderPlatform();
  dotenv.loadFromString(
    envString: 'HTTP_SCHEME=http\nAPI_HOST=localhost\nAPI_PORT=3000',
  );
  await GetStorage.init();
  await GetStorage.init(storageKey);

  final storage = GetStorage(storageKey);
  await storage.erase();

  final sessionStore = SessionStore(storage: storage);
  final appController = AppController(
    storage: storage,
    sessionStore: sessionStore,
  );
  final sheetsController = SheetsController(
    storage: storage,
    sessionStore: sessionStore,
  );
  final adminController = AdminController(
    storage: storage,
    sessionStore: sessionStore,
  );
  final navigationController = NavigationController();

  if (userData != null) {
    appController.updateFromMap(userData);
  }

  final sessionCoordinator = AppSessionCoordinator(
    appController: appController,
    sheetsController: sheetsController,
    adminController: adminController,
    navigationController: navigationController,
    sessionStore: sessionStore,
  );

  return TestAppDependencies(
    storage: storage,
    sessionStore: sessionStore,
    appController: appController,
    sheetsController: sheetsController,
    adminController: adminController,
    navigationController: navigationController,
    sessionCoordinator: sessionCoordinator,
  );
}
