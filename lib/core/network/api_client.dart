import 'dart:async';
import 'dart:convert';

import 'package:hero_app_flutter/core/config/api_connect.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:http/http.dart' as http;

typedef SessionExpiredHandler = FutureOr<void> Function();

class ApiClient {
  ApiClient({
    SessionStore? sessionStore,
    SessionExpiredHandler? onSessionExpired,
  }) : _sessionStore = sessionStore,
       _onSessionExpired = onSessionExpired;

  static SessionExpiredHandler? _sessionExpiredHandler;
  static bool _isHandlingSessionExpiration = false;

  static void configureSessionExpiredHandler(SessionExpiredHandler? handler) {
    _sessionExpiredHandler = handler;
  }

  SessionStore? _sessionStore;
  final SessionExpiredHandler? _onSessionExpired;

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

    return _buildHeadersForToken(
      resolvedToken: resolvedToken,
      contentType: contentType,
      disableCache: disableCache,
      extraHeaders: extraHeaders,
    );
  }

  Future<http.Response?> responseIfSessionExpired({
    String? token,
    bool useSessionToken = true,
  }) async {
    final resolvedToken = resolveToken(token, useSessionToken: useSessionToken);
    return _expiredSessionResponseForToken(resolvedToken);
  }

  Future<void> handleResponse(http.Response response, {String? token}) async {
    if (token == null || token.isEmpty) {
      return;
    }
    if (!_isUnauthorizedStatus(response.statusCode)) {
      return;
    }
    await _notifySessionExpired();
  }

  Map<String, String> _buildHeadersForToken({
    required String? resolvedToken,
    String? contentType = 'application/json',
    bool disableCache = false,
    Map<String, String>? extraHeaders,
  }) {
    return {
      if (resolvedToken != null && resolvedToken.isNotEmpty)
        'Authorization': 'Bearer $resolvedToken',
      ...?contentType == null ? null : {'Content-Type': contentType},
      ...?disableCache ? const {'Cache-Control': 'no-cache'} : null,
      ...?extraHeaders,
    };
  }

  SessionStore _getSessionStore() => _sessionStore ??= SessionStore();

  Future<http.Response?> _expiredSessionResponseForToken(
    String? resolvedToken,
  ) async {
    if (!_isExpiredSessionToken(resolvedToken)) {
      return null;
    }

    await _notifySessionExpired();
    return http.Response('{"message":"SESSION_EXPIRED"}', 401);
  }

  bool _isExpiredSessionToken(String? resolvedToken) {
    if (resolvedToken == null || resolvedToken.isEmpty) {
      return false;
    }
    if (_sessionStore == null) {
      return false;
    }

    final sessionStore = _sessionStore!;
    return resolvedToken == sessionStore.token &&
        sessionStore.isAccessTokenExpired;
  }

  bool _isUnauthorizedStatus(int statusCode) {
    return statusCode == 401 || statusCode == 403;
  }

  Future<void> _notifySessionExpired() async {
    final handler = _onSessionExpired ?? _sessionExpiredHandler;

    if (_isHandlingSessionExpiration) {
      return;
    }

    _isHandlingSessionExpiration = true;
    try {
      if (handler != null) {
        await handler();
      } else {
        _getSessionStore().clearSession();
      }
    } finally {
      _isHandlingSessionExpiration = false;
    }
  }

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
    return _send(
      token: token,
      contentType: includeJsonContentType ? 'application/json' : null,
      disableCache: disableCache,
      useSessionToken: useSessionToken,
      extraHeaders: headers,
      client: client,
      request: (httpClient, requestHeaders) =>
          httpClient.get(buildUri(path), headers: requestHeaders),
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
    return _send(
      token: token,
      contentType: includeJsonContentType ? 'application/json' : null,
      disableCache: disableCache,
      useSessionToken: useSessionToken,
      extraHeaders: headers,
      client: client,
      request: (httpClient, requestHeaders) =>
          httpClient.post(buildUri(path), headers: requestHeaders, body: body),
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
    return _send(
      token: token,
      contentType: includeJsonContentType ? 'application/json' : null,
      useSessionToken: useSessionToken,
      extraHeaders: headers,
      client: client,
      request: (httpClient, requestHeaders) =>
          httpClient.patch(buildUri(path), headers: requestHeaders, body: body),
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
    return _send(
      token: token,
      contentType: includeJsonContentType ? 'application/json' : null,
      useSessionToken: useSessionToken,
      extraHeaders: headers,
      client: client,
      request: (httpClient, requestHeaders) => httpClient.delete(
        buildUri(path),
        headers: requestHeaders,
        body: body,
      ),
    );
  }

  Future<http.Response> _send({
    required String? token,
    required bool useSessionToken,
    required String? contentType,
    bool disableCache = false,
    Map<String, String>? extraHeaders,
    http.Client? client,
    required Future<http.Response> Function(
      http.Client client,
      Map<String, String> headers,
    )
    request,
  }) async {
    final resolvedToken = resolveToken(token, useSessionToken: useSessionToken);
    final expiredResponse = await _expiredSessionResponseForToken(
      resolvedToken,
    );
    if (expiredResponse != null) {
      return expiredResponse;
    }

    return withClient((httpClient) async {
      final response = await request(
        httpClient,
        _buildHeadersForToken(
          resolvedToken: resolvedToken,
          contentType: contentType,
          disableCache: disableCache,
          extraHeaders: extraHeaders,
        ),
      );
      await handleResponse(response, token: resolvedToken);
      return response;
    }, client: client);
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
