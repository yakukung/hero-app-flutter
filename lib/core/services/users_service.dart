import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/core/network/api_client.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:flutter_application_1/core/utils/api_utils.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UserProfileImageUploadResult {
  final bool success;
  final int statusCode;
  final String message;
  final String? profileImage;

  const UserProfileImageUploadResult({
    required this.success,
    required this.statusCode,
    required this.message,
    this.profileImage,
  });
}

class UsersService {
  static final ApiClient _api = ApiClient();

  static Future<http.Response> fetchUserByIdRaw(
    String userId, {
    String? token,
    http.Client? client,
  }) async {
    return _api.get(path: '/users/$userId', token: token, client: client);
  }

  static Future<bool> followUser(String userId) async {
    try {
      final response = await _api.post(
        path: '/users/$userId/follow',
        includeJsonContentType: false,
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
    try {
      final response = await _api.delete(
        path: '/users/$userId/follow',
        includeJsonContentType: false,
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
    try {
      final response = await fetchUserByIdRaw(userId);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return UserModel.fromJson(jsonResponse['data']);
      }
    } catch (e) {
      debugPrint('Error fetching user by id: $e');
    }
    return null;
  }

  static Future<http.Response> updateUsername({
    required String uid,
    required String username,
    String? token,
    http.Client? client,
  }) async {
    return _api.patchJson(
      path: '/users/update-username',
      body: {'uid': uid, 'username': username},
      token: token,
      client: client,
    );
  }

  static Future<http.Response> updateEmail({
    required String uid,
    required String email,
    required String password,
    String? token,
    http.Client? client,
  }) async {
    return _api.patchJson(
      path: '/users/update-email',
      body: {'uid': uid, 'email': email, 'password': password},
      token: token,
      client: client,
    );
  }

  static Future<http.Response> updatePassword({
    required String uid,
    required String oldPassword,
    required String newPassword,
    String? token,
    http.Client? client,
  }) async {
    return _api.patchJson(
      path: '/users/update-password',
      body: {
        'uid': uid,
        'old_password': oldPassword,
        'new_password': newPassword,
      },
      token: token,
      client: client,
    );
  }

  static Future<UserProfileImageUploadResult> updateProfileImage({
    required String uid,
    required File imageFile,
    String? token,
    void Function(int bytes, int total)? onProgress,
  }) async {
    final String? resolvedToken = _api.resolveToken(token);

    try {
      final request = onProgress != null
          ? _ProgressMultipartRequest(
              'PUT',
              _api.buildUri('/users/update-profile-image'),
              onProgress: onProgress,
            )
          : http.MultipartRequest(
              'PUT',
              _api.buildUri('/users/update-profile-image'),
            );

      request.fields['uid'] = uid;
      if (resolvedToken != null && resolvedToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $resolvedToken';
      }

      final mediaType = imageFile.path.toLowerCase().endsWith('.png')
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          imageFile.path,
          contentType: mediaType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final bool success =
          response.statusCode == 200 || response.statusCode == 204;
      if (!success) {
        return UserProfileImageUploadResult(
          success: false,
          statusCode: response.statusCode,
          message: getErrorMessage(response),
        );
      }

      String? profileImage;
      final parsed = _tryParseJsonMap(response.body);
      if (parsed != null) {
        final dynamic data = parsed['data'];
        final dynamic rootProfileImage = parsed['profile_image'];
        if (rootProfileImage is String && rootProfileImage.isNotEmpty) {
          profileImage = rootProfileImage;
        } else if (data is Map<String, dynamic>) {
          final dynamic nestedProfileImage = data['profile_image'];
          if (nestedProfileImage is String && nestedProfileImage.isNotEmpty) {
            profileImage = nestedProfileImage;
          }
        }
      }

      return UserProfileImageUploadResult(
        success: true,
        statusCode: response.statusCode,
        message: 'อัปโหลดรูปโปรไฟล์สำเร็จ',
        profileImage: profileImage,
      );
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      return UserProfileImageUploadResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถอัปเดตรูปโปรไฟล์ได้',
      );
    }
  }

  static Map<String, dynamic>? _tryParseJsonMap(String source) {
    if (source.trim().isEmpty) return null;

    try {
      final dynamic decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}

    return null;
  }
}

class _ProgressMultipartRequest extends http.MultipartRequest {
  final void Function(int bytes, int total) onProgress;

  _ProgressMultipartRequest(
    super.method,
    super.url, {
    required this.onProgress,
  });

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final total = contentLength;
    int bytes = 0;

    final transformer = StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: (data, sink) {
        bytes += data.length;
        onProgress(bytes, total);
        sink.add(data);
      },
    );

    return http.ByteStream(byteStream.transform(transformer));
  }
}
