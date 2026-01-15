import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/services/product_data.dart';
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
      body: Consumer<ProductData>(
        builder: (context, productData, child) {
          final allProducts = productData.products;

          // Filter favorite products
          final favoriteProducts = allProducts.where((p) {
            final isFav = p['is_favorite'];
            if (isFav is int) return isFav == 1;
            if (isFav is bool) return isFav;
            return false;
          }).toList();

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
                if (favoriteProducts.isEmpty)
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
                        final productMap = favoriteProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              () => PreviewSheetPage(
                                productId: productMap['id'].toString(),
                              ),
                            );
                          },
                          child: ProductCard(
                            product: Product(
                              imageUrl: (productMap['imageUrl'] != null)
                                  ? productMap['imageUrl']
                                        .toString()
                                        .replaceAll('`', '')
                                        .trim()
                                  : null,
                              title: productMap['title'] ?? '',
                              author: productMap['author'] ?? '',
                              rating: (productMap['rating'] ?? 0).toDouble(),
                              price: productMap['price'] == 0
                                  ? 'ฟรี'
                                  : '${productMap['price']} บาท',
                              isFavorite: true,
                            ),
                            colorIndex: index, // Use gradient instead
                            onFavoriteTap: () {
                              productData.toggleFavorite(
                                productMap['id'].toString(),
                              );
                            },
                          ),
                        );
                      }, childCount: favoriteProducts.length),
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
