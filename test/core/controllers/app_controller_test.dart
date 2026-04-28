import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../support/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageKey = 'app_controller_test';
  late GetStorage storage;
  late AppController controller;

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    await GetStorage.init(storageKey);
  });

  setUp(() async {
    storage = GetStorage(storageKey);
    await storage.erase();
    controller = AppController(storage: storage);
  });

  test('updateFromMap stores user and access tokens', () {
    controller.updateFromMap({
      'id': 'user-1',
      'username': 'hero',
      'email': 'hero@example.com',
      'profile_image': '/uploads/avatar.png',
      'auth_provider': 'EMAIL_PASSWORD',
      'role_name': 'ADMIN',
      'role_id': 'role-admin',
      'visible_flag': true,
      'status_flag': 'ACTIVE',
      'point': 12,
      'created_at': '2026-01-01T00:00:00.000Z',
      'created_by': 'SYSTEM',
      'tokens': {'access_token': 'token-123', 'refresh_token': 'refresh-123'},
    });

    expect(controller.uid, 'user-1');
    expect(controller.username, 'hero');
    expect(controller.email, 'hero@example.com');
    expect(controller.user.value?.profileImage, '/uploads/avatar.png');
    expect(controller.user.value?.roleName, 'ADMIN');
    expect(storage.read('uid'), 'user-1');
    expect(storage.read('token'), 'token-123');
    expect(storage.read('refresh_token'), 'refresh-123');
  });

  test('clearUserData resets in-memory and persisted session', () async {
    controller.updateFromMap({
      'id': 'user-2',
      'username': 'member',
      'email': 'member@example.com',
      'auth_provider': 'GOOGLE',
      'role_name': 'USER',
      'role_id': 'role-user',
      'visible_flag': true,
      'status_flag': 'ACTIVE',
      'point': 0,
      'created_at': '2026-01-01T00:00:00.000Z',
      'created_by': 'SYSTEM',
      'tokens': {'access_token': 'token-xyz'},
    });

    controller.clearUserData();

    expect(controller.user.value, isNull);
    expect(controller.uid, isEmpty);
    expect(controller.errorMessage.value, isEmpty);
    expect(storage.read('uid'), isNull);
    expect(storage.read('token'), isNull);
  });
}
