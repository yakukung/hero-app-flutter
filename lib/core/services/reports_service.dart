import 'package:flutter/foundation.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:http/http.dart' as http;

class ReportsService {
  static final SessionStore _sessionStore = SessionStore();
  static final ApiClient _api = ApiClient(sessionStore: _sessionStore);

  static Future<ServiceResult<bool>> submitReport({
    required String referenceId,
    required String referenceTable,
    required ReportType reportType,
    required String content,
    http.Client? client,
  }) async {
    final token = _sessionStore.token;
    if (token.isEmpty) {
      return const ServiceResult(
        success: false,
        statusCode: 401,
        message: 'กรุณาเข้าสู่ระบบก่อนรายงาน',
        data: false,
      );
    }

    try {
      final response = await _api.postJson(
        path: '/reports',
        body: {
          'reference_id': referenceId,
          'reference_table': referenceTable,
          'report_type': reportType.name,
          'content': content,
        },
        token: token,
        client: client,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const ServiceResult(
          success: true,
          statusCode: 201,
          message: 'ส่งรายงานแล้ว',
          data: true,
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: getErrorMessage(
          response,
          fallback: 'ระบบรายงานยังไม่พร้อมใช้งาน',
        ),
        data: false,
      );
    } catch (error) {
      debugPrint('Error submitting report: $error');
      return const ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถเชื่อมต่อระบบรายงานได้',
        data: false,
      );
    }
  }
}
