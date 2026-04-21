import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:flutter_application_1/core/session/session_store.dart';
import 'package:flutter_application_1/core/services/admin_service.dart';

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
    final String currentUserId = _sessionStore.uid;

    if (currentUserId.isEmpty || currentUserId != userId) {
      errorMessage.value =
          'แบ็กเอนด์ปัจจุบันรองรับการเปลี่ยนชื่อได้เฉพาะบัญชีของตนเอง';
      return false;
    }

    try {
      final response = await AdminService.updateUserUsername(
        userId: userId,
        username: newUsername,
        token: token.isNotEmpty ? token : null,
      );
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('Error updating username by admin: $e');
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
