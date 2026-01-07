import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/product_model.dart';

class PreviewSheetPage extends StatefulWidget {
  final String productId;

  const PreviewSheetPage({super.key, required this.productId});

  @override
  State<PreviewSheetPage> createState() => _PreviewSheetPageState();
}

class _PreviewSheetPageState extends State<PreviewSheetPage> {
  Product? product;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      // Mock data loading
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
      final String responseBody = await rootBundle.loadString(
        'assets/mock_products.json',
      );
      final List<dynamic> data = jsonDecode(responseBody);

      final productData = data.firstWhere(
        (element) => element['id'].toString() == widget.productId,
        orElse: () => null,
      );

      if (productData != null) {
        setState(() {
          product = Product.fromJson(productData);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Product not found';
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching product details: ${e.toString()}');
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Image Section
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (product?.imageUrl != null)
                                  Image.network(
                                    product!.imageUrl!
                                        .replaceAll('`', '')
                                        .trim(),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 50,
                                              ),
                                            ),
                                  )
                                else
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 50),
                                  ),
                                ClipRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 5.0,
                                      sigmaY: 5.0,
                                    ),
                                    child: Container(
                                      color: Colors.black.withOpacity(0.3),
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'พรีวิวชีต',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4.0,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Dots Indicator (Static for now as per design single image)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDot(true),
                            const SizedBox(width: 8),
                            _buildDot(false),
                            const SizedBox(width: 8),
                            _buildDot(false),
                            const SizedBox(width: 8),
                            _buildDot(false),
                          ],
                        ),
                      ),

                      // Content Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product?.title ?? 'No Title',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ผู้โพสต์ ${product?.author ?? 'ไม่ระบุ'}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'คะแนนชีต ${product?.rating ?? 0}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ราคา ${double.tryParse(product?.price ?? '0') == 0 ? 'ฟรี' : '${product?.price} บาท'}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Favorite Button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  // Toggle favorite locally for UI demo
                                  if (product != null) {
                                    product = Product(
                                      id: product!.id,
                                      title: product!.title,
                                      description: product!.description,
                                      price: product!.price,
                                      rating: product!.rating,
                                      imageUrl: product!.imageUrl,
                                      author: product!.author,
                                      isFavorite: !(product!.isFavorite),
                                    );
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      product?.isFavorite == true
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 20,
                                      color: product?.isFavorite == true
                                          ? Colors.amber
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      product?.isFavorite == true
                                          ? 'ในรายการโปรด'
                                          : 'เพิ่มลงชีตโปรด',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Start Reading Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle read action
                            log('Start Reading Clicked');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A5DB9),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'เริ่มอ่าน',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // Custom App Bar (Back Button & Menu)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.grey[600] : Colors.grey[300],
      ),
    );
  }
}
