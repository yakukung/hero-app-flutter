import 'package:get/get.dart';

import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';

typedef FavoriteSheetAction = Future<bool> Function(String sheetId);

class HomeFavoriteActionResult {
  const HomeFavoriteActionResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

class HomePageController {
  HomePageController({
    SheetsController? sheetsController,
    FavoriteSheetAction? addFavorite,
    FavoriteSheetAction? removeFavorite,
  }) : _sheetsController = sheetsController ?? Get.find<SheetsController>(),
       _addFavorite = addFavorite,
       _removeFavorite = removeFavorite;

  final SheetsController _sheetsController;
  final FavoriteSheetAction? _addFavorite;
  final FavoriteSheetAction? _removeFavorite;

  SheetsController get sheetsController => _sheetsController;

  Future<void> load() => _sheetsController.fetchSheets();

  Future<void> refresh() => _sheetsController.refreshSheets();

  Future<HomeFavoriteActionResult> toggleFavorite(SheetModel sheet) async {
    final isCurrentlyFavorite = sheet.isFavorite;
    final success = isCurrentlyFavorite
        ? await (_removeFavorite ?? _sheetsController.removeFavorite)(sheet.id)
        : await (_addFavorite ?? _sheetsController.addFavorite)(sheet.id);

    return HomeFavoriteActionResult(
      success: success,
      message: success
          ? (isCurrentlyFavorite
                ? 'ลบจากรายการโปรดแล้ว'
                : 'เพิ่มเป็นรายการโปรดแล้ว')
          : 'เกิดข้อผิดพลาด กรุณาลองใหม่',
    );
  }
}
