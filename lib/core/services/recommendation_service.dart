import 'package:flutter/foundation.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:http/http.dart' as http;

class RecommendationService {
  static final SessionStore _sessionStore = SessionStore();
  static final ApiClient _api = ApiClient(sessionStore: _sessionStore);

  static Future<ServiceResult<List<SheetModel>>> fetchRecommendations({
    http.Client? client,
  }) async {
    final token = _sessionStore.token;
    try {
      final response = await _api.get(
        path: '/recommendations',
        token: token.isNotEmpty ? token : null,
        disableCache: true,
        client: client,
      );
      if (response.statusCode == 200) {
        return ServiceResult(
          success: true,
          statusCode: response.statusCode,
          message: 'โหลดชีตแนะนำสำเร็จ',
          data:
              getApiList(response.body, const [
                    'sheets',
                    'recommendations',
                    'items',
                    'data',
                  ])
                  .whereType<Map>()
                  .map(
                    (item) =>
                        SheetModel.fromJson(Map<String, dynamic>.from(item)),
                  )
                  .toList(),
        );
      }
      return const ServiceResult(
        success: false,
        statusCode: 404,
        message: 'ใช้การเรียงลำดับในแอประหว่างรอ backend',
        data: [],
      );
    } catch (error) {
      debugPrint('Error fetching recommendations: $error');
      return const ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ใช้การเรียงลำดับในแอประหว่างรอ backend',
        data: [],
      );
    }
  }
}
