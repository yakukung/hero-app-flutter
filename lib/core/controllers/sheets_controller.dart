import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_application_1/core/models/sheet_model.dart';
import 'package:flutter_application_1/core/models/category_model.dart';
import 'package:flutter_application_1/core/services/sheets.service.dart';

class SheetsController extends GetxController {
  SheetsController({GetStorage? storage}) : _storage = storage ?? GetStorage();

  var sheets = <SheetModel>[].obs;
  var favoriteSheets = <SheetModel>[].obs;
  var categories = <CategoryModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final GetStorage _storage;

  Future<void> fetchFavorites({bool showLoading = false}) async {
    final String? token = _storage.read('token')?.toString();

    if (showLoading) {
      isLoading.value = true;
      errorMessage.value = '';
    }

    if (token == null || token.isEmpty) {
      favoriteSheets.assignAll([]);
      _syncFavoriteFlags();
      if (showLoading) {
        isLoading.value = false;
      }
      return;
    }

    try {
      final favorites = await SheetsService.fetchFavorites(token: token);
      favoriteSheets.assignAll(favorites);
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
      final String? token = _storage.read('token')?.toString();

      if (token != null && token.isNotEmpty) {
        await fetchFavorites();
      }

      final List<SheetModel> newSheets = await SheetsService.fetchSheets(
        token: token,
      );
      sheets.assignAll(_mergeFavorites(newSheets));
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
    final String? token = _storage.read('token')?.toString();
    if (token == null || token.isEmpty) return false;
    try {
      final bool success = await SheetsService.addFavorite(
        sheetId,
        token: token,
      );
      if (success) {
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
    final String? token = _storage.read('token')?.toString();
    if (token == null || token.isEmpty) return false;
    try {
      final bool success = await SheetsService.removeFavorite(
        sheetId,
        token: token,
      );
      if (success) {
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
      final String? token = _storage.read('token')?.toString();
      final fetchedCategories = await SheetsService.fetchCategories(
        token: token,
      );
      categories.assignAll(fetchedCategories);
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return;
    }
  }

  List<SheetModel> searchSheets(String query) {
    if (query.isEmpty) return sheets.toList();
    final lowerQuery = query.toLowerCase();
    final matchingCategoryKeys = categories
        .where((cat) => cat.name.toLowerCase().contains(lowerQuery))
        .expand((cat) => [cat.id, cat.name])
        .map((key) => key.toLowerCase())
        .toSet();
    return sheets.where((sheet) {
      final titleMatches = sheet.title.toLowerCase().contains(lowerQuery);
      final categoryMatches =
          sheet.categoryIds?.any(
            (id) => matchingCategoryKeys.contains(id.toLowerCase()),
          ) ??
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
