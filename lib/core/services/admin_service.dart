import 'dart:io';

import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/services/users_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AdminService {
  static final ApiClient _api = ApiClient();

  static Future<http.Response> fetchUsers({
    String? token,
    http.Client? client,
  }) async {
    return _api.get(path: '/users/', token: token, client: client);
  }

  static Future<http.Response> fetchUserById(
    String userId, {
    String? token,
    http.Client? client,
  }) async {
    return _api.get(path: '/users/$userId', token: token, client: client);
  }

  static Future<http.Response> updateUserStatus({
    required String userId,
    required String statusFlag,
    String? token,
    http.Client? client,
  }) async {
    return _api.patchJson(
      path: '/users/update-status-flag/$userId',
      body: {'status_flag': statusFlag},
      token: token,
      client: client,
    );
  }

  static Future<http.Response> updateUserUsername({
    required String userId,
    required String username,
    String? token,
    http.Client? client,
  }) async {
    if (userId.isEmpty) {
      return http.Response('{"message":"BAD_REQUEST"}', 400);
    }

    return _api.patchJson(
      path: '/admin/users/$userId/username',
      body: {'username': username},
      token: token,
      client: client,
    );
  }

  static Future<http.Response> updateUserEmail({
    required String userId,
    required String email,
    String? token,
    http.Client? client,
  }) async {
    if (userId.isEmpty) {
      return http.Response('{"message":"BAD_REQUEST"}', 400);
    }

    return _api.patchJson(
      path: '/admin/users/$userId/email',
      body: {'email': email},
      token: token,
      client: client,
    );
  }

  static Future<http.Response> updateUserPassword({
    required String userId,
    required String newPassword,
    String? token,
    http.Client? client,
  }) async {
    if (userId.isEmpty) {
      return http.Response('{"message":"BAD_REQUEST"}', 400);
    }

    return _api.patchJson(
      path: '/admin/users/$userId/password',
      body: {'new_password': newPassword},
      token: token,
      client: client,
    );
  }

  static Future<http.Response> fetchReports({
    String? token,
    http.Client? client,
  }) {
    return _api.get(path: '/admin/reports', token: token, client: client);
  }

  static Future<http.Response> fetchPayments({
    String? token,
    http.Client? client,
  }) {
    return _api.get(path: '/admin/payments', token: token, client: client);
  }

  static Future<http.Response> updatePaymentStatus({
    required String paymentId,
    required String paymentType,
    required String paymentStatus,
    String? token,
    http.Client? client,
  }) {
    String path = '';
    switch (paymentType) {
      case 'WALLET_TOPUP':
        path = '/admin/wallet-top-ups/$paymentId/status';
        break;
      case 'SUBSCRIPTION':
        path = '/admin/subscriptions/$paymentId/status';
        break;
      case 'SHEET_PURCHASE':
        path = '/admin/sheet-purchases/$paymentId/status';
        break;
      default:
        path = '';
        break;
    }

    if (path.isEmpty) {
      return Future.value(http.Response('{"message":"BAD_REQUEST"}', 400));
    }

    return _api.patchJson(
      path: path,
      body: {'payment_status': paymentStatus},
      token: token,
      client: client,
    );
  }

  static Future<http.Response> fetchSubscriptions({
    String? token,
    http.Client? client,
  }) {
    return _api.get(path: '/admin/subscriptions', token: token, client: client);
  }

  static Future<http.Response> fetchRevenue({
    String? token,
    http.Client? client,
  }) {
    return _api.get(path: '/admin/revenue', token: token, client: client);
  }

  static Future<http.Response> fetchSheets({
    String? token,
    http.Client? client,
  }) {
    return _api.get(path: '/admin/sheets', token: token, client: client);
  }

  static Future<http.Response> fetchSheetById(
    String sheetId, {
    String? token,
    http.Client? client,
  }) {
    return _api.get(
      path: '/admin/sheets/$sheetId',
      token: token,
      client: client,
    );
  }

  static Future<http.Response> updateReportStatus({
    required String reportId,
    required String referenceTable,
    required String statusFlag,
    String? token,
    http.Client? client,
  }) {
    return _api.patchJson(
      path: '/admin/reports/$reportId/status',
      body: {'reference_table': referenceTable, 'status_flag': statusFlag},
      token: token,
      client: client,
    );
  }

  static Future<http.Response> submitReportAction({
    required String reportId,
    required String referenceTable,
    required String action,
    String? token,
    http.Client? client,
  }) {
    return _api.postJson(
      path: '/admin/reports/$reportId/action',
      body: {'reference_table': referenceTable, 'action': action},
      token: token,
      client: client,
    );
  }

  static Future<http.Response> updatePostStatus({
    required String postId,
    required String statusFlag,
    String? token,
    http.Client? client,
  }) {
    return _api.patchJson(
      path: '/admin/posts/$postId/status',
      body: {'status_flag': statusFlag},
      token: token,
      client: client,
    );
  }

  static Future<http.Response> updateSheetStatus({
    required String sheetId,
    required String statusFlag,
    String? token,
    http.Client? client,
  }) {
    return _api.patchJson(
      path: '/admin/sheets/$sheetId/status',
      body: {'status_flag': statusFlag},
      token: token,
      client: client,
    );
  }

  static Future<UserProfileImageUploadResult> updateUserProfileImage({
    required String userId,
    required File imageFile,
    String? token,
  }) async {
    final String? resolvedToken = _api.resolveToken(token);

    try {
      final request = http.MultipartRequest(
        'PUT',
        _api.buildUri('/admin/users/$userId/profile-image'),
      );
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
      return UserProfileImageUploadResult(
        success: success,
        statusCode: response.statusCode,
        message: success ? 'อัปโหลดสำเร็จ' : 'อัปโหลดไม่สำเร็จ',
      );
    } catch (e) {
      return UserProfileImageUploadResult(
        success: false,
        statusCode: 0,
        message: e.toString(),
      );
    }
  }

  static Future<http.Response> fetchPostComments({
    required String postId,
    String? token,
    http.Client? client,
  }) {
    return _api.get(
      path: '/admin/posts/$postId/comments',
      token: token,
      disableCache: true,
      client: client,
    );
  }

  static Future<http.Response> updateCommentStatus({
    required String commentId,
    required String statusFlag,
    String? token,
    http.Client? client,
  }) {
    return _api.patchJson(
      path: '/admin/comments/$commentId/status',
      body: {'status_flag': statusFlag},
      token: token,
      client: client,
    );
  }

  static Future<http.Response> deleteSheetReview({
    required String sheetId,
    required String reviewId,
    String? token,
    http.Client? client,
  }) {
    return _api.delete(
      path: '/admin/sheets/$sheetId/reviews/$reviewId',
      token: token,
      client: client,
    );
  }

  static Future<http.Response> fetchSheetReviews({
    required String sheetId,
    String? token,
    http.Client? client,
  }) {
    return _api.get(
      path: '/admin/sheets/$sheetId/reviews',
      token: token,
      disableCache: true,
      client: client,
    );
  }

  static Future<http.Response> updateReviewStatus({
    required String sheetId,
    required String reviewId,
    required String statusFlag,
    String? token,
    http.Client? client,
  }) {
    return _api.patchJson(
      path: '/admin/sheets/$sheetId/reviews/$reviewId/status',
      body: {'status_flag': statusFlag},
      token: token,
      client: client,
    );
  }
}
