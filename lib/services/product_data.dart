import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_connect.dart';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ProductData extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, Color> _productColors = {};

  List<Map<String, dynamic>> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, Color> get productColors => _productColors;

  Future<void> fetchProducts() async {
    if (_products.isNotEmpty && !_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$apiEndpoint/sheets'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']['sheets'];

        _products = data.map((item) {
          // Extract image URL
          String imageUrl = '';
          if (item['files'] != null && (item['files'] as List).isNotEmpty) {
            String path =
                item['files'][0]['thumbnail_path'] ??
                item['files'][0]['original_path'];
            // If path doesn't start with http, prepend apiEndpoint
            if (!path.startsWith('http')) {
              // Assuming apiEndpoint is like http://host:port/api/v1
              // We might need just host:port.
              // Let's assume path is relative to server root.
              // Construct clean URL.
              final uri = Uri.parse(apiEndpoint);
              final baseUrl = '${uri.scheme}://${uri.host}:${uri.port}';
              imageUrl = '$baseUrl/$path';
            } else {
              imageUrl = path;
            }
            log('Generated Image URL: $imageUrl');
          }

          // Extract category
          String subject = 'Unknown';
          if (item['categories'] != null &&
              (item['categories'] as List).isNotEmpty) {
            subject = item['categories'][0]['name'];
          }

          return {
            'id': item['id'],
            'title': item['title'],
            'description': item['description'] ?? '',
            'price': item['price'] ?? 'ฟรี', // Handle null price as Free
            'rating':
                double.tryParse(item['rating']?.toString() ?? '0.0') ?? 0.0,
            'review_count': 0, // Not provided by API yet
            'author': item['author_name'] ?? 'Unknown',
            'avatarUrl': 'assets/images/default/avatar.png', // Placeholder
            'imageUrl': imageUrl,
            'subject': subject,
            'is_favorite': false, // Default to false
          };
        }).toList();

        _isLoading = false;
        notifyListeners();
        await _updateProductColors();
      } else {
        throw Exception('Failed to load sheets: ${response.statusCode}');
      }
    } catch (e) {
      log('Product API error: $e');
      _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateProductColors() async {
    final Map<String, Color> newColors = {};
    final List<Future<void>> futures = [];

    for (var product in _products) {
      final imageUrl = product['imageUrl']
          ?.toString()
          .replaceAll('`', '')
          .trim();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        futures.add(
          Future(() async {
            try {
              final PaletteGenerator generator =
                  await PaletteGenerator.fromImageProvider(
                    NetworkImage(imageUrl),
                    size: const Size(200, 200),
                    maximumColorCount: 20,
                  );
              Color extractedColor =
                  generator.dominantColor?.color ?? Colors.white;
              Color lighterColor = Color.lerp(
                extractedColor,
                Colors.white,
                0.8,
              )!;
              newColors[product['id'].toString()] = lighterColor;
            } catch (e) {
              log('Error generating palette for ${product['id']}: $e');
              newColors[product['id'].toString()] = Colors.white;
            }
          }),
        );
      } else {
        newColors[product['id'].toString()] = Colors.white;
      }
    }
    await Future.wait(futures);
    _productColors = newColors;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    _products = [];
    await fetchProducts();
  }

  void toggleFavorite(String productId) {
    final index = _products.indexWhere(
      (element) => element['id'].toString() == productId,
    );
    if (index != -1) {
      final currentStatus = _products[index]['is_favorite'];
      bool isFav = false;
      if (currentStatus is int) {
        isFav = currentStatus == 1;
      } else if (currentStatus is bool) {
        isFav = currentStatus;
      }

      _products[index]['is_favorite'] = isFav ? 0 : 1;
      notifyListeners();
    }
  }
}
