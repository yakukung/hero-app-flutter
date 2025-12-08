import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_connect.dart';
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
      final response = await http.get(
        Uri.parse('$apiEndpoint/product/${widget.productId}'),
      );

      log('API Status Code: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          product = Product.fromJson(data);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load product details';
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
      appBar: AppBar(
        title: Text(
          isLoading
              ? 'Loading...'
              : product?.name ?? product?.title ?? 'Product',
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product?.imageUrl != null)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          product!.imageUrl!.replaceAll('`', '').trim(),
                          height: 400,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product?.title ?? 'No Title',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (product?.isFavorite != null)
                        Icon(
                          product!.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product!.isFavorite ? Colors.red : Colors.grey,
                          size: 30,
                        ),
                    ],
                  ),
                  SizedBox(height: 8),

                  if (product?.author != null)
                    Text(
                      'โดย ${product!.author}',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (product?.rating != null)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              '${product!.rating}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      if (product?.price != null)
                        Text(
                          double.tryParse(product!.price ?? '0') == 0
                              ? 'ราคา: ฟรี'
                              : 'ราคา: ${product!.price}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 24),

                  if (product?.description != null)
                    Text(
                      product!.description!,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                ],
              ),
            ),
    );
  }
}
