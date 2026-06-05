import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/models/product_model.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/shared/widgets/product/product_card.dart';

enum HomeSheetListType { recommended, popular, newest }

class HomeSheetListPage extends StatelessWidget {
  const HomeSheetListPage({
    super.key,
    required this.title,
    required this.listType,
    required this.sheetsController,
    required this.onOpenSheet,
    required this.onFavoriteTap,
  });

  final String title;
  final HomeSheetListType listType;
  final SheetsController sheetsController;
  final ValueChanged<SheetModel> onOpenSheet;
  final ValueChanged<SheetModel> onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final sheets = _resolveSheets();

        if (sheetsController.isLoading.value && sheets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (sheets.isEmpty) {
          return const Center(
            child: Text(
              'ไม่พบชีต',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: sheets.length,
          itemBuilder: (context, index) {
            final sheet = sheets[index];
            return GestureDetector(
              onTap: () => onOpenSheet(sheet),
              child: ProductCard(
                product: Product(
                  id: sheet.id,
                  imageUrl: sheet.thumbnail,
                  title: sheet.title,
                  author: sheet.authorName ?? 'Unknown',
                  rating: sheet.rating ?? 0.0,
                  price: sheet.price == 0 || sheet.price == null
                      ? 'ฟรี'
                      : '${sheet.price} บาท',
                  isFavorite: sheet.isFavorite,
                ),
                colorIndex: index,
                onFavoriteTap: () => onFavoriteTap(sheet),
              ),
            );
          },
        );
      }),
    );
  }

  List<SheetModel> _resolveSheets() {
    return switch (listType) {
      HomeSheetListType.recommended => sheetsController.recommendedSheets(),
      HomeSheetListType.popular => sheetsController.popularSheets,
      HomeSheetListType.newest => sheetsController.newestSheets,
    };
  }
}
