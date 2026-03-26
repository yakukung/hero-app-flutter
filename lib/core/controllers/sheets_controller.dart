import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter_application_1/core/models/sheet_model.dart';
import 'package:flutter_application_1/core/models/category_model.dart';
import 'package:http/http.dart' as http;

class SheetsController extends GetxController {
  SheetsController({GetStorage? storage}) : _storage = storage ?? GetStorage();

  var sheets = <SheetModel>[].obs;
  var favoriteSheets = <SheetModel>[].obs;
  var categories = <CategoryModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final GetStorage _storage;

  Future<void> fetchFavorites({bool showLoading = false}) async {
    final String? token = _storage.read('token');

    if (showLoading) {
      isLoading.value = true;
      errorMessage.value = '';
    }

    if (token == null) {
      favoriteSheets.assignAll([]);
      _syncFavoriteFlags();
      if (showLoading) {
        isLoading.value = false;
      }
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
        favoriteSheets.assignAll(
          data.map((item) => SheetModel.fromJson(item)).toList(),
        );
      } else if (response.statusCode == 404) {
        favoriteSheets.assignAll([]);
      }
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
      favoriteSheets.assignAll([]);
    } finally {
      _syncFavoriteFlags();
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<void> fetchSheets({bool forceRefresh = false}) async {
    if (sheets.isNotEmpty && !forceRefresh && !isLoading.value) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final String? token = _storage.read('token');

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
        final List<SheetModel> newSheets = data
            .map((item) => SheetModel.fromJson(item))
            .toList();
        sheets.assignAll(_mergeFavorites(newSheets));
      } else {
        throw Exception('Failed to load sheets: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching sheets: $e');
      errorMessage.value = 'เกิดข้อผิดพลาด: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshSheets() async {
    await fetchSheets(forceRefresh: true);
  }

  Future<bool> addFavorite(String sheetId) async {
    final String? token = _storage.read('token');
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
        _updateFavoriteState(sheetId, isFavorite: true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(String sheetId) async {
    final String? token = _storage.read('token');
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
        _updateFavoriteState(sheetId, isFavorite: false);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      return false;
    }
  }

  Future<void> fetchCategories() async {
    if (categories.isNotEmpty) {
      return;
    }

    try {
      final String? token = _storage.read('token');
      final response = await http.get(
        Uri.parse('$apiEndpoint/categories'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']['categories'];
        categories.assignAll(
          data.map((item) => CategoryModel.fromJson(item)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return;
    }
  }

  List<SheetModel> searchSheets(String query) {
    if (query.isEmpty) return sheets.toList();
    final lowerQuery = query.toLowerCase();
    final matchingCategoryIds = categories
        .where((cat) => cat.name.toLowerCase().contains(lowerQuery))
        .map((cat) => cat.id)
        .toSet();
    return sheets.where((sheet) {
      final titleMatches = sheet.title.toLowerCase().contains(lowerQuery);
      final categoryMatches =
          sheet.categoryIds?.any((id) => matchingCategoryIds.contains(id)) ??
          false;
      return titleMatches || categoryMatches;
    }).toList();
  }

  void resetState() {
    sheets.clear();
    favoriteSheets.clear();
    categories.clear();
    isLoading.value = false;
    errorMessage.value = '';
  }

  List<SheetModel> _mergeFavorites(List<SheetModel> source) {
    return source
        .map(
          (sheet) => _copyWithFavoriteState(
            sheet,
            favoriteSheets.any((fav) => fav.id == sheet.id),
          ),
        )
        .toList();
  }

  void _syncFavoriteFlags() {
    if (sheets.isEmpty) {
      return;
    }

    sheets.assignAll(_mergeFavorites(sheets));
  }

  void _updateFavoriteState(String sheetId, {required bool isFavorite}) {
    final int sheetIndex = sheets.indexWhere((sheet) => sheet.id == sheetId);
    if (sheetIndex != -1) {
      final updatedSheet = _copyWithFavoriteState(
        sheets[sheetIndex],
        isFavorite,
      );
      sheets[sheetIndex] = updatedSheet;
    }

    final int favoriteIndex = favoriteSheets.indexWhere(
      (sheet) => sheet.id == sheetId,
    );

    if (isFavorite) {
      if (favoriteIndex == -1 && sheetIndex != -1) {
        favoriteSheets.add(sheets[sheetIndex]);
      }
    } else if (favoriteIndex != -1) {
      favoriteSheets.removeAt(favoriteIndex);
    }
  }

  SheetModel _copyWithFavoriteState(SheetModel sheet, bool isFavorite) {
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
      questions: sheet.questions,
      categoryIds: sheet.categoryIds,
      keywordIds: sheet.keywordIds,
      buyerCount: sheet.buyerCount,
      isPurchased: sheet.isPurchased,
      isFavorite: isFavorite,
    );
  }
}
