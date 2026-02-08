import 'dart:convert';
import 'dart:developer';
import 'package:flutter_application_1/config/api_connect.dart';
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

      log('Get posts response status: ${response.statusCode}');
      // log('Get posts response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['code'] == 200) {
          final List<dynamic> postsJson = data['data']['posts'];
          if (postsJson.isNotEmpty) {
            log('First post JSON: ${postsJson.first}');
          }

          try {
            final posts = postsJson
                .map(
                  (json) =>
                      PostModel.fromJson(json, currentUserId: currentUserId),
                )
                .toList();
            log('Successfully mapped ${posts.length} posts');
            return posts;
          } catch (e) {
            log('Error mapping posts: $e');
            return [];
          }
        }
      }
      return [];
    } catch (e) {
      log('Error getting posts: $e');
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

      log('Like post response: ${response.statusCode}');

      if (response.statusCode == 204 || response.statusCode == 409) {
        return true;
      }
      return false;
    } catch (e) {
      log('Error liking post: $e');
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

      log('Unlike post response: ${response.statusCode}');

      if (response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      log('Error unliking post: $e');
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
