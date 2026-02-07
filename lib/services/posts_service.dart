import 'dart:convert';
import 'dart:developer';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class PostsService {
  static Future<bool> createPost({
    required String content,
    String? sheetId,
  }) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    if (token == null) {
      log('Error: No token found');
      return false;
    }

    try {
      final url = Uri.parse('$apiEndpoint/posts/create');
      final body = {
        'content': content,
        if (sheetId != null) 'sheet_id': sheetId,
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      log('Create post response status: ${response.statusCode}');
      log('Create post response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('Error creating post: $e');
      return false;
    }
  }
}
