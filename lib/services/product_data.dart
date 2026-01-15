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

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (_products.isNotEmpty && !_isLoading && !forceRefresh) {
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

        // Lazy load colors - don't await, let it run in background
        _lazyLoadColors();
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

  /// Load colors progressively without blocking UI
  void _lazyLoadColors() {
    for (var product in _products) {
      final productId = product['id'].toString();

      // Skip if already has color
      if (_productColors.containsKey(productId)) continue;

      final imageUrl = product['imageUrl']
          ?.toString()
          .replaceAll('`', '')
          .trim();

      if (imageUrl == null || imageUrl.isEmpty) {
        _productColors[productId] = Colors.grey[100]!;
        notifyListeners();
        continue;
      }

      // Load each color asynchronously without waiting
      _loadSingleColor(productId, imageUrl);
    }
  }

  Future<void> _loadSingleColor(String productId, String imageUrl) async {
    try {
      final generator = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        size: const Size(100, 100), // Smaller size = faster
        maximumColorCount: 10, // Less colors = faster
      );

      final extractedColor =
          generator.dominantColor?.color ?? Colors.grey[100]!;
      final lighterColor = Color.lerp(extractedColor, Colors.white, 0.8)!;

      _productColors[productId] = lighterColor;
      notifyListeners(); // Update UI immediately when this color is ready
    } catch (e) {
      log('Error generating palette for $productId: $e');
      _productColors[productId] = Colors.grey[100]!;
      notifyListeners();
    }
  }

  /// Refresh products silently without clearing existing data
  /// This allows RefreshIndicator to work smoothly
  Future<void> refreshProducts() async {
    // Don't set isLoading = true, let RefreshIndicator handle the loading state
    // Don't clear _products, keep showing existing data during refresh

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
              final uri = Uri.parse(apiEndpoint);
              final baseUrl = '${uri.scheme}://${uri.host}:${uri.port}';
              imageUrl = '$baseUrl/$path';
            } else {
              imageUrl = path;
            }
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
            'price': item['price'] ?? 'ฟรี',
            'rating':
                double.tryParse(item['rating']?.toString() ?? '0.0') ?? 0.0,
            'review_count': 0,
            'author': item['author_name'] ?? 'Unknown',
            'avatarUrl': 'assets/images/default/avatar.png',
            'imageUrl': imageUrl,
            'subject': subject,
            'is_favorite': false,
          };
        }).toList();

        // Keep existing colors, only load colors for new products
        // _lazyLoadColors() already skips products that have colors
        notifyListeners();

        // Lazy load colors only for new products (existing ones are skipped)
        _lazyLoadColors();
      }
    } catch (e) {
      log('Refresh error: $e');
      // On error, keep existing data - don't show error for pull-to-refresh
    }
  }

  /// Force refresh that clears everything (for hard reset scenarios)
  Future<void> hardRefreshProducts() async {
    _products = [];
    _productColors = {};
    await fetchProducts(forceRefresh: true);
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
