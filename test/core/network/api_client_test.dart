import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../support/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    dotenv.loadFromString(
      envString: '''
HTTP_SCHEME=http
API_HOST=localhost
API_PORT=3000
''',
    );
    await GetStorage.init();
  });

  tearDown(() {
    ApiClient.configureSessionExpiredHandler(null);
  });

  test(
    'calls session expired handler when API returns 401 with token',
    () async {
      const storageKey = 'api_client_unauthorized_test';
      await GetStorage.init(storageKey);
      final storage = GetStorage(storageKey);
      await storage.erase();
      final sessionStore = SessionStore(storage: storage)
        ..writeUid('user-1')
        ..write(SessionStore.tokenKey, 'token-123');
      var handlerCalls = 0;

      ApiClient.configureSessionExpiredHandler(() {
        handlerCalls++;
        sessionStore.clearSession();
      });

      final client = MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer token-123');
        return http.Response('{"message":"expired"}', 401);
      });

      final response = await ApiClient(
        sessionStore: sessionStore,
      ).get(path: '/protected', client: client);

      expect(response.statusCode, 401);
      expect(handlerCalls, 1);
      expect(sessionStore.uid, isEmpty);
      expect(sessionStore.token, isEmpty);
    },
  );

  test(
    'short-circuits request when stored access token is already expired',
    () async {
      const storageKey = 'api_client_expired_token_test';
      await GetStorage.init(storageKey);
      final storage = GetStorage(storageKey);
      await storage.erase();
      final sessionStore = SessionStore(storage: storage)
        ..writeUid('user-1')
        ..persistTokens({
          'access_token': 'token-123',
          'access_token_expires_at': DateTime.now()
              .subtract(const Duration(minutes: 1))
              .toUtc()
              .toIso8601String(),
        });
      var handlerCalls = 0;

      ApiClient.configureSessionExpiredHandler(() {
        handlerCalls++;
        sessionStore.clearSession();
      });

      final client = MockClient((request) async {
        fail('Expired session should not hit the network');
      });

      final response = await ApiClient(
        sessionStore: sessionStore,
      ).get(path: '/protected', client: client);

      expect(response.statusCode, 401);
      expect(handlerCalls, 1);
      expect(sessionStore.uid, isEmpty);
      expect(sessionStore.token, isEmpty);
    },
  );
}
