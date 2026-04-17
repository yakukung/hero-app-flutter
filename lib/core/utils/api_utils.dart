import 'dart:convert';
import 'package:http/http.dart' as http;

String getErrorMessage(http.Response response) {
  try {
    if (response.body.trim().isEmpty) {
      return 'เกิดข้อผิดพลาด';
    }

    final Map<String, dynamic> body = jsonDecode(response.body);
    final dynamic error = body['error'];

    if (error is Map<String, dynamic>) {
      final dynamic message = error['message'];
      if (message is Map<String, dynamic>) {
        return message['th']?.toString() ??
            message['en']?.toString() ??
            'เกิดข้อผิดพลาด';
      }
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }

    final dynamic message = body['message'];
    if (message != null && message.toString().isNotEmpty) {
      return message.toString();
    }

    return 'เกิดข้อผิดพลาด';
  } catch (e) {
    return 'เกิดข้อผิดพลาด';
  }
}
