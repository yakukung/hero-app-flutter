import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:http/http.dart' as http;

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
      path: '/users/update-username',
      body: {'username': username},
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
}
