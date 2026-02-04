import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'dart:convert';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:http/http.dart' as http;

class AuthService {
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
      log("Error during Google Sign-In: $e");
      return null;
    }
  }

  Future<http.Response> loginByGoogle({
    required String providerUserId,
    required String providerName,
    required String providerUsername,
    required String providerEmail,
    required String providerAvatar,
  }) async {
    final url = Uri.parse('$apiEndpoint/auth/loginByGoogle');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'provider_user_id': providerUserId,
        'provider_name': providerName,
        'provider_username': providerUsername,
        'provider_email': providerEmail,
        'provider_avatar': providerAvatar,
      }),
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
