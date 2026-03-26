import 'dart:convert';

import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class UsersService {
  static Future<bool> followUser(String userId) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    try {
      final url = Uri.parse('$apiEndpoint/users/$userId/follow');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 409) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error following user: $e');
      return false;
    }
  }

  static Future<bool> unfollowUser(String userId) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    try {
      final url = Uri.parse('$apiEndpoint/users/$userId/follow');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 404) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error unfollowing user: $e');
      return false;
    }
  }

  static Future<UserModel?> fetchUserById(String userId) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

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
}
