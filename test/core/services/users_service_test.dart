import 'dart:convert';

import 'package:flutter_application_1/core/services/users_service.dart';
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

  group('UsersService API methods', () {
    test('updateEmail sends PATCH payload to users/update-email', () async {
      final client = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/users/update-email');
        expect(request.headers['authorization'], 'Bearer token-123');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['uid'], 'user-1');
        expect(body['email'], 'new@mail.com');
        expect(body['password'], 'pwd-123456');

        return http.Response('', 204);
      });

      final response = await UsersService.updateEmail(
        uid: 'user-1',
        email: 'new@mail.com',
        password: 'pwd-123456',
        token: 'token-123',
        client: client,
      );

      expect(response.statusCode, 204);
    });

    test('updatePassword sends old/new password fields', () async {
      final client = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/users/update-password');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['uid'], 'user-2');
        expect(body['old_password'], 'old-pass');
        expect(body['new_password'], 'new-pass');

        return http.Response('{"error":{"message":{"th":"failed"}}}', 400);
      });

      final response = await UsersService.updatePassword(
        uid: 'user-2',
        oldPassword: 'old-pass',
        newPassword: 'new-pass',
        token: 'token-456',
        client: client,
      );

      expect(response.statusCode, 400);
    });
  });
}
