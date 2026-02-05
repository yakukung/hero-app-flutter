import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/services/sheets.service.dart';
import 'package:flutter_application_1/widgets/product/product_card.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/pages/user/sheet/preview_sheet.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<SheetData>(
        builder: (context, sheetData, child) {
          final allSheets = sheetData.sheets;

          // Filter favorite products
          // Note: is_favorite is currently not a field in SheetModel in the DB dump
          // but we'll use a placeholder or check how it was used before.
          // For now, let's assume all sheets in this view are favorites or handled by a separate list.
          // For now, let's assume all sheets in this view are favorites or handled by a separate list.
          final favoriteSheets = allSheets;

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ชีตโปรด',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'รายการที่คุณติดดาวจะอยู่ที่นี่',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.grey[200], thickness: 1),
                      ],
                    ),
                  ),
                ),
                if (favoriteSheets.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ยังไม่มีรายการโปรด',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final sheet = favoriteSheets[index];
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
                              isFavorite: true,
                            ),
                            colorIndex: index, // Use gradient instead
                            onFavoriteTap: () {
                              sheetData.toggleFavorite(sheet.id);
                            },
                          ),
                        );
                      }, childCount: favoriteSheets.length),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}
