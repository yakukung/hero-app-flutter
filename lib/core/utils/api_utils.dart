import 'dart:convert';
import 'package:http/http.dart' as http;

Map<String, dynamic>? decodeJsonMap(String source) {
  try {
    if (source.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(source);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

dynamic getApiData(String source) {
  final decoded = decodeJsonMap(source);
  if (decoded == null) {
    return null;
  }
  return decoded['data'] ?? decoded;
}

List<dynamic> getApiList(String source, List<String> keys) {
  final root = getApiData(source);
  if (root is List) {
    return root;
  }
  if (root is Map<String, dynamic>) {
    for (final key in keys) {
      final value = root[key];
      if (value is List) {
        return value;
      }
    }
  }
  return const [];
}

String getErrorMessage(
  http.Response response, {
  String fallback = 'เกิดข้อผิดพลาด',
}) {
  try {
    if (response.body.trim().isEmpty) {
      return fallback;
    }

    final Map<String, dynamic>? body = decodeJsonMap(response.body);
    if (body == null) {
      return fallback;
    }

    final dynamic error = body['error'];

    if (error is Map<String, dynamic>) {
      final dynamic message = error['message'];
      if (message is Map<String, dynamic>) {
        return message['th']?.toString() ??
            message['en']?.toString() ??
            fallback;
      }
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }

    final dynamic message = body['message'];
    if (message != null && message.toString().isNotEmpty) {
      return message.toString();
    }

    return fallback;
  } catch (e) {
    return fallback;
  }
}
