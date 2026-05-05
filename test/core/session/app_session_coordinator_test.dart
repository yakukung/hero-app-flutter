import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/session/app_session_coordinator.dart';

import '../../support/test_app_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('logout clears state and returns intro destination', () async {
    final dependencies = await createTestAppDependencies(
      'app_session_coordinator_test',
      userData: {
        'id': 'user-1',
        'username': 'hero',
        'email': 'hero@example.com',
        'auth_provider': 'EMAIL_PASSWORD',
        'role_name': 'USER',
        'role_id': 'role-user',
        'visible_flag': true,
        'status_flag': 'ACTIVE',
        'point': 0,
        'created_at': '2026-01-01T00:00:00.000Z',
        'created_by': 'SYSTEM',
        'tokens': {'access_token': 'token-123'},
      },
    );

    dependencies.sheetsController.sheets.addAll([]);
    final destination = await dependencies.sessionCoordinator.logout();

    expect(destination, SessionDestination.intro);
    expect(dependencies.appController.hasUser, isFalse);
    expect(dependencies.sessionStore.uid, isEmpty);
    expect(dependencies.sessionStore.token, isEmpty);
    expect(dependencies.navigationController.currentIndex.value, 0);
  });

  test('expireSession clears state and marks login destination', () async {
    final dependencies = await createTestAppDependencies(
      'app_session_coordinator_expire_session_test',
      userData: {
        'id': 'user-1',
        'username': 'hero',
        'email': 'hero@example.com',
        'auth_provider': 'EMAIL_PASSWORD',
        'role_name': 'USER',
        'role_id': 'role-user',
        'visible_flag': true,
        'status_flag': 'ACTIVE',
        'point': 0,
        'created_at': '2026-01-01T00:00:00.000Z',
        'created_by': 'SYSTEM',
        'tokens': {'access_token': 'token-123'},
      },
    );

    dependencies.navigationController.currentIndex.value = 3;

    await dependencies.sessionCoordinator.expireSession();

    expect(dependencies.appController.hasUser, isFalse);
    expect(dependencies.appController.wasSessionExpired.value, isTrue);
    expect(dependencies.sessionStore.uid, isEmpty);
    expect(dependencies.sessionStore.token, isEmpty);
    expect(dependencies.navigationController.currentIndex.value, 0);
  });
}
