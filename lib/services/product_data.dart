import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter/material.dart';

class ProductData extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

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
            if (!path.startsWith('http')) {
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

        _isLoading = false;
        notifyListeners();
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

  /// Refresh products silently without clearing existing data
  Future<void> refreshProducts() async {
    try {
      final response = await http.get(Uri.parse('$apiEndpoint/sheets'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']['sheets'];

        _products = data.map((item) {
          String imageUrl = '';
          if (item['files'] != null && (item['files'] as List).isNotEmpty) {
            String path =
                item['files'][0]['thumbnail_path'] ??
                item['files'][0]['original_path'];
            if (!path.startsWith('http')) {
              final uri = Uri.parse(apiEndpoint);
              final baseUrl = '${uri.scheme}://${uri.host}:${uri.port}';
              imageUrl = '$baseUrl/$path';
            } else {
              imageUrl = path;
            }
          }

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

        notifyListeners();
      }
    } catch (e) {
      log('Refresh error: $e');
    }
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
