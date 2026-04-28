import 'dart:convert';

import 'package:hero_app_flutter/core/config/api_connect.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({SessionStore? sessionStore}) : _sessionStore = sessionStore;

  SessionStore? _sessionStore;

  Uri buildUri(String path) => Uri.parse('$apiEndpoint$path');

  String? resolveToken(String? token, {bool useSessionToken = true}) {
    if (token != null && token.isNotEmpty) {
      return token;
    }

    if (!useSessionToken) {
      return null;
    }

    final storedToken = _getSessionStore().token;
    if (storedToken.isEmpty) {
      return null;
    }

    return storedToken;
  }

  Map<String, String> buildHeaders({
    String? token,
    String? contentType = 'application/json',
    bool disableCache = false,
    bool useSessionToken = true,
    Map<String, String>? extraHeaders,
  }) {
    final resolvedToken = resolveToken(token, useSessionToken: useSessionToken);

    return {
      if (resolvedToken != null && resolvedToken.isNotEmpty)
        'Authorization': 'Bearer $resolvedToken',
      ...?contentType == null ? null : {'Content-Type': contentType},
      ...?disableCache ? const {'Cache-Control': 'no-cache'} : null,
      ...?extraHeaders,
    };
  }

  SessionStore _getSessionStore() => _sessionStore ??= SessionStore();

  Future<T> withClient<T>(
    Future<T> Function(http.Client client) action, {
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

  Future<http.Response> get({
    required String path,
    String? token,
    bool includeJsonContentType = true,
    bool disableCache = false,
    bool useSessionToken = true,
    Map<String, String>? headers,
    http.Client? client,
  }) {
    return withClient(
      (httpClient) => httpClient.get(
        buildUri(path),
        headers: buildHeaders(
          token: token,
          contentType: includeJsonContentType ? 'application/json' : null,
          disableCache: disableCache,
          useSessionToken: useSessionToken,
          extraHeaders: headers,
        ),
      ),
      client: client,
    );
  }

  Future<http.Response> post({
    required String path,
    String? token,
    Object? body,
    bool includeJsonContentType = true,
    bool disableCache = false,
    bool useSessionToken = true,
    Map<String, String>? headers,
    http.Client? client,
  }) {
    return withClient(
      (httpClient) => httpClient.post(
        buildUri(path),
        headers: buildHeaders(
          token: token,
          contentType: includeJsonContentType ? 'application/json' : null,
          disableCache: disableCache,
          useSessionToken: useSessionToken,
          extraHeaders: headers,
        ),
        body: body,
      ),
      client: client,
    );
  }

  Future<http.Response> patch({
    required String path,
    String? token,
    Object? body,
    bool includeJsonContentType = true,
    bool useSessionToken = true,
    Map<String, String>? headers,
    http.Client? client,
  }) {
    return withClient(
      (httpClient) => httpClient.patch(
        buildUri(path),
        headers: buildHeaders(
          token: token,
          contentType: includeJsonContentType ? 'application/json' : null,
          useSessionToken: useSessionToken,
          extraHeaders: headers,
        ),
        body: body,
      ),
      client: client,
    );
  }

  Future<http.Response> delete({
    required String path,
    String? token,
    Object? body,
    bool includeJsonContentType = true,
    bool useSessionToken = true,
    Map<String, String>? headers,
    http.Client? client,
  }) {
    return withClient(
      (httpClient) => httpClient.delete(
        buildUri(path),
        headers: buildHeaders(
          token: token,
          contentType: includeJsonContentType ? 'application/json' : null,
          useSessionToken: useSessionToken,
          extraHeaders: headers,
        ),
        body: body,
      ),
      client: client,
    );
  }

  Future<http.Response> postJson({
    required String path,
    required Map<String, dynamic> body,
    String? token,
    bool useSessionToken = true,
    Map<String, String>? headers,
    http.Client? client,
  }) {
    return post(
      path: path,
      token: token,
      body: jsonEncode(body),
      useSessionToken: useSessionToken,
      headers: headers,
      client: client,
    );
  }

  Future<http.Response> patchJson({
    required String path,
    required Map<String, dynamic> body,
    String? token,
    bool useSessionToken = true,
    Map<String, String>? headers,
    http.Client? client,
  }) {
    return patch(
      path: path,
      token: token,
      body: jsonEncode(body),
      useSessionToken: useSessionToken,
      headers: headers,
      client: client,
    );
  }
}
