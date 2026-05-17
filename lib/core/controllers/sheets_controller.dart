import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/models/category_model.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/services/sheets_service.dart';
import 'package:hero_app_flutter/core/services/preferences_service.dart';
import 'package:hero_app_flutter/core/services/recommendation_service.dart';

class SheetsController extends GetxController {
  SheetsController({GetStorage? storage, SessionStore? sessionStore})
    : _sessionStore = sessionStore ?? SessionStore(storage: storage);

  var sheets = <SheetModel>[].obs;
  var favoriteSheets = <SheetModel>[].obs;
  var backendRecommendedSheets = <SheetModel>[].obs;
  var categories = <CategoryModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final SessionStore _sessionStore;

  Future<void> fetchFavorites({bool showLoading = false}) async {
    final String token = _sessionStore.token;

    if (showLoading) {
      isLoading.value = true;
      errorMessage.value = '';
    }

    if (token.isEmpty) {
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
      final String token = _sessionStore.token;

      if (token.isNotEmpty) {
        await fetchFavorites();
      }

      final List<SheetModel> newSheets = await SheetsService.fetchSheets(
        token: token.isNotEmpty ? token : null,
      );
      sheets.assignAll(_mergeFavorites(newSheets));
      await fetchBackendRecommendations();
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

  Future<void> fetchBackendRecommendations() async {
    try {
      final result = await RecommendationService.fetchRecommendations();
      final recommendations = result.data ?? const <SheetModel>[];
      if (!result.success || recommendations.isEmpty) {
        backendRecommendedSheets.clear();
        return;
      }

      backendRecommendedSheets.assignAll(
        _mergeFavorites(_hydrateRecommendedSheets(recommendations)),
      );
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');
      backendRecommendedSheets.clear();
    }
  }

  Future<bool> addFavorite(String sheetId) async {
    final String token = _sessionStore.token;
    if (token.isEmpty) return false;
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
    final String token = _sessionStore.token;
    if (token.isEmpty) return false;
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
      final String token = _sessionStore.token;
      final fetchedCategories = await SheetsService.fetchCategories(
        token: token.isNotEmpty ? token : null,
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
      final descriptionMatches =
          sheet.description?.toLowerCase().contains(lowerQuery) ?? false;
      final authorMatches =
          sheet.authorName?.toLowerCase().contains(lowerQuery) ?? false;
      final keywordMatches =
          sheet.keywordIds?.any(
            (id) => id.toLowerCase().contains(lowerQuery),
          ) ??
          false;
      final categoryMatches =
          sheet.categoryIds?.any(
            (id) => matchingCategoryKeys.contains(id.toLowerCase()),
          ) ??
          false;
      return titleMatches ||
          descriptionMatches ||
          authorMatches ||
          keywordMatches ||
          categoryMatches;
    }).toList();
  }

  List<SheetModel> get popularSheets {
    final sorted = sheets.toList()
      ..sort((a, b) {
        final ratingCompare = (b.rating ?? 0).compareTo(a.rating ?? 0);
        if (ratingCompare != 0) return ratingCompare;
        return b.buyerCount.compareTo(a.buyerCount);
      });
    return sorted;
  }

  List<SheetModel> get newestSheets {
    return sheets.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<SheetModel> recommendedSheets({PreferencesService? preferencesService}) {
    if (backendRecommendedSheets.isNotEmpty) {
      return backendRecommendedSheets.toList();
    }

    final preferences = (preferencesService ?? PreferencesService()).load();
    if (preferences.isEmpty) {
      return popularSheets;
    }

    final keywords = preferences.keywords.map((e) => e.toLowerCase()).toSet();
    final subjects = preferences.subjects.map((e) => e.toLowerCase()).toSet();
    final filtered = sheets.where((sheet) {
      final keywordMatches =
          sheet.keywordIds?.any((keyword) {
            final lower = keyword.toLowerCase();
            return keywords.any((preference) => lower.contains(preference));
          }) ??
          false;
      final subjectMatches =
          sheet.categoryIds?.any((subject) {
            final lower = subject.toLowerCase();
            return subjects.any((preference) => lower.contains(preference));
          }) ??
          false;
      return keywordMatches || subjectMatches;
    }).toList();

    if (filtered.isEmpty) {
      return popularSheets;
    }
    return filtered..sort((a, b) {
      final ratingCompare = (b.rating ?? 0).compareTo(a.rating ?? 0);
      if (ratingCompare != 0) return ratingCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  void resetState() {
    sheets.clear();
    favoriteSheets.clear();
    backendRecommendedSheets.clear();
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
    if (backendRecommendedSheets.isNotEmpty) {
      backendRecommendedSheets.assignAll(
        _mergeFavorites(backendRecommendedSheets),
      );
    }
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

    final int recommendedIndex = backendRecommendedSheets.indexWhere(
      (sheet) => sheet.id == sheetId,
    );
    if (recommendedIndex != -1) {
      backendRecommendedSheets[recommendedIndex] = _copySheet(
        backendRecommendedSheets[recommendedIndex],
        isFavorite: isFavorite,
      );
    }
  }

  SheetModel _copyWithFavoriteState(SheetModel sheet, bool isFavorite) {
    return _copySheet(sheet, isFavorite: isFavorite);
  }

  void markPurchased(String sheetId) {
    _updatePurchaseState(sheets, sheetId);
    _updatePurchaseState(favoriteSheets, sheetId);
    _updatePurchaseState(backendRecommendedSheets, sheetId);
  }

  void _updatePurchaseState(RxList<SheetModel> source, String sheetId) {
    final index = source.indexWhere((sheet) => sheet.id == sheetId);
    if (index != -1) {
      source[index] = _copySheet(source[index], isPurchased: true);
    }
  }

  List<SheetModel> _hydrateRecommendedSheets(List<SheetModel> source) {
    return source.map((recommendation) {
      final cachedIndex = sheets.indexWhere(
        (sheet) => sheet.id == recommendation.id,
      );
      if (cachedIndex == -1) {
        return recommendation;
      }
      return sheets[cachedIndex];
    }).toList();
  }

  SheetModel _copySheet(
    SheetModel sheet, {
    bool? isFavorite,
    bool? isPurchased,
  }) {
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
      isPurchased: isPurchased ?? sheet.isPurchased,
      isFavorite: isFavorite ?? sheet.isFavorite,
    );
  }
}
