import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/sheet_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class SheetPaymentData {
  final String sheetId;
  final String sheetTable = 'sheets';
  final String paymentMethod = 'PROMPTPAY';
  final double amount;
  final String currency;
  final List<File> slipImage;

  const SheetPaymentData({
    required this.sheetId,
    required this.amount,
    required this.currency,
    required this.slipImage,
  });
}

class SheetsService {
  static Future<bool> paymentSheet({required SheetPaymentData data}) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    try {
      if (token == null) {
        return false;
      }
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiEndpoint/sheets/payment'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['sheetId'] = data.sheetId;
      request.fields['sheetTable'] = data.sheetTable;
      request.fields['paymentMethod'] = data.paymentMethod;
      request.fields['amount'] = data.amount.toString();
      request.fields['currency'] = data.currency;

      for (var file in data.slipImage) {
        request.files.add(
          await http.MultipartFile.fromPath('slipImage', file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

class SheetData extends ChangeNotifier {
  List<SheetModel> _sheets = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<SheetModel> get sheets => _sheets;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchSheets({bool forceRefresh = false}) async {
    if (_sheets.isNotEmpty && !_isLoading && !forceRefresh) {
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

        _sheets = data.map((item) => SheetModel.fromJson(item)).toList();

        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load sheets: ${response.statusCode}');
      }
    } catch (e) {
      log('Sheet API error: $e');
      _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSheets() async {
    try {
      final response = await http.get(Uri.parse('$apiEndpoint/sheets'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']['sheets'];

        _sheets = data.map((item) => SheetModel.fromJson(item)).toList();

        notifyListeners();
      }
    } catch (e) {
      log('Refresh error: $e');
    }
  }

  void toggleFavorite(String sheetId) {
    final index = _sheets.indexWhere((element) => element.id == sheetId);
    if (index != -1) {
      notifyListeners();
    }
  }
}
