import 'dart:convert';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_application_1/models/post_model.dart';
import 'package:http/http.dart' as http;

class PostsService {
  static Future<List<PostModel>> getPosts() async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    final String? currentUserId = storage.read('uid');

    try {
      final url = Uri.parse('$apiEndpoint/posts');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['code'] == 200) {
          final List<dynamic> postsJson = data['data']['posts'];

          try {
            final posts = postsJson
                .map(
                  (json) =>
                      PostModel.fromJson(json, currentUserId: currentUserId),
                )
                .toList();
            return posts;
          } catch (e) {
            debugPrint('Error mapping posts: $e');
            return [];
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting posts: $e');
      return [];
    }
  }

  static Future<bool> likePost(String postId) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    try {
      final url = Uri.parse('$apiEndpoint/posts/$postId/like');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204 || response.statusCode == 409) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error liking post: $e');
      return false;
    }
  }

  static Future<bool> unlikePost(String postId) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    try {
      final url = Uri.parse('$apiEndpoint/posts/$postId/like');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error unliking post: $e');
      return false;
    }
  }

  static Future<bool> createPost({
    required String content,
    String? sheetId,
  }) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    if (token == null) {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      return false;
    }
  }
}
