import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/services/sheets.service.dart';
import 'package:flutter_application_1/widgets/product/product_card.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/pages/user/sheet/preview_sheet.dart';
import 'package:flutter_application_1/widgets/custom_dialog.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SheetData>(context, listen: false).fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<SheetData>(
        builder: (context, sheetData, child) {
          final favoriteSheets = sheetData.favoriteSheets;

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
                            colorIndex: index,
                            onFavoriteTap: () {
                              showCustomDialog(
                                title: 'นำออกจากรายการโปรด',
                                message: 'คุณต้องการลบจากรายการโปรดไหม',
                                isConfirm: true,
                                onOk: () async {
                                  final success = await sheetData
                                      .removeFavorite(sheet.id);
                                  if (mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'ลบจากรายการโปรดแล้ว',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
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
