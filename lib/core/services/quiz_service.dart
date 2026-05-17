import 'package:flutter/foundation.dart';
import 'package:hero_app_flutter/core/models/quiz_result_model.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:http/http.dart' as http;

class QuizService {
  static final SessionStore _sessionStore = SessionStore();
  static final ApiClient _api = ApiClient(sessionStore: _sessionStore);

  static Future<ServiceResult<bool>> submitResult(
    QuizResultModel result, {
    http.Client? client,
  }) async {
    final token = _sessionStore.token;
    if (token.isEmpty) {
      return const ServiceResult(
        success: false,
        statusCode: 401,
        message: 'ไม่ได้บันทึกผล เพราะยังไม่ได้เข้าสู่ระบบ',
        data: false,
      );
    }

    try {
      final response = await _api.postJson(
        path: '/quiz/results',
        body: result.toJson(),
        token: token,
        client: client,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const ServiceResult(
          success: true,
          statusCode: 201,
          message: 'บันทึกผลคะแนนแล้ว',
          data: true,
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: getErrorMessage(
          response,
          fallback: 'ระบบบันทึกคะแนนยังไม่พร้อมใช้งาน',
        ),
        data: false,
      );
    } catch (error) {
      debugPrint('Error submitting quiz result: $error');
      return const ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถเชื่อมต่อระบบบันทึกคะแนนได้',
        data: false,
      );
    }
  }

  static Future<ServiceResult<Map<String, dynamic>>> fetchResult(
    String sheetId, {
    http.Client? client,
  }) async {
    final token = _sessionStore.token;
    if (token.isEmpty) {
      return const ServiceResult(
        success: false,
        statusCode: 401,
        message: 'กรุณาเข้าสู่ระบบ',
        data: {},
      );
    }

    try {
      final response = await _api.get(
        path: '/quiz/results/$sheetId',
        token: token,
        disableCache: true,
        client: client,
      );
      if (response.statusCode == 200) {
        final data = getApiData(response.body);
        return ServiceResult(
          success: true,
          statusCode: response.statusCode,
          message: 'โหลดผลคะแนนสำเร็จ',
          data: data is Map<String, dynamic> ? data : <String, dynamic>{},
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: getErrorMessage(
          response,
          fallback: 'ระบบผลคะแนนยังไม่พร้อมใช้งาน',
        ),
        data: const {},
      );
    } catch (error) {
      debugPrint('Error fetching quiz result: $error');
      return const ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถเชื่อมต่อระบบผลคะแนนได้',
        data: {},
      );
    }
  }
}
