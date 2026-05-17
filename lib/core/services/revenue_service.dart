import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hero_app_flutter/core/models/revenue_model.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:http/http.dart' as http;

class RevenueService {
  static final SessionStore _sessionStore = SessionStore();
  static final ApiClient _api = ApiClient(sessionStore: _sessionStore);

  static Future<ServiceResult<RevenueSummaryModel>> fetchCreatorEarnings({
    http.Client? client,
  }) async {
    final token = _sessionStore.token;
    if (token.isEmpty) {
      return ServiceResult(
        success: false,
        statusCode: 401,
        message: 'กรุณาเข้าสู่ระบบ',
        data: RevenueSummaryModel.empty(),
      );
    }

    try {
      final response = await _api.get(
        path: '/revenue/creator',
        token: token,
        disableCache: true,
        client: client,
      );
      if (response.statusCode == 200) {
        return ServiceResult(
          success: true,
          statusCode: response.statusCode,
          message: 'โหลดรายได้สำเร็จ',
          data: RevenueSummaryModel.fromJson(jsonDecode(response.body)),
        );
      }
      if (response.statusCode == 404) {
        return ServiceResult(
          success: true,
          statusCode: 404,
          message: 'ยังไม่มีรายได้',
          data: RevenueSummaryModel.empty(),
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: 'ระบบรายได้ยังไม่พร้อมใช้งาน',
        data: RevenueSummaryModel.empty(),
      );
    } catch (error) {
      debugPrint('Error fetching creator earnings: $error');
      return ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถเชื่อมต่อระบบรายได้ได้',
        data: RevenueSummaryModel.empty(),
      );
    }
  }
}
