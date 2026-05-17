import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:http/http.dart' as http;

class ReviewsService {
  static final SessionStore _sessionStore = SessionStore();
  static final ApiClient _api = ApiClient(sessionStore: _sessionStore);

  static Future<ServiceResult<List<SheetReviewModel>>> fetchSheetReviews(
    String sheetId, {
    http.Client? client,
  }) async {
    try {
      final response = await _api.get(
        path: '/sheets/$sheetId/reviews',
        disableCache: true,
        client: client,
      );
      if (response.statusCode == 200) {
        return ServiceResult(
          success: true,
          statusCode: response.statusCode,
          message: 'โหลดรีวิวสำเร็จ',
          data: getApiList(response.body, const ['reviews', 'items', 'data'])
              .whereType<Map>()
              .map(
                (item) =>
                    SheetReviewModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(),
        );
      }
      if (response.statusCode == 404) {
        return const ServiceResult(
          success: true,
          statusCode: 404,
          message: 'ยังไม่มีรีวิว',
          data: [],
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: getErrorMessage(
          response,
          fallback: 'ระบบรีวิวยังไม่พร้อมใช้งาน',
        ),
        data: const [],
      );
    } catch (error) {
      debugPrint('Error fetching sheet reviews: $error');
      return const ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถเชื่อมต่อระบบรีวิวได้',
        data: [],
      );
    }
  }

  static Future<ServiceResult<SheetReviewModel?>> submitSheetReview({
    required String sheetId,
    required int score,
    required String content,
    http.Client? client,
  }) async {
    final token = _sessionStore.token;
    if (token.isEmpty) {
      return const ServiceResult(
        success: false,
        statusCode: 401,
        message: 'กรุณาเข้าสู่ระบบก่อนรีวิว',
      );
    }

    try {
      final response = await _api.postJson(
        path: '/sheets/$sheetId/reviews',
        body: {'score': score, 'content': content},
        token: token,
        client: client,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceResult(
          success: true,
          statusCode: response.statusCode,
          message: 'บันทึกรีวิวแล้ว',
          data: _extractReview(response.body, sheetId: sheetId),
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: getErrorMessage(
          response,
          fallback: 'ระบบรีวิวยังไม่พร้อมใช้งาน',
        ),
      );
    } catch (error) {
      debugPrint('Error submitting sheet review: $error');
      return const ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถเชื่อมต่อระบบรีวิวได้',
      );
    }
  }

  static Future<ServiceResult<bool>> deleteSheetReview({
    required String sheetId,
    required String reviewId,
    http.Client? client,
  }) async {
    final token = _sessionStore.token;
    if (token.isEmpty) {
      return const ServiceResult(
        success: false,
        statusCode: 401,
        message: 'กรุณาเข้าสู่ระบบก่อนลบรีวิว',
        data: false,
      );
    }

    try {
      final response = await _api.delete(
        path: '/sheets/$sheetId/reviews/$reviewId',
        token: token,
        client: client,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const ServiceResult(
          success: true,
          statusCode: 204,
          message: 'ลบรีวิวแล้ว',
          data: true,
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: getErrorMessage(response, fallback: 'ไม่สามารถลบรีวิวได้'),
        data: false,
      );
    } catch (error) {
      debugPrint('Error deleting sheet review: $error');
      return const ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถเชื่อมต่อระบบรีวิวได้',
        data: false,
      );
    }
  }

  static SheetReviewModel? _extractReview(
    String body, {
    required String sheetId,
  }) {
    try {
      final decoded = jsonDecode(body);
      dynamic root = decoded is Map ? decoded['data'] ?? decoded : decoded;
      if (root is Map && root['review'] is Map) {
        root = root['review'];
      }
      if (root is Map) {
        return SheetReviewModel.fromJson({
          'sheet_id': sheetId,
          ...Map<String, dynamic>.from(root),
        });
      }
    } catch (_) {}
    return null;
  }
}
