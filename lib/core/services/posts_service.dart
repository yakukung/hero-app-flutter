import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/models/post_model.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';

class ShareActionResult {
  final bool success;
  final bool alreadyShared;
  final bool removed;
  final int? shareCount;

  const ShareActionResult({
    required this.success,
    this.alreadyShared = false,
    this.removed = false,
    this.shareCount,
  });
}

class PostsService {
  static final SessionStore _sessionStore = SessionStore();
  static final ApiClient _api = ApiClient(sessionStore: _sessionStore);

  static Future<List<PostModel>> getPosts() async {
    final String token = _sessionStore.token;
    final String currentUserId = _sessionStore.uid;

    try {
      final response = await _api.get(
        path: '/posts',
        token: token.isNotEmpty ? token : null,
        disableCache: true,
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
    final String token = _sessionStore.token;
    final String currentUserId = _sessionStore.uid;

    try {
      final response = await _api.get(
        path: '/posts/$postId',
        token: token.isNotEmpty ? token : null,
        disableCache: true,
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
    final String token = _sessionStore.token;

    try {
      final response = await _api.post(
        path: '/posts/$postId/like',
        token: token.isNotEmpty ? token : null,
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
    final String token = _sessionStore.token;

    try {
      final response = await _api.delete(
        path: '/posts/$postId/like',
        token: token.isNotEmpty ? token : null,
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
    final String token = _sessionStore.token;

    if (token.isEmpty) {
      return null;
    }

    try {
      final response = await _api.postJson(
        path: '/posts/$postId/comment',
        body: {'content': content},
        token: token,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final parsed = _extractSingleComment(response.body, postId: postId);
        return parsed ??
            PostCommentModel(
              id: 'gen-$postId-${DateTime.now().millisecondsSinceEpoch}',
              postId: postId,
              userId: _sessionStore.uid,
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
    final String token = _sessionStore.token;

    try {
      final response = await _api.get(
        path: '/posts/$postId/comments',
        token: token.isNotEmpty ? token : null,
        disableCache: true,
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
    final String token = _sessionStore.token;

    if (token.isEmpty) return false;

    try {
      final response = await _api.delete(
        path: '/posts/$postId/comment/$commentId',
        token: token,
      );
      return _isDeleteSuccess(response.statusCode);
    } catch (e) {
      debugPrint('Error deleting comment ($postId/$commentId): $e');
      return false;
    }
  }

  static Future<ShareActionResult> sharePost(String postId) async {
    final String token = _sessionStore.token;

    if (token.isEmpty) {
      return const ShareActionResult(success: false);
    }

    try {
      final response = await _api.post(
        path: '/posts/$postId/share',
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  static Future<ShareActionResult> unsharePost(String postId) async {
    final String token = _sessionStore.token;

    if (token.isEmpty) {
      return const ShareActionResult(success: false);
    }

    try {
      final response = await _api.delete(
        path: '/posts/$postId/share',
        token: token,
      );

      if (_isDeleteSuccess(response.statusCode) || response.statusCode == 404) {
        final shareCount = _extractShareCount(response.body);
        return ShareActionResult(
          success: true,
          removed: true,
          shareCount: shareCount,
        );
      }
    } catch (e) {
      debugPrint('Error unsharing post: $e');
    }

    return const ShareActionResult(success: false);
  }

  static Future<bool> createPost({
    required String content,
    String? sheetId,
  }) async {
    final String token = _sessionStore.token;

    if (token.isEmpty) {
      return false;
    }

    try {
      final body = <String, dynamic>{
        'content': content,
        if (sheetId != null && sheetId.isNotEmpty) 'sheet_id': sheetId,
      };

      final response = await _api.postJson(
        path: '/posts/create',
        body: body,
        token: token,
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
