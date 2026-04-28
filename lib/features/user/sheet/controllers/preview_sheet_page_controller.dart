import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/services/sheets_service.dart';
import 'package:hero_app_flutter/core/session/app_session_coordinator.dart';

typedef FetchSheetById = Future<SheetModel?> Function(String sheetId);

class PreviewSheetFavoriteResult {
  const PreviewSheetFavoriteResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

class PreviewSheetPageController extends ChangeNotifier {
  PreviewSheetPageController({
    required this.sheetId,
    SheetsController? sheetsController,
    AppSessionCoordinator? sessionCoordinator,
    FetchSheetById? fetchSheetById,
  }) : _sheetsController = sheetsController ?? Get.find<SheetsController>(),
       _sessionCoordinator = sessionCoordinator ?? AppSessionCoordinator(),
       _fetchSheetById = fetchSheetById ?? SheetsService.fetchSheetById;

  final String sheetId;
  final SheetsController _sheetsController;
  final AppSessionCoordinator _sessionCoordinator;
  final FetchSheetById _fetchSheetById;

  SheetModel? _sheet;
  bool _isLoading = true;
  String _errorMessage = '';
  List<String> _previewImages = const [];

  SheetModel? get sheet => _sheet;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<String> get previewImages => _previewImages;
  String get currentUserId => _sessionCoordinator.currentUserId;
  bool get isOwner => _sheet != null && _sheet!.authorId == currentUserId;
  bool get canReadFull {
    final isFree = (_sheet?.price ?? 0) == 0;
    final isPurchased = _sheet?.isPurchased ?? false;
    return isOwner || isFree || isPurchased;
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (_sessionCoordinator.isAuthenticated &&
          _sheetsController.favoriteSheets.isEmpty) {
        await _sheetsController.fetchFavorites();
      }

      final fetchedSheet = await _fetchSheetById(sheetId);
      if (fetchedSheet == null) {
        _errorMessage = 'Failed to load sheet';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final isFavorited = _sheetsController.favoriteSheets.any(
        (favorite) => favorite.id == fetchedSheet.id,
      );
      final previewImages =
          fetchedSheet.files
              ?.map((file) => file.fullOriginalUrl)
              .take(2)
              .toList() ??
          const <String>[];

      _sheet = _copyWithFavoriteState(fetchedSheet, isFavorited);
      _previewImages = previewImages;
    } catch (error) {
      debugPrint('Error fetching sheet details: $error');
      _errorMessage = 'Error: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PreviewSheetFavoriteResult> toggleFavorite() async {
    final currentSheet = _sheet;
    if (currentSheet == null) {
      return const PreviewSheetFavoriteResult(
        success: false,
        message: 'ไม่พบข้อมูลชีต',
      );
    }

    final isCurrentlyFavorite = currentSheet.isFavorite;
    final success = isCurrentlyFavorite
        ? await _sheetsController.removeFavorite(currentSheet.id)
        : await _sheetsController.addFavorite(currentSheet.id);

    if (!success) {
      return const PreviewSheetFavoriteResult(
        success: false,
        message: 'เกิดข้อผิดพลาด กรุณาลองใหม่',
      );
    }

    _sheet = _copyWithFavoriteState(currentSheet, !isCurrentlyFavorite);
    notifyListeners();
    return PreviewSheetFavoriteResult(
      success: true,
      message: isCurrentlyFavorite
          ? 'ลบจากรายการโปรดแล้ว'
          : 'เพิ่มเป็นรายการโปรดแล้ว',
    );
  }

  SheetModel _copyWithFavoriteState(SheetModel source, bool isFavorite) {
    return SheetModel(
      id: source.id,
      authorId: source.authorId,
      title: source.title,
      description: source.description,
      rating: source.rating,
      price: source.price,
      visibleFlag: source.visibleFlag,
      statusFlag: source.statusFlag,
      createdAt: source.createdAt,
      createdBy: source.createdBy,
      updatedAt: source.updatedAt,
      updatedBy: source.updatedBy,
      authorName: source.authorName,
      authorAvatar: source.authorAvatar,
      files: source.files,
      questions: source.questions,
      categoryIds: source.categoryIds,
      keywordIds: source.keywordIds,
      buyerCount: source.buyerCount,
      isPurchased: source.isPurchased,
      isFavorite: isFavorite,
    );
  }
}
