import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart'; // For rootBundle

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:http/http.dart' as http;
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
      // Mock data loading
      await Future.delayed(const Duration(seconds: 1)); // Simulate delay
      final String responseBody = await rootBundle.loadString(
        'assets/mock_products.json',
      );
      final List<dynamic> data = jsonDecode(responseBody);

      _products = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
      notifyListeners();
      await _updateProductColors();
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
      // Handle both int (1/0) and bool (true/false) just in case
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
