import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/upload_state.dart';
import 'package:flutter_application_1/widgets/upload/upload_progress_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/services/navigation_service.dart';

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

class SheetUploadService {
  static Future<bool> uploadSheet({
    required BuildContext context,
    required SheetUploadData data,
  }) async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    final uri = Uri.parse('$apiEndpoint/sheets/create');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      if (token != null) 'Authorization': 'Bearer $token',
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

    final stateNotifier = ValueNotifier(const UploadState(isUploading: true));
    // ignore: use_build_context_synchronously
    UploadProgressDialog.show(
      context: context,
      stateNotifier: stateNotifier,
      onComplete: () {
        try {
          final navService = Get.find<NavigationService>();
          navService.changeIndex(0);
        } catch (e) {
          log('Error navigating back: $e');
        }
      },
    );

    try {
      final progressRequest = ProgressMultipartRequest(
        'POST',
        uri,
        onProgress: (int bytes, int total) {
          final progress = bytes / total;
          stateNotifier.value = stateNotifier.value.copyWith(
            progress: progress,
          );
        },
      );

      progressRequest.headers.addAll(request.headers);
      progressRequest.fields.addAll(request.fields);
      progressRequest.files.addAll(request.files);

      final streamedResponse = await progressRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        stateNotifier.value = stateNotifier.value.copyWith(
          isUploading: false,
          isSuccess: true,
          progress: 1.0,
        );
        return true;
      } else {
        stateNotifier.value = stateNotifier.value.copyWith(
          isUploading: false,
          isSuccess: false,
          errorMessage: 'อัปโหลดล้มเหลว: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      stateNotifier.value = stateNotifier.value.copyWith(
        isUploading: false,
        isSuccess: false,
        errorMessage: 'เกิดข้อผิดพลาด: $e',
      );
      return false;
    }
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
