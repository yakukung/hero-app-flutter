import 'dart:convert';
import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_application_1/core/models/post_model.dart';
import 'package:http/http.dart' as http;

class ShareActionResult {
  final bool success;
  final bool alreadyShared;
  final int? shareCount;

  const ShareActionResult({
    required this.success,
    this.alreadyShared = false,
    this.shareCount,
  });
}

class PostsService {
  static Future<List<PostModel>> getPosts() async {
    final storage = GetStorage();
    final String? token = storage.read('token')?.toString();

    final String? currentUserId = storage.read('uid')?.toString();

    try {
      final url = Uri.parse('$apiEndpoint/posts');
      final response = await http.get(
        url,
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
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

  static Future<PostModel?> getPostById(String postId) async {
    final storage = GetStorage();
    final String? token = storage.read('token')?.toString();
    final String? currentUserId = storage.read('uid')?.toString();

    try {
      final url = Uri.parse('$apiEndpoint/posts/$postId');
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic>? postJson = _extractPostJson(data);
        if (postJson != null) {
          return PostModel.fromJson(postJson, currentUserId: currentUserId);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting post by id: $e');
      return null;
    }
  }

  static Map<String, dynamic>? _extractPostJson(Map<String, dynamic> data) {
    final dynamic root = data['data'] ?? data;

    if (root is Map<String, dynamic>) {
      if (root['post'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(root['post'] as Map);
      }
      if (root['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(root['data'] as Map);
      }
      if (root['id'] != null && root.containsKey('content')) {
        return Map<String, dynamic>.from(root);
      }
    }
    return null;
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

  static Future<PostCommentModel?> commentOnPost({
    required String postId,
    required String content,
  }) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    if (token == null || token.isEmpty) {
      return null;
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/posts/$postId/comment'),
        headers: headers,
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final parsed = _extractSingleComment(response.body, postId: postId);
        return parsed ??
            PostCommentModel(
              id: 'gen-$postId-${DateTime.now().millisecondsSinceEpoch}',
              postId: postId,
              userId: storage.read('uid')?.toString() ?? '',
              content: content,
              createdAt: DateTime.now(),
            );
      }
    } catch (e) {
      debugPrint('Error commenting post: $e');
    }

    return null;
  }

  static Future<List<PostCommentModel>> getComments(String postId) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    final headers = {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Cache-Control': 'no-cache',
    };

    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/posts/$postId/comments'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final comments = _extractComments(data);
        if (comments != null) {
          return comments;
        }
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    }

    return [];
  }

  static List<PostCommentModel>? _extractComments(dynamic data) {
    dynamic root;
    if (data is Map<String, dynamic>) {
      root = data['data'] ?? data;
    } else {
      root = data;
    }

    if (root is List) {
      return _mapComments(root);
    }

    if (root is Map<String, dynamic>) {
      final comments = root['comments'];
      if (comments is Map && comments['data'] is List) {
        return _mapComments(comments['data'] as List);
      }
      if (comments is List) {
        return _mapComments(comments);
      }
      if (root['data'] is List) {
        return _mapComments(root['data'] as List);
      }

      if (root['post'] is Map) {
        final postMap = root['post'] as Map;
        final postComments = postMap['comments'];
        if (postComments is Map && postComments['data'] is List) {
          return _mapComments(postComments['data'] as List);
        }
        if (postComments is List) {
          return _mapComments(postComments);
        }
      }
    }
    return null;
  }

  static List<PostCommentModel> _mapComments(List<dynamic> source) {
    return source
        .where((e) => e is Map<String, dynamic> || e is Map)
        .map(
          (e) => PostCommentModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  static bool _isDeleteSuccess(int statusCode) {
    return statusCode == 200 ||
        statusCode == 204 ||
        statusCode == 202 ||
        statusCode == 201;
  }

  static Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    if (token == null || token.isEmpty) return false;

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final url = Uri.parse('$apiEndpoint/posts/$postId/comment/$commentId');
    try {
      final response = await http.delete(url, headers: headers);
      return _isDeleteSuccess(response.statusCode);
    } catch (e) {
      debugPrint('Error deleting comment ($url): $e');
      return false;
    }
  }

  static Future<ShareActionResult> sharePost(String postId) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    if (token == null || token.isEmpty) {
      return const ShareActionResult(success: false);
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/posts/$postId/share'),
        headers: headers,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final shareCount = _extractShareCount(response.body);
        return ShareActionResult(success: true, shareCount: shareCount);
      }

      if (response.statusCode == 409) {
        final shareCount = _extractShareCount(response.body);
        return ShareActionResult(
          success: true,
          alreadyShared: true,
          shareCount: shareCount,
        );
      }
    } catch (e) {
      debugPrint('Error sharing post: $e');
    }

    return const ShareActionResult(success: false);
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
      final body = {'content': content, 'sheet_id': ?sheetId};

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

  static int? _extractShareCount(String body) {
    try {
      if (body.isEmpty) return null;
      final decoded = jsonDecode(body);
      final data = decoded['data'] ?? decoded;
      if (data is Map<String, dynamic>) {
        if (data['share_count'] != null) {
          return int.tryParse(data['share_count'].toString());
        }
        if (data['shares'] is Map && data['shares']['total_items'] != null) {
          return int.tryParse(data['shares']['total_items'].toString());
        }
        if (data['shares'] is List) {
          return (data['shares'] as List).length;
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static PostCommentModel? _extractSingleComment(
    String body, {
    required String postId,
  }) {
    try {
      final decoded = jsonDecode(body);
      final data = decoded['data'] ?? decoded;
      dynamic commentNode;
      if (data is Map<String, dynamic>) {
        if (data['comment'] != null) {
          commentNode = data['comment'];
        } else if (data['data'] != null) {
          commentNode = data['data'];
        } else if (data['comments'] != null) {
          commentNode = data['comments'];
        }
      }
      commentNode ??= data;

      if (commentNode is Map<String, dynamic>) {
        return PostCommentModel.fromJson({'post_id': postId, ...commentNode});
      }
    } catch (e) {
      debugPrint('Error extracting single comment: $e');
    }
    return null;
  }
}
