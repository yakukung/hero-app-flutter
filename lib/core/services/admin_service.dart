import 'package:flutter_application_1/core/network/api_client.dart';
import 'package:http/http.dart' as http;

class AdminService {
  static final ApiClient _api = ApiClient();

  static Future<http.Response> fetchUsers({
    String? token,
    http.Client? client,
  }) async {
    return _api.get(path: '/users/', token: token, client: client);
  }

  static Future<http.Response> fetchUserById(
    String userId, {
    String? token,
    http.Client? client,
  }) async {
    return _api.get(path: '/users/$userId', token: token, client: client);
  }

  static Future<http.Response> updateUserStatus({
    required String userId,
    required String statusFlag,
    String? token,
    http.Client? client,
  }) async {
    return _api.patchJson(
      path: '/users/update-status-flag/$userId',
      body: {'status_flag': statusFlag},
      token: token,
      client: client,
    );
  }

  static Future<http.Response> updateUserUsername({
    required String userId,
    required String username,
    String? token,
    http.Client? client,
  }) async {
    if (userId.isEmpty) {
      return http.Response('{"message":"BAD_REQUEST"}', 400);
    }

    return _api.patchJson(
      path: '/users/update-username',
      body: {'username': username},
      token: token,
      client: client,
    );
  }
}
