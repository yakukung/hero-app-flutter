import 'package:flutter/foundation.dart';
import 'package:hero_app_flutter/core/models/notification_model.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final SessionStore _sessionStore = SessionStore();
  static final ApiClient _api = ApiClient(sessionStore: _sessionStore);

  static Future<ServiceResult<List<AppNotificationModel>>> fetchNotifications({
    http.Client? client,
  }) async {
    final token = _sessionStore.token;
    if (token.isEmpty) {
      return const ServiceResult(
        success: false,
        statusCode: 401,
        message: 'กรุณาเข้าสู่ระบบ',
        data: [],
      );
    }

    try {
      final response = await _api.get(
        path: '/notifications',
        token: token,
        disableCache: true,
        client: client,
      );
      if (response.statusCode == 200) {
        return ServiceResult(
          success: true,
          statusCode: response.statusCode,
          message: 'โหลดการแจ้งเตือนสำเร็จ',
          data:
              getApiList(response.body, const [
                    'notifications',
                    'items',
                    'data',
                  ])
                  .whereType<Map>()
                  .map(
                    (item) => AppNotificationModel.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
                  )
                  .toList(),
        );
      }
      if (response.statusCode == 404) {
        return const ServiceResult(
          success: true,
          statusCode: 404,
          message: 'ยังไม่มีการแจ้งเตือน',
          data: [],
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: 'ระบบแจ้งเตือนยังไม่พร้อมใช้งาน',
        data: const [],
      );
    } catch (error) {
      debugPrint('Error fetching notifications: $error');
      return const ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถเชื่อมต่อระบบแจ้งเตือนได้',
        data: [],
      );
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    final token = _sessionStore.token;
    if (token.isEmpty) return;
    try {
      await _api.patchJson(
        path: '/notifications/$notificationId/read',
        body: const {},
        token: token,
      );
    } catch (_) {}
  }
}
