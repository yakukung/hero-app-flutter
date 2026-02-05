import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class Appdata extends ChangeNotifier {
  UserModel? _user;
  String _errorMessage = '';

  GetStorage gs = GetStorage();

  UserModel? get user => _user;
  String get uid => _user?.id ?? '';
  String get username => _user?.username ?? '';
  String get email => _user?.email ?? '';
  String get provider => _user?.authProvider.name ?? 'EMAIL';
  String get profileImage {
    if (_user?.profileImage == null || _user!.profileImage!.isEmpty) return '';
    if (_user!.profileImage!.startsWith('http')) return _user!.profileImage!;
    return Uri.parse(apiEndpoint).resolve(_user!.profileImage!).toString();
  }

  void setProfileImage(String url) {
    if (_user == null) return;
    _user = _user!.copyWith(profileImage: url);
    notifyListeners();
  }

  String get errorMessage => _errorMessage;

  Future<void> fetchUserData() async {
    GetStorage gs = GetStorage();
    final String? storedUid = gs.read('uid')?.toString();

    if (storedUid != null && storedUid.isNotEmpty) {
      try {
        final String? token = gs.read('token')?.toString();
        final response = await http.get(
          Uri.parse('$apiEndpoint/users/$storedUid'),
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final userData = _extractUserMap(jsonDecode(response.body));
          if (userData.isNotEmpty) {
            _applyUserData(userData);
            _errorMessage = '';
          } else {
            _handleUserError('ไม่พบข้อมูลผู้ใช้ในข้อมูลตอบกลับ');
          }
        } else {
          _handleUserError(
            'ไม่สามารถดึงข้อมูลผู้ใช้ได้: ${response.statusCode}',
          );
        }
      } catch (e) {
        _handleUserError('เกิดข้อผิดพลาดในการดึงข้อมูล: $e');
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
    try {
      _user = UserModel.fromJson(userData);

      final gs = GetStorage();
      gs.write('uid', _user!.id);

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
    } catch (e) {
      _handleUserError('Error parsing user data: $e');
    }
  }

  void _handleUserError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearUserData() {
    _user = null;
    _errorMessage = '';

    final gs = GetStorage();
    gs.remove('token');
    gs.remove('refresh_token');
    gs.remove('access_token_expires_at');
    gs.remove('refresh_token_expires_at');
    gs.remove('uid');

    notifyListeners();
  }
}

class UserProfile {
  String uid = '';
}
