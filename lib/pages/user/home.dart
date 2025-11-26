import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/pages/user/sheet/preview_sheet.dart';
import 'package:flutter_application_1/widgets/product/product_card.dart';
import 'package:flutter_application_1/widgets/search/search_sheet_box.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:flutter_application_1/services/product_data.dart'; // Import the new ProductData

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<bool> isFavoriteList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Appdata>(context, listen: false).fetchUserData();
      Provider.of<ProductData>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductData>(
      builder: (context, productData, child) {
        final isLoading = productData.isLoading;
        final errorMessage = productData.errorMessage;
        final products = productData.products;
        final productColors = productData.productColors;

        // Initialize isFavoriteList based on products from provider
        if (isFavoriteList.length != products.length) {
          isFavoriteList = List<bool>.generate(
            products.length,
            (i) => products[i]['is_favorite'] == 1,
          );
        }

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: productData.fetchProducts,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A5DB9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'ลองใหม่',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : products.isEmpty
                    ? const Center(
                      child: Text(
                        'ไม่มีข้อมูลผลิตภัณฑ์',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 35),
                          const SearchSheetBox(),
                          const SizedBox(height: 35),
                          Row(
                            children: [
                              const SizedBox(width: 35),
                              Text(
                                'ชีตใหม่ล่าสุด',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                const SizedBox(width: 25),
                                for (int i = 0; i < products.length; i++)
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => PreviewSheetPage(
                                          productId:
                                              products[i]['id'].toString(),
                                        ),
                                      );
                                    },
                                    child: ProductCard(
                                      product: Product(
                                        imageUrl:
                                            (products[i]['imageUrl'] != null)
                                                ? products[i]['imageUrl']
                                                    .toString()
                                                    .replaceAll('`', '')
                                                    .trim()
                                                : null,
                                        title: products[i]['title'] ?? '',
                                        author: products[i]['author'] ?? '',
                                        rating:
                                            (products[i]['rating'] ?? 0)
                                                .toDouble(),
                                        price:
                                            products[i]['price'] == 0
                                                ? 'ฟรี'
                                                : products[i]['price']
                                                        ?.toString() ??
                                                    '',
                                        isFavorite:
                                            isFavoriteList.length > i
                                                ? isFavoriteList[i]
                                                : false,
                                      ),
                                      backgroundColor:
                                          productColors[products[i]['id']
                                              .toString()] ??
                                          Colors.white,
                                      onFavoriteTap: () {
                                        setState(() {
                                          if (isFavoriteList.length > i) {
                                            isFavoriteList[i] =
                                                !isFavoriteList[i];
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                const SizedBox(width: 25),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              const SizedBox(width: 35),
                              Text(
                                'ชีตยอดฮิต',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                const SizedBox(width: 25),
                                for (int i = 0; i < products.length; i++)
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => PreviewSheetPage(
                                          productId:
                                              products[i]['id'].toString(),
                                        ),
                                      );
                                    },
                                    child: ProductCard(
                                      product: Product(
                                        imageUrl:
                                            (products[i]['imageUrl'] != null)
                                                ? products[i]['imageUrl']
                                                    .toString()
                                                    .replaceAll('`', '')
                                                    .trim()
                                                : null,
                                        title: products[i]['title'] ?? '',
                                        author: products[i]['author'] ?? '',
                                        rating:
                                            (products[i]['rating'] ?? 0)
                                                .toDouble(),
                                        price:
                                            products[i]['price']?.toString() ??
                                            '',
                                        isFavorite:
                                            isFavoriteList.length > i
                                                ? isFavoriteList[i]
                                                : false,
                                      ),
                                      backgroundColor:
                                          productColors[products[i]['id']
                                              .toString()] ??
                                          Colors
                                              .white, // ส่งสีที่ดึงมาให้ ProductCard
                                      onFavoriteTap: () {
                                        setState(() {
                                          if (isFavoriteList.length > i) {
                                            isFavoriteList[i] =
                                                !isFavoriteList[i];
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                const SizedBox(width: 25),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        );
      },
    );
  }
}
