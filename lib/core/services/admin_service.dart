import 'dart:convert';

import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AdminService {
  static Uri _buildUri(String path) => Uri.parse('$apiEndpoint$path');

  static Map<String, String> _jsonHeaders({String? token}) {
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static String? _resolveToken(String? token) {
    if (token != null && token.isNotEmpty) return token;
    return GetStorage().read('token')?.toString();
  }

  static Future<http.Response> _withClient(
    Future<http.Response> Function(http.Client client) action, {
    http.Client? client,
  }) async {
    final http.Client httpClient = client ?? http.Client();
    try {
      return await action(httpClient);
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  static Future<http.Response> fetchUsers({
    String? token,
    http.Client? client,
  }) async {
    final String? resolvedToken = _resolveToken(token);
    return _withClient(
      (httpClient) => httpClient.get(
        _buildUri('/users/'),
        headers: _jsonHeaders(token: resolvedToken),
      ),
      client: client,
    );
  }

  static Future<http.Response> fetchUserById(
    String userId, {
    String? token,
    http.Client? client,
  }) async {
    final String? resolvedToken = _resolveToken(token);
    return _withClient(
      (httpClient) => httpClient.get(
        _buildUri('/users/$userId'),
        headers: _jsonHeaders(token: resolvedToken),
      ),
      client: client,
    );
  }

  static Future<http.Response> updateUserStatus({
    required String userId,
    required String statusFlag,
    String? token,
    http.Client? client,
  }) async {
    final String? resolvedToken = _resolveToken(token);
    return _withClient(
      (httpClient) => httpClient.patch(
        _buildUri('/users/update-status-flag/$userId'),
        headers: _jsonHeaders(token: resolvedToken),
        body: jsonEncode({'status_flag': statusFlag}),
      ),
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

    final String? resolvedToken = _resolveToken(token);
    return _withClient(
      (httpClient) => httpClient.patch(
        _buildUri('/users/update-username'),
        headers: _jsonHeaders(token: resolvedToken),
        body: jsonEncode({'username': username}),
      ),
      client: client,
    );
  }
}
