import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';

import 'package:flutter_application_1/pages/user/sheet/preview_sheet.dart';
import 'package:flutter_application_1/services/sheets.service.dart';
import 'package:flutter_application_1/widgets/custom_dialog.dart';
import 'package:flutter_application_1/widgets/product/product_card.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const SearchResultsPage({super.key, required this.searchQuery});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SheetData>(context, listen: false).fetchCategories();
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
      body: Consumer<SheetData>(
        builder: (context, sheetData, child) {
          final results = sheetData.searchSheets(widget.searchQuery);

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
                        bool success;
                        if (isCurrentlyFavorite) {
                          success = await sheetData.removeFavorite(sheet.id);
                        } else {
                          success = await sheetData.addFavorite(sheet.id);
                        }

                        if (mounted) {
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
                        }
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
