import 'package:flutter/material.dart';
import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/models/product_model.dart';
import 'package:hero_app_flutter/features/user/sheet/preview_sheet_page.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:hero_app_flutter/shared/widgets/product/product_card.dart';
import 'package:get/get.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const SearchResultsPage({super.key, required this.searchQuery});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final SheetsController _sheetsController = Get.find<SheetsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sheetsController.sheets.isEmpty) {
        _sheetsController.fetchSheets();
      }
      _sheetsController.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ผลการค้นหา: "${widget.searchQuery}"',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final results = _sheetsController.searchSheets(widget.searchQuery);

        if (_sheetsController.isLoading.value && results.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (results.isEmpty) {
          return const Center(
            child: Text(
              'ไม่พบผลลัพธ์การค้นหา',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final sheet = results[index];
            return GestureDetector(
              onTap: () {
                Get.to(() => PreviewSheetPage(sheetId: sheet.id));
              },
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
                onFavoriteTap: () {
                  final isCurrentlyFavorite = sheet.isFavorite;
                  showCustomDialog(
                    title: isCurrentlyFavorite
                        ? 'นำออกจากรายการโปรด'
                        : 'เพิ่มเป็นรายการโปรด',
                    message: isCurrentlyFavorite
                        ? 'คุณต้องการลบจากรายการโปรดไหม'
                        : 'คุณยืนยันที่จะเพิ่มเป็นรายการโปรดไหม',
                    isConfirm: true,
                    onOk: () async {
                      final success = isCurrentlyFavorite
                          ? await _sheetsController.removeFavorite(sheet.id)
                          : await _sheetsController.addFavorite(sheet.id);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? (isCurrentlyFavorite
                                      ? 'ลบจากรายการโปรดแล้ว'
                                      : 'เพิ่มเป็นรายการโปรดแล้ว')
                                : 'เกิดข้อผิดพลาด กรุณาลองใหม่',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
