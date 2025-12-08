import 'dart:convert';
import 'dart:developer';
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

    const int maxRetries = 3;
    const Duration timeoutDuration = Duration(seconds: 10);
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final response = await http
            .get(Uri.parse('$apiEndpoint/product'))
            .timeout(timeoutDuration);

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          _products = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
          notifyListeners();
          await _updateProductColors();
          return;
        } else {
          _errorMessage = 'ไม่สามารถดึงข้อมูลได้ (${response.statusCode})';
          _isLoading = false;
          notifyListeners();
          retryCount++;
        }
      } catch (e) {
        log('Product API error: $e (Attempt ${retryCount + 1}/$maxRetries)');
        _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
        _isLoading = false;
        notifyListeners();
        retryCount++;
      }

      if (retryCount < maxRetries) {
        log('Retrying in 2 seconds...');
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (retryCount == maxRetries) {
      _errorMessage = 'ไม่สามารถดึงข้อมูลได้หลังจากลอง $maxRetries ครั้ง';
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
}
