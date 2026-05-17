import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/payment_history_model.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PaymentService {
  static final SessionStore _sessionStore = SessionStore();
  static final ApiClient _api = ApiClient(sessionStore: _sessionStore);

  static Future<ServiceResult<List<PaymentHistoryItem>>> fetchPaymentHistory({
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
        path: '/payments/history',
        token: token,
        disableCache: true,
        client: client,
      );
      if (response.statusCode == 200) {
        return ServiceResult(
          success: true,
          statusCode: response.statusCode,
          message: 'โหลดประวัติการชำระเงินสำเร็จ',
          data: getApiList(response.body, const ['payments', 'items', 'data'])
              .whereType<Map>()
              .map(
                (item) => PaymentHistoryItem.fromJson(
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
          message: 'ยังไม่มีประวัติการชำระเงิน',
          data: [],
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: getErrorMessage(response, fallback: 'ไม่สามารถโหลดประวัติได้'),
        data: const [],
      );
    } catch (error) {
      debugPrint('Error fetching payment history: $error');
      return ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถเชื่อมต่อประวัติการชำระเงินได้',
        data: const [],
      );
    }
  }

  static Future<ServiceResult<List<TopUpHistoryItem>>> fetchTopUpHistory({
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
        path: '/wallet/top-ups',
        token: token,
        disableCache: true,
        client: client,
      );
      if (response.statusCode == 200) {
        return ServiceResult(
          success: true,
          statusCode: response.statusCode,
          message: 'โหลดรายการเติมเงินสำเร็จ',
          data:
              getApiList(response.body, const [
                    'top_ups',
                    'topups',
                    'items',
                    'data',
                  ])
                  .whereType<Map>()
                  .map(
                    (item) => TopUpHistoryItem.fromJson(
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
          message: 'ยังไม่มีรายการเติมเงิน',
          data: [],
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: getErrorMessage(
          response,
          fallback: 'ไม่สามารถโหลดรายการเติมเงินได้',
        ),
        data: const [],
      );
    } catch (error) {
      debugPrint('Error fetching top-up history: $error');
      return ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถเชื่อมต่อรายการเติมเงินได้',
        data: const [],
      );
    }
  }

  static Future<ServiceResult<PaymentStatus>> createTopUp({
    required double amount,
    required File slipImage,
  }) {
    return _postSlipPayment(
      path: '/wallet/top-ups',
      slipImage: slipImage,
      fields: {
        'amount': amount.toStringAsFixed(2),
        'payment_method': 'PROMPTPAY',
      },
      unavailableMessage: 'ระบบเติมเงินยังไม่พร้อมใช้งาน',
    );
  }

  static Future<ServiceResult<PaymentStatus>> subscribe({
    required String packageTitle,
    required double amount,
    required File slipImage,
    String? planId,
  }) {
    return _postSlipPayment(
      path: '/subscriptions',
      slipImage: slipImage,
      fields: {
        'package_title': packageTitle,
        'plan_name': packageTitle,
        if (planId != null && planId.isNotEmpty) 'plan_id': planId,
        'amount': amount.toStringAsFixed(2),
        'payment_method': 'PROMPTPAY',
      },
      unavailableMessage: 'ระบบสมัครสมาชิกพรีเมียมยังไม่พร้อมใช้งาน',
    );
  }

  static Future<ServiceResult<SheetPurchaseResult>> purchaseSheet({
    required String sheetId,
    required double amount,
    http.Client? client,
  }) async {
    final token = _sessionStore.token;
    if (token.isEmpty) {
      return const ServiceResult(
        success: false,
        statusCode: 401,
        message: 'กรุณาเข้าสู่ระบบก่อนซื้อชีต',
        data: SheetPurchaseResult(isPurchased: false),
      );
    }

    try {
      final response = await _api.postJson(
        path: '/sheets/$sheetId/purchase',
        body: {'amount': amount, 'payment_method': 'WALLET'},
        token: token,
        client: client,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceResult(
          success: true,
          statusCode: response.statusCode,
          message: 'ซื้อชีตสำเร็จ',
          data: SheetPurchaseResult.fromJson(
            decodeJsonMap(response.body) ?? const <String, dynamic>{},
          ),
        );
      }
      if (response.statusCode == 402 || response.statusCode == 409) {
        return ServiceResult(
          success: false,
          statusCode: response.statusCode,
          message: getErrorMessage(
            response,
            fallback: 'ยอดเงินไม่พอสำหรับซื้อชีต',
          ),
          data: SheetPurchaseResult(isPurchased: false),
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: getErrorMessage(
          response,
          fallback: 'ระบบซื้อชีตยังไม่พร้อมใช้งาน',
        ),
        data: SheetPurchaseResult(isPurchased: false),
      );
    } catch (error) {
      debugPrint('Error purchasing sheet: $error');
      return const ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถเชื่อมต่อระบบซื้อชีตได้',
        data: SheetPurchaseResult(isPurchased: false),
      );
    }
  }

  static Future<ServiceResult<List<SubscriptionPlanModel>>> fetchPlans({
    http.Client? client,
  }) async {
    try {
      final response = await _api.get(
        path: '/subscriptions/plans',
        disableCache: true,
        client: client,
      );
      if (response.statusCode == 200) {
        return ServiceResult(
          success: true,
          statusCode: response.statusCode,
          message: 'โหลดแพ็กเกจสำเร็จ',
          data: getApiList(response.body, const ['plans', 'items', 'data'])
              .whereType<Map>()
              .map(
                (item) => SubscriptionPlanModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: 'ใช้แพ็กเกจเริ่มต้นระหว่างรอ backend',
        data: const [],
      );
    } catch (_) {
      return const ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ใช้แพ็กเกจเริ่มต้นระหว่างรอ backend',
        data: [],
      );
    }
  }

  static Future<ServiceResult<SubscriptionStatusModel>>
  fetchSubscriptionStatus({http.Client? client}) async {
    final token = _sessionStore.token;
    if (token.isEmpty) {
      return ServiceResult(
        success: false,
        statusCode: 401,
        message: 'กรุณาเข้าสู่ระบบ',
        data: SubscriptionStatusModel.inactive(),
      );
    }

    try {
      final response = await _api.get(
        path: '/subscriptions/me',
        token: token,
        disableCache: true,
        client: client,
      );
      if (response.statusCode == 200) {
        return ServiceResult(
          success: true,
          statusCode: response.statusCode,
          message: 'โหลดสถานะสมาชิกสำเร็จ',
          data: SubscriptionStatusModel.fromJson(
            decodeJsonMap(response.body) ?? const <String, dynamic>{},
          ),
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: getErrorMessage(
          response,
          fallback: 'ไม่สามารถโหลดสถานะสมาชิกได้',
        ),
        data: SubscriptionStatusModel.inactive(),
      );
    } catch (error) {
      debugPrint('Error fetching subscription status: $error');
      return ServiceResult(
        success: false,
        statusCode: 0,
        message: 'ไม่สามารถเชื่อมต่อสถานะสมาชิกได้',
        data: SubscriptionStatusModel.inactive(),
      );
    }
  }

  static Future<ServiceResult<PaymentStatus>> _postSlipPayment({
    required String path,
    required File slipImage,
    required Map<String, String> fields,
    required String unavailableMessage,
  }) async {
    final token = _sessionStore.token;
    if (token.isEmpty) {
      return const ServiceResult(
        success: false,
        statusCode: 401,
        message: 'กรุณาเข้าสู่ระบบ',
      );
    }

    try {
      final fileSize = await slipImage.length();
      if (fileSize > 5 * 1024 * 1024) {
        return const ServiceResult(
          success: false,
          statusCode: 400,
          message: 'ไฟล์รูปภาพใหญ่เกิน 5MB กรุณาเลือกรูปอื่น',
        );
      }

      final request = http.MultipartRequest('POST', _api.buildUri(path));
      request.headers.addAll({
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      });
      request.fields.addAll(fields);
      final mimeType = slipImage.path.toLowerCase().endsWith('.png')
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');

      request.files.add(
        await http.MultipartFile.fromPath(
          'slip_image',
          slipImage.path,
          contentType: mimeType,
        ),
      );
      return _sendPaymentRequest(request, unavailableMessage);
    } catch (error) {
      debugPrint('Error creating payment request: $error');
      return ServiceResult(
        success: false,
        statusCode: 0,
        message: unavailableMessage,
      );
    }
  }

  static Future<ServiceResult<PaymentStatus>> _sendPaymentRequest(
    http.MultipartRequest request,
    String unavailableMessage,
  ) async {
    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      await _api.handleResponse(response, token: _sessionStore.token);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceResult(
          success: true,
          statusCode: response.statusCode,
          message: 'ส่งหลักฐานการชำระเงินแล้ว',
          data: _statusFromResponse(response),
        );
      }
      return ServiceResult(
        success: false,
        statusCode: response.statusCode,
        message: getErrorMessage(response, fallback: unavailableMessage),
      );
    } catch (error) {
      debugPrint('Error sending payment request: $error');
      return ServiceResult(
        success: false,
        statusCode: 0,
        message: unavailableMessage,
      );
    }
  }

  static PaymentStatus _statusFromResponse(http.Response response) {
    try {
      final data = getApiData(response.body);
      if (data is Map && data['payment_status'] != null) {
        return PaymentStatus.fromString(data['payment_status'].toString());
      }
    } catch (_) {}
    return PaymentStatus.PENDING;
  }
}
