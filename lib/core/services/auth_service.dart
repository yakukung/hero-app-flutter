import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'dart:convert';
import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Uri _buildUri(String path) => Uri.parse('$apiEndpoint$path');

  static Future<http.Response> _postJson({
    required String path,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    http.Client? client,
  }) async {
    final http.Client httpClient = client ?? http.Client();
    try {
      return await httpClient.post(
        _buildUri(path),
        headers: {'Content-Type': 'application/json', ...?headers},
        body: jsonEncode(body),
      );
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      rethrow;
    }
  }

  Future<http.Response> loginByGoogle({
    required String providerUserId,
    required String providerName,
    required String providerUsername,
    required String providerEmail,
    required String providerAvatar,
  }) async {
    return await _postJson(
      path: '/auth/loginByGoogle',
      body: {
        'provider_user_id': providerUserId,
        'provider_name': providerName,
        'provider_username': providerUsername,
        'provider_email': providerEmail,
        'provider_avatar': providerAvatar,
      },
    );
  }

  static Future<http.Response> login({
    required String usernameOrEmail,
    required String password,
    http.Client? client,
  }) async {
    return _postJson(
      path: '/auth/login',
      body: {'usernameOrEmail': usernameOrEmail, 'password': password},
      client: client,
    );
  }

  static Future<http.Response> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    http.Client? client,
  }) async {
    return _postJson(
      path: '/auth/register',
      body: {
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'base_url': apiEndpoint,
      },
      client: client,
    );
  }

  static Future<http.Response> requestPasswordReset({
    required String email,
    http.Client? client,
  }) async {
    return _postJson(
      path: '/auth/forgot-password',
      body: {'email': email, 'base_url': apiEndpoint},
      client: client,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
