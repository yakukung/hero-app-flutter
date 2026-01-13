import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class Appdata extends ChangeNotifier {
  String _username = '';
  String _uid = '';
  String _email = '';
  String _errorMessage = '';
  String _profileImage = '';
  late UserProfile user;

  GetStorage gs = GetStorage();

  String get uid => _uid;
  String get username => _username;
  String get email => _email;
  String get profileImage => _profileImage;

  set uid(String value) {
    _uid = value;
    notifyListeners();
  }

  set username(String value) {
    _username = value;
    notifyListeners();
  }

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  void setProfileImage(String url) {
    _profileImage = url;
    notifyListeners();
  }

  String get errorMessage => _errorMessage;

  Future<void> fetchUserData() async {
    GetStorage gs = GetStorage();
    final storedUid = gs.read('uid');
    _uid = storedUid == null ? '' : storedUid.toString();

    if (_uid.isNotEmpty) {
      final response = await http.get(Uri.parse('$apiEndpoint/users/$_uid'));

      if (response.statusCode == 200) {
        final userData = _extractUserMap(jsonDecode(response.body));
        if (userData.isNotEmpty) {
          _applyUserData(userData);
          _errorMessage = '';
        } else {
          _handleUserError('ไม่พบข้อมูลผู้ใช้ในข้อมูลตอบกลับ');
        }
      } else {
        _handleUserError('ไม่สามารถดึงข้อมูลผู้ใช้ได้: ${response.statusCode}');
      }
    } else {
      _clearUserData();
    }
  }

  void updateFromMap(Map<String, dynamic> userData) {
    _applyUserData(userData);
  }

  Map<String, dynamic> _extractUserMap(dynamic responseBody) {
    if (responseBody is Map<String, dynamic>) {
      if (responseBody['data'] is Map<String, dynamic>) {
        return responseBody['data'] as Map<String, dynamic>;
      }
      return responseBody;
    }
    return <String, dynamic>{};
  }

  void _applyUserData(Map<String, dynamic> userData) {
    _username = userData['username']?.toString() ?? _username;
    _uid = userData['uid']?.toString() ?? userData['id']?.toString() ?? _uid;
    _email = userData['email']?.toString() ?? _email;
    _profileImage =
        userData['profile_image']?.toString() ??
        userData['profileImage']?.toString() ??
        _profileImage;

    if (userData['tokens'] is Map<String, dynamic>) {
      final tokens = userData['tokens'] as Map<String, dynamic>;
      final accessToken = tokens['access_token']?.toString();
      final refreshToken = tokens['refresh_token']?.toString();
      final accessTokenExpiresAt = tokens['access_token_expires_at'];
      final refreshTokenExpiresAt = tokens['refresh_token_expires_at'];

      final gs = GetStorage();
      if (accessToken != null) {
        gs.write('token', accessToken);
      }
      if (refreshToken != null) {
        gs.write('refresh_token', refreshToken);
      }
      if (accessTokenExpiresAt != null) {
        gs.write('access_token_expires_at', accessTokenExpiresAt);
      }
      if (refreshTokenExpiresAt != null) {
        gs.write('refresh_token_expires_at', refreshTokenExpiresAt);
      }
    }
    notifyListeners();
  }

  void _handleUserError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearUserData() {
    _username = '';
    _uid = '';
    _email = '';
    _profileImage = '';
    _errorMessage = '';

    final gs = GetStorage();
    gs.remove('token');
    gs.remove('refresh_token');
    gs.remove('access_token_expires_at');
    gs.remove('refresh_token_expires_at');

    notifyListeners();
  }
}

class UserProfile {
  String uid = '';
}
