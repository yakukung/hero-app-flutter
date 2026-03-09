import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/sheet_model.dart';
import 'package:flutter_application_1/models/category_model.dart';
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
  static Future<bool> paymentSheet({required SheetPaymentData data}) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    try {
      if (token == null) {
        return false;
      }
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiEndpoint/sheets/payment'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['sheetId'] = data.sheetId;
      request.fields['sheetTable'] = data.sheetTable;
      request.fields['paymentMethod'] = data.paymentMethod;
      request.fields['amount'] = data.amount.toString();
      request.fields['currency'] = data.currency;

      for (var file in data.slipImage) {
        request.files.add(
          await http.MultipartFile.fromPath('slipImage', file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error processing sheet payment: $e');
      return false;
    }
  }

  static Future<List<SheetModel>> fetchSheetsByUserId(String userId) async {
    if (userId.isEmpty) {
      return [];
    }

    final storage = GetStorage();
    final String? token = storage.read('token')?.toString();

    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/sheets/user/$userId'),
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
            .map((item) => SheetModel.fromJson(Map<String, dynamic>.from(item)))
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
    final storage = GetStorage();
    final String? token = storage.read('token')?.toString();

    if (token == null || token.isEmpty) {
      return const SheetActionResult(
        success: false,
        message: 'ไม่พบ token สำหรับยืนยันตัวตน',
      );
    }

    try {
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final payload = jsonEncode({
        'title': title,
        'description': description,
        'price': price,
      });

      var response = await http.patch(
        Uri.parse('$apiEndpoint/sheets/$sheetId'),
        headers: headers,
        body: payload,
      );

      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await http.patch(
          Uri.parse('$apiEndpoint/sheets/update/$sheetId'),
          headers: headers,
          body: payload,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const SheetActionResult(
          success: true,
          message: 'แก้ไขชีตสำเร็จ',
        );
      }

      return SheetActionResult(
        success: false,
        message: _extractApiErrorMessage(
          response,
          fallbackMessage: 'ไม่สามารถแก้ไขชีตได้',
        ),
      );
    } catch (e) {
      debugPrint('Error updating sheet: $e');
      return const SheetActionResult(
        success: false,
        message: 'เกิดข้อผิดพลาดระหว่างแก้ไขชีต',
      );
    }
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
        Uri.parse('$apiEndpoint/sheets/$sheetId'),
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

class SheetData extends ChangeNotifier {
  List<SheetModel> _sheets = [];
  List<SheetModel> _favoriteSheets = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<SheetModel> get sheets => _sheets;
  List<CategoryModel> get categories => _categories;
  List<SheetModel> get favoriteSheets => _favoriteSheets;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchFavorites() async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    if (token == null) {
      _favoriteSheets = [];
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/sheets/favorites'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']['sheets'];
        _favoriteSheets = data
            .map((item) => SheetModel.fromJson(item))
            .toList();
      } else if (response.statusCode == 404) {
        _favoriteSheets = [];
      }
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
      _favoriteSheets = [];
    }
  }

  Future<void> fetchSheets({bool forceRefresh = false}) async {
    if (_sheets.isNotEmpty && !_isLoading && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final storage = GetStorage();
      final String? token = storage.read('token');

      // Fetch favorites first to have fresh data for mapping
      if (token != null) {
        await fetchFavorites();
      }

      final response = await http.get(
        Uri.parse('$apiEndpoint/sheets'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']['sheets'];

        final newSheets = data
            .map((item) => SheetModel.fromJson(item))
            .toList();

        // Cross-reference with favorites list to ensure isFavorite is accurate
        _sheets = newSheets.map((sheet) {
          final isFavorited = _favoriteSheets.any((fav) => fav.id == sheet.id);
          if (isFavorited != sheet.isFavorite) {
            return SheetModel(
              id: sheet.id,
              authorId: sheet.authorId,
              title: sheet.title,
              description: sheet.description,
              rating: sheet.rating,
              price: sheet.price,
              visibleFlag: sheet.visibleFlag,
              statusFlag: sheet.statusFlag,
              createdAt: sheet.createdAt,
              createdBy: sheet.createdBy,
              updatedAt: sheet.updatedAt,
              updatedBy: sheet.updatedBy,
              authorName: sheet.authorName,
              authorAvatar: sheet.authorAvatar,
              files: sheet.files,
              categoryIds: sheet.categoryIds,
              keywordIds: sheet.keywordIds,
              buyerCount: sheet.buyerCount,
              isPurchased: sheet.isPurchased,
              isFavorite: isFavorited,
            );
          }
          return sheet;
        }).toList();

        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load sheets: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching sheets: $e');
      _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSheets() async {
    try {
      final storage = GetStorage();
      final String? token = storage.read('token');

      if (token != null) {
        await fetchFavorites();
      }

      final response = await http.get(
        Uri.parse('$apiEndpoint/sheets'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']['sheets'];

        final newSheets = data
            .map((item) => SheetModel.fromJson(item))
            .toList();

        // Sync favorite status
        _sheets = newSheets.map((sheet) {
          final isFavorited = _favoriteSheets.any((fav) => fav.id == sheet.id);
          if (isFavorited != sheet.isFavorite) {
            return SheetModel(
              id: sheet.id,
              authorId: sheet.authorId,
              title: sheet.title,
              description: sheet.description,
              rating: sheet.rating,
              price: sheet.price,
              visibleFlag: sheet.visibleFlag,
              statusFlag: sheet.statusFlag,
              createdAt: sheet.createdAt,
              createdBy: sheet.createdBy,
              updatedAt: sheet.updatedAt,
              updatedBy: sheet.updatedBy,
              authorName: sheet.authorName,
              authorAvatar: sheet.authorAvatar,
              files: sheet.files,
              categoryIds: sheet.categoryIds,
              keywordIds: sheet.keywordIds,
              buyerCount: sheet.buyerCount,
              isPurchased: sheet.isPurchased,
              isFavorite: isFavorited,
            );
          }
          return sheet;
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing sheets: $e');
      return;
    }
  }

  Future<bool> addFavorite(String sheetId) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/sheets/sheet-favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'sheet_id': sheetId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = _sheets.indexWhere((element) => element.id == sheetId);
        if (index != -1) {
          final oldSheet = _sheets[index];
          final updatedSheet = SheetModel(
            id: oldSheet.id,
            authorId: oldSheet.authorId,
            title: oldSheet.title,
            description: oldSheet.description,
            rating: oldSheet.rating,
            price: oldSheet.price,
            visibleFlag: oldSheet.visibleFlag,
            statusFlag: oldSheet.statusFlag,
            createdAt: oldSheet.createdAt,
            createdBy: oldSheet.createdBy,
            updatedAt: oldSheet.updatedAt,
            updatedBy: oldSheet.updatedBy,
            authorName: oldSheet.authorName,
            authorAvatar: oldSheet.authorAvatar,
            files: oldSheet.files,
            categoryIds: oldSheet.categoryIds,
            keywordIds: oldSheet.keywordIds,
            buyerCount: oldSheet.buyerCount,
            isPurchased: oldSheet.isPurchased,
            isFavorite: true,
          );
          _sheets[index] = updatedSheet;

          // Also update _favoriteSheets list
          if (!_favoriteSheets.any((s) => s.id == sheetId)) {
            _favoriteSheets.add(updatedSheet);
          }

          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(String sheetId) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/sheets/sheet-unfavorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'sheet_id': sheetId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = _sheets.indexWhere((element) => element.id == sheetId);
        if (index != -1) {
          final oldSheet = _sheets[index];
          _sheets[index] = SheetModel(
            id: oldSheet.id,
            authorId: oldSheet.authorId,
            title: oldSheet.title,
            description: oldSheet.description,
            rating: oldSheet.rating,
            price: oldSheet.price,
            visibleFlag: oldSheet.visibleFlag,
            statusFlag: oldSheet.statusFlag,
            createdAt: oldSheet.createdAt,
            createdBy: oldSheet.createdBy,
            updatedAt: oldSheet.updatedAt,
            updatedBy: oldSheet.updatedBy,
            authorName: oldSheet.authorName,
            authorAvatar: oldSheet.authorAvatar,
            files: oldSheet.files,
            categoryIds: oldSheet.categoryIds,
            keywordIds: oldSheet.keywordIds,
            buyerCount: oldSheet.buyerCount,
            isPurchased: oldSheet.isPurchased,
            isFavorite: false,
          );

          _favoriteSheets.removeWhere((s) => s.id == sheetId);

          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      return false;
    }
  }

  void toggleFavorite(String sheetId) {
    final index = _sheets.indexWhere((element) => element.id == sheetId);
    if (index != -1) {}
  }

  Future<void> fetchCategories() async {
    try {
      final storage = GetStorage();
      final String? token = storage.read('token');

      final response = await http.get(
        Uri.parse('$apiEndpoint/categories'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']['categories'];
        _categories = data.map((item) => CategoryModel.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return;
    }
  }

  List<SheetModel> searchSheets(String query) {
    if (query.isEmpty) return _sheets;
    final lowerQuery = query.toLowerCase();

    // Find matching category IDs
    final matchingCategoryIds = _categories
        .where((cat) => cat.name.toLowerCase().contains(lowerQuery))
        .map((cat) => cat.id)
        .toSet();

    return _sheets.where((sheet) {
      final titleMatches = sheet.title.toLowerCase().contains(lowerQuery);
      final categoryMatches =
          sheet.categoryIds?.any((id) => matchingCategoryIds.contains(id)) ??
          false;
      return titleMatches || categoryMatches;
    }).toList();
  }
}
