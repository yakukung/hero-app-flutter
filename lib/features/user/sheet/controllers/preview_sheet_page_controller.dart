import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/models/payment_history_model.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
import 'package:hero_app_flutter/core/services/payment_service.dart';
import 'package:hero_app_flutter/core/services/reviews_service.dart';
import 'package:hero_app_flutter/core/services/sheets_service.dart';
import 'package:hero_app_flutter/core/session/app_session_coordinator.dart';

typedef FetchSheetById = Future<SheetModel?> Function(String sheetId);
typedef PurchaseSheet =
    Future<ServiceResult<SheetPurchaseResult>> Function({
      required String sheetId,
      required double amount,
    });
typedef FetchSheetReviews =
    Future<ServiceResult<List<SheetReviewModel>>> Function(String sheetId);
typedef SubmitSheetReview =
    Future<ServiceResult<SheetReviewModel?>> Function({
      required String sheetId,
      required int score,
      required String content,
    });

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
    PurchaseSheet? purchaseSheet,
    FetchSheetReviews? fetchReviews,
    SubmitSheetReview? submitReview,
  }) : _sheetsController = sheetsController ?? Get.find<SheetsController>(),
       _sessionCoordinator = sessionCoordinator ?? AppSessionCoordinator(),
       _fetchSheetById = fetchSheetById ?? SheetsService.fetchSheetById,
       _purchaseSheet = purchaseSheet ?? PaymentService.purchaseSheet,
       _fetchReviews = fetchReviews ?? ReviewsService.fetchSheetReviews,
       _submitReview = submitReview ?? ReviewsService.submitSheetReview;

  final String sheetId;
  final SheetsController _sheetsController;
  final AppSessionCoordinator _sessionCoordinator;
  final FetchSheetById _fetchSheetById;
  final PurchaseSheet _purchaseSheet;
  final FetchSheetReviews _fetchReviews;
  final SubmitSheetReview _submitReview;

  SheetModel? _sheet;
  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _isLoadingReviews = false;
  String _errorMessage = '';
  String _reviewErrorMessage = '';
  List<String> _previewImages = const [];
  List<SheetReviewModel> _reviews = const [];

  SheetModel? get sheet => _sheet;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  bool get isLoadingReviews => _isLoadingReviews;
  String get errorMessage => _errorMessage;
  String get reviewErrorMessage => _reviewErrorMessage;
  List<String> get previewImages => _previewImages;
  List<SheetReviewModel> get reviews => _reviews;
  String get currentUserId => _sessionCoordinator.currentUserId;
  bool get isOwner => _sheet != null && _sheet!.authorId == currentUserId;
  bool get hasPremiumAccess => _sessionCoordinator.hasPremiumAccess;
  bool get canReadFull {
    final isFree = (_sheet?.price ?? 0) == 0;
    final isPurchased = _sheet?.isPurchased ?? false;
    return isOwner || isFree || isPurchased || hasPremiumAccess;
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
              .take(3)
              .toList() ??
          const <String>[];

      _sheet = _copyWithFavoriteState(fetchedSheet, isFavorited);
      _previewImages = previewImages;
      await loadReviews();
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

  Future<PreviewSheetFavoriteResult> purchase() async {
    final currentSheet = _sheet;
    if (currentSheet == null) {
      return const PreviewSheetFavoriteResult(
        success: false,
        message: 'ไม่พบข้อมูลชีต',
      );
    }
    if (!_sessionCoordinator.isAuthenticated) {
      return const PreviewSheetFavoriteResult(
        success: false,
        message: 'กรุณาเข้าสู่ระบบก่อนซื้อชีต',
      );
    }

    _isPurchasing = true;
    notifyListeners();
    final result = await _purchaseSheet(
      sheetId: currentSheet.id,
      amount: currentSheet.price ?? 0,
    );
    _isPurchasing = false;

    if (result.success) {
      _sheet = _copyWithPurchaseState(
        currentSheet,
        isPurchased: result.data?.isPurchased ?? true,
      );
      _sheetsController.markPurchased(currentSheet.id);
      notifyListeners();
      await _sessionCoordinator.refreshCurrentUserData();
      return const PreviewSheetFavoriteResult(
        success: true,
        message: 'ซื้อชีตสำเร็จ',
      );
    }

    notifyListeners();
    return PreviewSheetFavoriteResult(success: false, message: result.message);
  }

  Future<void> loadReviews() async {
    _isLoadingReviews = true;
    _reviewErrorMessage = '';
    notifyListeners();
    final result = await _fetchReviews(sheetId);
    _isLoadingReviews = false;
    _reviews = result.data ?? const [];
    _reviewErrorMessage = result.success ? '' : result.message;
    notifyListeners();
  }

  Future<PreviewSheetFavoriteResult> submitReview({
    required int score,
    required String content,
  }) async {
    final result = await _submitReview(
      sheetId: sheetId,
      score: score,
      content: content,
    );
    if (result.success) {
      await loadReviews();
      return const PreviewSheetFavoriteResult(
        success: true,
        message: 'บันทึกรีวิวแล้ว',
      );
    }
    return PreviewSheetFavoriteResult(success: false, message: result.message);
  }

  SheetModel _copyWithFavoriteState(SheetModel source, bool isFavorite) {
    return _copySheet(source, isFavorite: isFavorite);
  }

  SheetModel _copyWithPurchaseState(
    SheetModel source, {
    required bool isPurchased,
  }) {
    return _copySheet(source, isPurchased: isPurchased);
  }

  SheetModel _copySheet(
    SheetModel source, {
    bool? isFavorite,
    bool? isPurchased,
  }) {
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
      isPurchased: isPurchased ?? source.isPurchased,
      isFavorite: isFavorite ?? source.isFavorite,
    );
  }
}
