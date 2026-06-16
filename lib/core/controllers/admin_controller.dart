import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hero_app_flutter/core/models/user_model.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/services/admin_service.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';

class AdminController extends GetxController {
  AdminController({GetStorage? storage, SessionStore? sessionStore})
    : _sessionStore = sessionStore ?? SessionStore(storage: storage);

  var users = <UserModel>[].obs;
  var totalItems = 0.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final SessionStore _sessionStore;

  Future<void> fetchUsers() async {
    final String token = _sessionStore.token;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await AdminService.fetchUsers(
        token: token.isNotEmpty ? token : null,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final Map<String, dynamic> data = jsonResponse['data'];
        _parseUsers(data);
        errorMessage.value = '';
      } else {
        errorMessage.value = 'Failed to fetch users: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
      errorMessage.value = 'Error fetching users: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserModel?> fetchUserById(String userId) async {
    final String token = _sessionStore.token;
    try {
      final response = await AdminService.fetchUserById(
        userId,
        token: token.isNotEmpty ? token : null,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return UserModel.fromJson(jsonResponse['data']);
      }
    } catch (e) {
      debugPrint('Error fetching user by id: $e');
    }
    return null;
  }

  Future<bool> updateUserStatus(String userId, String statusFlag) async {
    final String token = _sessionStore.token;
    try {
      final response = await AdminService.updateUserStatus(
        userId: userId,
        statusFlag: statusFlag,
        token: token.isNotEmpty ? token : null,
      );
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('Error updating user status: $e');
      return false;
    }
  }

  Future<bool> updateUserUsername(String userId, String newUsername) async {
    final String token = _sessionStore.token;
    try {
      final response = await AdminService.updateUserUsername(
        userId: userId,
        username: newUsername,
        token: token.isNotEmpty ? token : null,
      );
      if (response.statusCode == 204) return true;

      final String rawMessage = getErrorMessage(
        response,
        fallback: 'ไม่สามารถเปลี่ยนชื่อผู้ใช้ได้',
      );

      if (response.statusCode == 409 || rawMessage == 'CONFLICT') {
        errorMessage.value = 'ชื่อผู้ใช้นี้ถูกใช้งานแล้ว กรุณาใช้ชื่ออื่น';
      } else if (response.statusCode == 400 || rawMessage == 'BAD_REQUEST') {
        errorMessage.value = 'ข้อมูลชื่อผู้ใช้ไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
      } else {
        errorMessage.value = rawMessage;
      }

      return false;
    } catch (e) {
      debugPrint('Error updating username by admin: $e');
      errorMessage.value = 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้';
      return false;
    }
  }

  Future<bool> updateUserEmail(String userId, String newEmail) async {
    final String token = _sessionStore.token;
    try {
      final response = await AdminService.updateUserEmail(
        userId: userId,
        email: newEmail,
        token: token.isNotEmpty ? token : null,
      );
      if (response.statusCode == 204) return true;

      final String rawMessage = getErrorMessage(
        response,
        fallback: 'ไม่สามารถเปลี่ยนอีเมลได้',
      );

      if (response.statusCode == 409 || rawMessage == 'CONFLICT') {
        errorMessage.value = 'อีเมลนี้ถูกใช้งานแล้ว กรุณาใช้ที่อยู่อีเมลอื่น';
      } else if (response.statusCode == 400 || rawMessage == 'BAD_REQUEST') {
        errorMessage.value = 'รูปแบบอีเมลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
      } else {
        errorMessage.value = rawMessage;
      }

      return false;
    } catch (e) {
      debugPrint('Error updating email by admin: $e');
      errorMessage.value = 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้';
      return false;
    }
  }

  Future<bool> updateUserPassword(String userId, String newPassword) async {
    final String token = _sessionStore.token;
    try {
      final response = await AdminService.updateUserPassword(
        userId: userId,
        newPassword: newPassword,
        token: token.isNotEmpty ? token : null,
      );
      if (response.statusCode == 204) return true;

      final String rawMessage = getErrorMessage(
        response,
        fallback: 'ไม่สามารถเปลี่ยนรหัสผ่านได้',
      );

      if (response.statusCode == 400 || rawMessage == 'BAD_REQUEST') {
        errorMessage.value =
            'รูปแบบรหัสผ่านไม่ถูกต้อง กรุณาใช้รหัสผ่านที่แข็งแรง';
      } else {
        errorMessage.value = rawMessage;
      }

      return false;
    } catch (e) {
      debugPrint('Error updating password by admin: $e');
      errorMessage.value = 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้';
      return false;
    }
  }

  void resetState() {
    users.clear();
    totalItems.value = 0;
    isLoading.value = false;
    errorMessage.value = '';
  }

  void _parseUsers(Map<String, dynamic> data) {
    final List<dynamic> usersJson = data['users'] ?? [];
    users.assignAll(usersJson.map((json) => UserModel.fromJson(json)).toList());
    totalItems.value = data['total_items'] ?? 0;
  }
}
