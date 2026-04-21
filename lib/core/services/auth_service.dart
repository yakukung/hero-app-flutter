import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter_application_1/core/network/api_client.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final ApiClient _api = ApiClient();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
    return _api.postJson(
      path: '/auth/loginByGoogle',
      body: {
        'provider_user_id': providerUserId,
        'provider_name': providerName,
        'provider_username': providerUsername,
        'provider_email': providerEmail,
        'provider_avatar': providerAvatar,
      },
      useSessionToken: false,
    );
  }

  static Future<http.Response> login({
    required String usernameOrEmail,
    required String password,
    http.Client? client,
  }) async {
    return _api.postJson(
      path: '/auth/login',
      body: {'usernameOrEmail': usernameOrEmail, 'password': password},
      useSessionToken: false,
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
    return _api.postJson(
      path: '/auth/register',
      body: {
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'base_url': apiEndpoint,
      },
      useSessionToken: false,
      client: client,
    );
  }

  static Future<http.Response> requestPasswordReset({
    required String email,
    http.Client? client,
  }) async {
    return _api.postJson(
      path: '/auth/forgot-password',
      body: {'email': email, 'base_url': apiEndpoint},
      useSessionToken: false,
      client: client,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
