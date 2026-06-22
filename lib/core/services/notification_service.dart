import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/models/notification_model.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
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

  static List<AppNotificationModel> buildSheetNotifications({
    required DateTime lastSeenAt,
    List<SheetModel>? sheets,
  }) {
    final allSheets = sheets ?? Get.find<SheetsController>().sheets;
    final results = <AppNotificationModel>[];

    for (final sheet in allSheets) {
      final isNew = sheet.createdAt.isAfter(lastSeenAt);
      final isUpdated = sheet.updatedAt != null &&
          sheet.updatedAt!.isAfter(lastSeenAt) &&
          sheet.updatedAt!.difference(sheet.createdAt).inSeconds > 5;

      if (!isNew && !isUpdated) continue;

      results.add(AppNotificationModel(
        id: 'sheet_${sheet.id}',
        title: isNew ? 'ชีตใหม่' : 'ชีตอัปเดต',
        message: isNew
            ? 'มีชีตใหม่ "${sheet.title}"'
            : 'ชีต "${sheet.title}" มีการอัปเดต',
        createdAt: isNew ? sheet.createdAt : sheet.updatedAt!,
        isRead: false,
        referenceTable: 'sheets',
        referenceId: sheet.id,
      ));
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  static int countUnreadSheets({
    required DateTime lastSeenAt,
    List<SheetModel>? sheets,
  }) {
    final allSheets = sheets ?? Get.find<SheetsController>().sheets;
    return allSheets.where((s) {
      if (s.createdAt.isAfter(lastSeenAt)) {
        return true;
      }
      if (s.updatedAt != null &&
          s.updatedAt!.isAfter(lastSeenAt) &&
          s.updatedAt!.difference(s.createdAt).inSeconds > 5) {
        return true;
      }
      return false;
    }).length;
  }
}

class NotificationPreferences {
  NotificationPreferences._();

  static final _box = GetStorage();

  static DateTime? get lastSeenAt {
    final ts = _box.read<String>('notificationLastSeenAt');
    return ts != null ? DateTime.tryParse(ts) : null;
  }

  static set lastSeenAt(DateTime value) {
    _box.write('notificationLastSeenAt', value.toIso8601String());
  }

  static void markAsSeen() {
    lastSeenAt = DateTime.now();
  }
}
