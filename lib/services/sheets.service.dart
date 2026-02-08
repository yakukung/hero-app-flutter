import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/sheet_model.dart';
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
      return false;
    }
  }
}

class SheetData extends ChangeNotifier {
  List<SheetModel> _sheets = [];
  List<SheetModel> _favoriteSheets = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<SheetModel> get sheets => _sheets;
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

      log('Favorites response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('Favorites response body: ${response.body}');
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']['sheets'];
        _favoriteSheets = data
            .map((item) => SheetModel.fromJson(item))
            .toList();
      } else if (response.statusCode == 404) {
        log('No favorites found (404)');
        _favoriteSheets = [];
      } else {
        log('Favorites response error body: ${response.body}');
      }
    } catch (e) {
      log('Fetch favorites error: $e');
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
        log('Sheets response: ${response.body}');
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
      log('Sheet API error: $e');
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
        log('Sheets (refresh) response: ${response.body}');
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
              isPurchased: sheet.isPurchased,
              isFavorite: isFavorited,
            );
          }
          return sheet;
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      log('Refresh error: $e');
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
      log('Add favorite error: $e');
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
      log('Remove favorite error: $e');
      return false;
    }
  }

  void toggleFavorite(String sheetId) {
    final index = _sheets.indexWhere((element) => element.id == sheetId);
    if (index != -1) {}
  }
}
