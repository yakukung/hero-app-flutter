import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter_application_1/core/models/category_model.dart';
import 'package:flutter_application_1/core/models/sheet_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class SheetPaymentData {
  final String sheetId;
  final String sheetTable = 'sheets';
  final String paymentMethod = 'PROMPTPAY';
  final double amount;
  final String currency;
  final List<File> slipImage;

  const SheetPaymentData({
    required this.sheetId,
    required this.amount,
    required this.currency,
    required this.slipImage,
  });
}

class SheetActionResult {
  final bool success;
  final String message;

  const SheetActionResult({required this.success, required this.message});
}

class SheetsService {
  static Uri _buildUri(String path) => Uri.parse('$apiEndpoint$path');

  static String? _resolveToken(String? token) {
    if (token != null && token.isNotEmpty) return token;
    return GetStorage().read('token')?.toString();
  }

  static Map<String, String> _jsonHeaders({
    String? token,
    bool disableCache = false,
  }) {
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (disableCache) 'Cache-Control': 'no-cache',
    };
  }

  static Future<http.Response> _withClient(
    Future<http.Response> Function(http.Client client) action, {
    http.Client? client,
  }) async {
    final http.Client httpClient = client ?? http.Client();
    try {
      return await action(httpClient);
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  static Future<List<SheetModel>> fetchFavorites({
    String? token,
    http.Client? client,
  }) async {
    final String? resolvedToken = _resolveToken(token);
    if (resolvedToken == null || resolvedToken.isEmpty) {
      return [];
    }

    try {
      final response = await _withClient(
        (httpClient) => httpClient.get(
          _buildUri('/sheets/favorites'),
          headers: _jsonHeaders(token: resolvedToken),
        ),
        client: client,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']?['sheets'] ?? [];
        return data
            .whereType<Map>()
            .map(
              (item) => SheetModel.fromJson(
                _withCurrentUserPurchaseFlag(Map<String, dynamic>.from(item)),
              ),
            )
            .toList();
      }

      if (response.statusCode == 404) {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
    }

    return [];
  }

  static Future<List<SheetModel>> fetchSheets({
    String? token,
    http.Client? client,
  }) async {
    final String? resolvedToken = _resolveToken(token);

    try {
      final response = await _withClient(
        (httpClient) => httpClient.get(
          _buildUri('/sheets'),
          headers: _jsonHeaders(token: resolvedToken, disableCache: true),
        ),
        client: client,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']?['sheets'] ?? [];
        return data
            .whereType<Map>()
            .map(
              (item) => SheetModel.fromJson(
                _withCurrentUserPurchaseFlag(Map<String, dynamic>.from(item)),
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching sheets: $e');
    }

    return [];
  }

  static Future<List<CategoryModel>> fetchCategories({
    String? token,
    http.Client? client,
  }) async {
    final String? resolvedToken = _resolveToken(token);

    try {
      final response = await _withClient(
        (httpClient) => httpClient.get(
          _buildUri('/categories'),
          headers: _jsonHeaders(token: resolvedToken),
        ),
        client: client,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']?['categories'] ?? [];
        return data
            .whereType<Map>()
            .map(
              (item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }

    return [];
  }

  static Future<bool> addFavorite(
    String sheetId, {
    String? token,
    http.Client? client,
  }) async {
    final String? resolvedToken = _resolveToken(token);
    if (resolvedToken == null || resolvedToken.isEmpty) {
      return false;
    }

    try {
      final response = await _withClient(
        (httpClient) => httpClient.post(
          _buildUri('/sheets/sheet-favorites'),
          headers: _jsonHeaders(token: resolvedToken),
          body: jsonEncode({'sheet_id': sheetId}),
        ),
        client: client,
      );

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return false;
    }
  }

  static Future<bool> removeFavorite(
    String sheetId, {
    String? token,
    http.Client? client,
  }) async {
    final String? resolvedToken = _resolveToken(token);
    if (resolvedToken == null || resolvedToken.isEmpty) {
      return false;
    }

    try {
      final response = await _withClient(
        (httpClient) => httpClient.post(
          _buildUri('/sheets/sheet-unfavorites'),
          headers: _jsonHeaders(token: resolvedToken),
          body: jsonEncode({'sheet_id': sheetId}),
        ),
        client: client,
      );

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      return false;
    }
  }

  static Future<SheetModel?> fetchSheetById(
    String sheetId, {
    String? token,
    http.Client? client,
  }) async {
    final String? resolvedToken = _resolveToken(token);

    try {
      final response = await _withClient(
        (httpClient) => httpClient.get(
          _buildUri('/sheets/$sheetId'),
          headers: {
            if (resolvedToken != null && resolvedToken.isNotEmpty)
              'Authorization': 'Bearer $resolvedToken',
          },
        ),
        client: client,
      );

      if (response.statusCode != 200) {
        return null;
      }

      final dynamic jsonResponse = jsonDecode(response.body);
      final Map<String, dynamic>? sheetMap = _extractSingleSheetMap(
        jsonResponse,
      );
      if (sheetMap == null) {
        return null;
      }

      return SheetModel.fromJson(_withCurrentUserPurchaseFlag(sheetMap));
    } catch (e) {
      debugPrint('Error fetching sheet by id: $e');
      return null;
    }
  }

  static Future<bool> paymentSheet({required SheetPaymentData data}) async {
    debugPrint(
      'paymentSheet is not supported by current backend routes: ${data.sheetId}',
    );
    return false;
  }

  static Future<List<SheetModel>> fetchSheetsByUserId(String userId) async {
    if (userId.isEmpty) {
      return [];
    }

    final storage = GetStorage();
    final String? token = storage.read('token')?.toString();

    try {
      final response = await http.get(
        _buildUri('/sheets/user/$userId'),
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        final List<dynamic> rawSheets = _extractSheetsList(jsonResponse);

        return rawSheets
            .whereType<Map>()
            .map(
              (item) => SheetModel.fromJson(
                _withCurrentUserPurchaseFlag(Map<String, dynamic>.from(item)),
              ),
            )
            .toList();
      }

      if (response.statusCode == 404) {
        return [];
      }

      throw Exception('Failed to load user sheets: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching sheets by user id: $e');
      throw Exception('Failed to load user sheets: $e');
    }
  }

  static Future<SheetActionResult> updateSheet({
    required String sheetId,
    required String title,
    required String description,
    required double price,
  }) async {
    debugPrint(
      'updateSheet is not supported by current backend routes: $sheetId',
    );
    return const SheetActionResult(
      success: false,
      message: 'แบ็กเอนด์เวอร์ชันปัจจุบันยังไม่รองรับการแก้ไขชีต',
    );
  }

  static Future<SheetActionResult> deleteSheet({
    required String sheetId,
    int buyerCount = 0,
  }) async {
    if (buyerCount > 0) {
      return const SheetActionResult(
        success: false,
        message: 'ไม่สามารถลบชีตนี้ได้ เพราะมีผู้ซื้อแล้ว',
      );
    }

    final storage = GetStorage();
    final String? token = storage.read('token')?.toString();

    if (token == null || token.isEmpty) {
      return const SheetActionResult(
        success: false,
        message: 'ไม่พบ token สำหรับยืนยันตัวตน',
      );
    }

    try {
      final headers = {'Authorization': 'Bearer $token'};

      final response = await http.delete(
        _buildUri('/sheets/$sheetId'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return const SheetActionResult(
          success: true,
          message: 'ลบชีตสำเร็จ (response 204)',
        );
      }

      if (response.statusCode == 404) {
        return const SheetActionResult(
          success: false,
          message: 'ไม่พบชีตนี้ (response 404)',
        );
      }

      if (response.statusCode == 409) {
        return const SheetActionResult(
          success: false,
          message: 'ไม่สามารถลบชีตนี้ได้ เพราะมีผู้ซื้อแล้ว',
        );
      }

      return SheetActionResult(
        success: false,
        message: _extractApiErrorMessage(
          response,
          fallbackMessage: 'ไม่สามารถลบชีตได้',
        ),
      );
    } catch (e) {
      debugPrint('Error deleting sheet: $e');
      return const SheetActionResult(
        success: false,
        message: 'เกิดข้อผิดพลาดระหว่างลบชีต',
      );
    }
  }
}

Map<String, dynamic> _withCurrentUserPurchaseFlag(Map<String, dynamic> source) {
  if (source['is_purchased'] != null) {
    return source;
  }

  final String currentUid = GetStorage().read('uid')?.toString() ?? '';
  if (currentUid.isEmpty) {
    return source;
  }

  bool isPurchased = false;
  final dynamic buyers = source['buyers'];

  if (buyers is List) {
    isPurchased = buyers.whereType<Map>().any((buyer) {
      final map = Map<String, dynamic>.from(buyer);
      final String? buyerId =
          map['id']?.toString() ?? map['user_id']?.toString();
      return buyerId != null && buyerId == currentUid;
    });
  } else if (buyers is Map && buyers['uid'] is List) {
    final buyerUids = (buyers['uid'] as List).map((e) => e.toString()).toList();
    isPurchased = buyerUids.contains(currentUid);
  }

  return <String, dynamic>{...source, 'is_purchased': isPurchased};
}

String _extractApiErrorMessage(
  http.Response response, {
  required String fallbackMessage,
}) {
  try {
    final dynamic decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final dynamic error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final dynamic message = error['message'];
        if (message is Map<String, dynamic>) {
          final String? th = message['th']?.toString();
          if (th != null && th.isNotEmpty) return th;
          final String? en = message['en']?.toString();
          if (en != null && en.isNotEmpty) return en;
        }
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }

      final dynamic message = decoded['message'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }
  } catch (_) {}

  return fallbackMessage;
}

List<dynamic> _extractSheetsList(dynamic responseBody) {
  if (responseBody is List) {
    return responseBody;
  }

  if (responseBody is! Map<String, dynamic>) {
    return [];
  }

  final dynamic data = responseBody['data'];
  if (data is Map<String, dynamic>) {
    if (data['sheets'] is List) {
      return data['sheets'] as List<dynamic>;
    }
    if (data['sheet'] is List) {
      return data['sheet'] as List<dynamic>;
    }
  }

  if (data is List) {
    return data;
  }

  if (responseBody['sheets'] is List) {
    return responseBody['sheets'] as List<dynamic>;
  }
  if (responseBody['sheet'] is List) {
    return responseBody['sheet'] as List<dynamic>;
  }

  return [];
}

Map<String, dynamic>? _extractSingleSheetMap(dynamic responseBody) {
  if (responseBody is! Map<String, dynamic>) {
    return null;
  }

  final dynamic data = responseBody['data'];

  if (data is Map<String, dynamic>) {
    if (data['sheet'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['sheet']);
    }
    if (data['sheet'] is List && (data['sheet'] as List).isNotEmpty) {
      return Map<String, dynamic>.from((data['sheet'] as List).first as Map);
    }
    if (data['id'] != null) {
      return Map<String, dynamic>.from(data);
    }
  }

  if (data is List && data.isNotEmpty) {
    return Map<String, dynamic>.from(data.first as Map);
  }

  if (responseBody['sheet'] is Map<String, dynamic>) {
    return Map<String, dynamic>.from(responseBody['sheet']);
  }

  if (responseBody['sheet'] is List &&
      (responseBody['sheet'] as List).isNotEmpty) {
    return Map<String, dynamic>.from(
      (responseBody['sheet'] as List).first as Map,
    );
  }

  if (responseBody['id'] != null) {
    return Map<String, dynamic>.from(responseBody);
  }

  return null;
}
