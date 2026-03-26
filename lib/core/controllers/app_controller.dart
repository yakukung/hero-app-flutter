import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:http/http.dart' as http;

class AppController extends GetxController {
  AppController({GetStorage? storage}) : _storage = storage ?? GetStorage();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxBool isReady = false.obs;
  final RxString errorMessage = ''.obs;

  final GetStorage _storage;

  String get uid => user.value?.id ?? '';
  String get username => user.value?.username ?? '';
  String get email => user.value?.email ?? '';
  String get provider => user.value?.authProvider.name ?? 'EMAIL';
  double get wallet => user.value?.wallet ?? 0.0;
  int get followersCount => user.value?.followersCount ?? 0;
  int get followingsCount => user.value?.followingsCount ?? 0;
  String get profileImage {
    final String imagePath = user.value?.profileImage ?? '';
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return Uri.parse(apiEndpoint).resolve(imagePath).toString();
  }

  bool get hasUser => user.value != null;

  @override
  void onInit() {
    super.onInit();
    _hydrateSession();
  }

  Future<void> _hydrateSession() async {
    final String storedUid = _storage.read('uid')?.toString() ?? '';
    if (storedUid.isEmpty) {
      isReady.value = true;
      return;
    }

    await fetchUserData();
    isReady.value = true;
  }

  void setProfileImage(String url) {
    if (user.value == null) return;
    user.value = user.value!.copyWith(profileImage: url);
  }

  Future<void> fetchUserData() async {
    final String? storedUid = _storage.read('uid')?.toString();
    isLoading.value = true;

    try {
      if (storedUid != null && storedUid.isNotEmpty) {
        final String? token = _storage.read('token')?.toString();
        final response = await http.get(
          Uri.parse('$apiEndpoint/users/$storedUid'),
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final userData = _extractUserMap(jsonDecode(response.body));
          if (userData.isNotEmpty) {
            _applyUserData(userData);
            errorMessage.value = '';
          } else {
            _handleUserError('ไม่พบข้อมูลผู้ใช้ในข้อมูลตอบกลับ');
          }
        } else {
          _handleUserError(
            'ไม่สามารถดึงข้อมูลผู้ใช้ได้: ${response.statusCode}',
          );
          if (response.statusCode == 401 ||
              response.statusCode == 403 ||
              response.statusCode == 404) {
            clearUserData();
          }
        }
      } else {
        clearUserData();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      _handleUserError('เกิดข้อผิดพลาดในการดึงข้อมูล: $e');
    } finally {
      isLoading.value = false;
      isReady.value = true;
    }
  }

  void updateFromMap(Map<String, dynamic> userData) {
    _applyUserData(userData);
    isReady.value = true;
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
      final newUser = UserModel.fromJson(userData);
      String? resolvedRole = newUser.roleName;

      if (resolvedRole == null || resolvedRole.isEmpty) {
        if (user.value?.roleName != null && user.value!.roleName!.isNotEmpty) {
          resolvedRole = user.value!.roleName;
        } else {
          resolvedRole = _storage.read('role_name')?.toString();
        }
      }

      if (resolvedRole != null && resolvedRole.isNotEmpty) {
        user.value = newUser.copyWith(roleName: resolvedRole);
        _storage.write('role_name', resolvedRole);
      } else {
        user.value = newUser;
      }

      _storage.write('uid', user.value!.id);

      if (userData['tokens'] is Map<String, dynamic>) {
        final tokens = userData['tokens'] as Map<String, dynamic>;
        final accessToken = tokens['access_token']?.toString();
        final refreshToken = tokens['refresh_token']?.toString();
        final accessTokenExpiresAt = tokens['access_token_expires_at'];
        final refreshTokenExpiresAt = tokens['refresh_token_expires_at'];

        if (accessToken != null) {
          _storage.write('token', accessToken);
        }
        if (refreshToken != null) {
          _storage.write('refresh_token', refreshToken);
        }
        if (accessTokenExpiresAt != null) {
          _storage.write('access_token_expires_at', accessTokenExpiresAt);
        }
        if (refreshTokenExpiresAt != null) {
          _storage.write('refresh_token_expires_at', refreshTokenExpiresAt);
        }
      }
    } catch (e) {
      debugPrint('Error parsing user data: $e');
      _handleUserError('Error parsing user data: $e');
    }
  }

  void _handleUserError(String message) {
    errorMessage.value = message;
  }

  void clearUserData() {
    user.value = null;
    errorMessage.value = '';

    _storage.remove('token');
    _storage.remove('refresh_token');
    _storage.remove('access_token_expires_at');
    _storage.remove('refresh_token_expires_at');
    _storage.remove('uid');
    _storage.remove('role_name');
    isReady.value = true;
  }
}
