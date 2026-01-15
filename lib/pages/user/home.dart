import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/pages/user/sheet/preview_sheet.dart';
import 'package:flutter_application_1/widgets/product/product_card.dart';
import 'package:flutter_application_1/widgets/search/search_sheet_box.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:flutter_application_1/services/product_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Appdata>(context, listen: false).fetchUserData();
      Provider.of<ProductData>(context, listen: false).fetchProducts();
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<ProductData>(context, listen: false).refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductData>(
      builder: (context, productData, child) {
        final isLoading = productData.isLoading;
        final errorMessage = productData.errorMessage;
        final products = productData.products;
        final productColors = productData.productColors;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? _buildErrorView(productData)
                : products.isEmpty
                ? _buildEmptyView()
                : _buildContent(products, productColors, productData),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(ProductData productData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            productData.errorMessage,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text(
        'ไม่มีข้อมูลผลิตภัณฑ์',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildContent(
    List<dynamic> products,
    Map<String, Color> productColors,
    ProductData productData,
  ) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF2A5DB9),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 35),
            const SearchSheetBox(),
            const SizedBox(height: 35),
            _buildSectionHeader('ชีตยอดนิยม'),
            const SizedBox(height: 16),
            _buildProductList(products, productColors, productData),
            const SizedBox(height: 20),
            _buildSectionHeader('ชีตใหม่ล่าสุด'),
            const SizedBox(height: 16),
            _buildProductList(products, productColors, productData),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Handle see all action
            },
            child: const Text(
              'แสดงทั้งหมด',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(
    List<dynamic> products,
    Map<String, Color> productColors,
    ProductData productData,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        children: [
          for (int i = 0; i < products.length; i++)
            GestureDetector(
              onTap: () {
                Get.to(
                  () =>
                      PreviewSheetPage(productId: products[i]['id'].toString()),
                );
              },
              child: ProductCard(
                product: Product(
                  imageUrl: (products[i]['imageUrl'] != null)
                      ? products[i]['imageUrl']
                            .toString()
                            .replaceAll('`', '')
                            .trim()
                      : null,
                  title: products[i]['title'] ?? '',
                  author: products[i]['author'] ?? '',
                  rating: (products[i]['rating'] ?? 0).toDouble(),
                  price: products[i]['price'] == 0
                      ? 'ฟรี'
                      : '${products[i]['price']} บาท',
                  isFavorite: (products[i]['is_favorite'] == 1),
                ),
                backgroundColor:
                    productColors[products[i]['id'].toString()] ?? Colors.white,
                onFavoriteTap: () {
                  productData.toggleFavorite(products[i]['id'].toString());
                },
              ),
            ),
        ],
      ),
    );
  }
}
