import 'dart:convert';
import 'package:http/http.dart' as http;

String getErrorMessage(http.Response response) {
  try {
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['error']?['message']?['th'] ?? 'เกิดข้อผิดพลาด';
  } catch (e) {
    return 'เกิดข้อผิดพลาด';
  }
}
