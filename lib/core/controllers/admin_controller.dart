import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter_application_1/core/models/user_model.dart';

class AdminController extends GetxController {
  AdminController({GetStorage? storage}) : _storage = storage ?? GetStorage();

  var users = <UserModel>[].obs;
  var totalItems = 0.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final GetStorage _storage;

  Future<void> fetchUsers() async {
    final String? token = _storage.read('token');
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/users/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
    final String? token = _storage.read('token');
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
    final String? token = _storage.read('token');
    try {
      final response = await http.patch(
        Uri.parse('$apiEndpoint/users/update-status-flag/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status_flag': statusFlag}),
      );
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('Error updating user status: $e');
      return false;
    }
  }

  Future<bool> updateUserUsername(String userId, String newUsername) async {
    final String? token = _storage.read('token');
    try {
      final response = await http.patch(
        Uri.parse('$apiEndpoint/users/update-username'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'uid': userId, 'username': newUsername}),
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
