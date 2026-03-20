import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AdminService extends ChangeNotifier {
  List<UserModel> _users = [];
  int _totalItems = 0;
  bool _isLoading = false;
  String _errorMessage = '';

  List<UserModel> get users => _users;
  int get totalItems => _totalItems;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final GetStorage _storage = GetStorage();

  Future<void> fetchUsers() async {
    final String? token = _storage.read('token');

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

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

        _totalItems = data['total_items'] ?? 0;
        final List<dynamic> usersJson = data['users'] ?? [];

        _users = usersJson.map((json) => UserModel.fromJson(json)).toList();
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to fetch users: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
      _errorMessage = 'Error fetching users: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
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
      return null;
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

      if (response.statusCode == 204) {
        return true;
      }
      return false;
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

      if (response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating username by admin: $e');
      return false;
    }
  }
}
