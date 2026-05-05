import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../support/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    await GetStorage.init();
  });

  test('detects expired access token from ISO timestamp', () async {
    const storageKey = 'session_store_iso_expiry_test';
    await GetStorage.init(storageKey);
    final storage = GetStorage(storageKey);
    await storage.erase();
    final sessionStore = SessionStore(storage: storage)
      ..write(
        SessionStore.accessTokenExpiresAtKey,
        DateTime.now().subtract(const Duration(seconds: 1)).toIso8601String(),
      );

    expect(sessionStore.isAccessTokenExpired, isTrue);
  });

  test('keeps future epoch access token active', () async {
    const storageKey = 'session_store_epoch_expiry_test';
    await GetStorage.init(storageKey);
    final storage = GetStorage(storageKey);
    await storage.erase();
    final sessionStore = SessionStore(storage: storage)
      ..write(
        SessionStore.accessTokenExpiresAtKey,
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
      );

    expect(sessionStore.isAccessTokenExpired, isFalse);
  });
}
