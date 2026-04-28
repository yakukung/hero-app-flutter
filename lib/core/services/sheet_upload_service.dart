import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SheetUploadData {
  final String title;
  final String description;
  final String categoryId;
  final List<String> keywords;
  final String price;
  final List<File> images;
  final List<Map<String, dynamic>>? questions;

  const SheetUploadData({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.keywords,
    required this.price,
    required this.images,
    this.questions,
  });
}

class SheetUploadResult {
  const SheetUploadResult({
    required this.success,
    required this.statusCode,
    required this.message,
  });

  final bool success;
  final int statusCode;
  final String message;
}

typedef SendSheetUploadRequest =
    Future<http.Response> Function(http.MultipartRequest request);

class SheetUploadService {
  static final SessionStore _sessionStore = SessionStore();
  static final ApiClient _api = ApiClient(sessionStore: _sessionStore);

  static Future<SheetUploadResult> uploadSheet({
    required SheetUploadData data,
    void Function(int bytes, int total)? onProgress,
    SendSheetUploadRequest? sendRequest,
  }) async {
    final String token = _sessionStore.token;

    final uri = _api.buildUri('/sheets/create');
    final request = onProgress != null
        ? ProgressMultipartRequest('POST', uri, onProgress: onProgress)
        : http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    request.fields['title'] = data.title;
    request.fields['description'] = data.description;
    request.fields['category'] = data.categoryId;
    request.fields['keywords'] = jsonEncode(data.keywords);
    request.fields['price'] = data.price;

    if (data.questions != null && data.questions!.isNotEmpty) {
      request.fields['questions'] = jsonEncode(data.questions);
    } else {
      request.fields['questions'] = '[]';
    }

    for (var file in data.images) {
      String mimeType = 'image/jpeg';
      if (file.path.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    try {
      final response = await (sendRequest ?? _sendRequest)(request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SheetUploadResult(
          success: true,
          statusCode: response.statusCode,
          message: 'อัปโหลดชีตสำเร็จ',
        );
      }

      return SheetUploadResult(
        success: false,
        statusCode: response.statusCode,
        message: 'อัปโหลดล้มเหลว: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Error uploading sheet: $e');
      return SheetUploadResult(
        success: false,
        statusCode: 0,
        message: 'เกิดข้อผิดพลาด: $e',
      );
    }
  }

  static Future<http.Response> _sendRequest(
    http.MultipartRequest request,
  ) async {
    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }
}

class ProgressMultipartRequest extends http.MultipartRequest {
  final void Function(int bytes, int total) onProgress;

  ProgressMultipartRequest(super.method, super.url, {required this.onProgress});

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final total = contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress(bytes, total);
        sink.add(data);
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}
