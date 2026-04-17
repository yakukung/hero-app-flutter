import 'dart:convert';

import 'package:flutter_application_1/core/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(
      envString: '''
HTTP_SCHEME=http
API_HOST=localhost
API_PORT=3000
''',
    );
  });

  group('AuthService API methods', () {
    test('login posts credentials to auth/login', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/auth/login');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['usernameOrEmail'], 'hero@example.com');
        expect(body['password'], 'secret-123');

        return http.Response('{"code":200}', 200);
      });

      final response = await AuthService.login(
        usernameOrEmail: 'hero@example.com',
        password: 'secret-123',
        client: client,
      );

      expect(response.statusCode, 200);
    });

    test('requestPasswordReset bubbles network exception', () async {
      final client = MockClient((request) async {
        throw Exception('network error');
      });

      expect(
        () => AuthService.requestPasswordReset(
          email: 'hero@example.com',
          client: client,
        ),
        throwsException,
      );
    });
  });
}
