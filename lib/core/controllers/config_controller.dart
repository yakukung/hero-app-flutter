import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';

class ConfigController extends GetxController {
  final RxMap<String, Map<String, dynamic>> _configs =
      <String, Map<String, dynamic>>{}.obs;
  final RxBool isLoading = false.obs;
  final SessionStore _sessionStore = SessionStore();
  final ApiClient _api = ApiClient();

  String? getConfigString(String metaKey) {
    final config = _configs[metaKey];
    if (config == null) return null;
    return config['meta_value']?.toString();
  }

  Future<void> fetchConfigs() async {
    if (_configs.isNotEmpty) return;
    isLoading.value = true;
    try {
      final response = await _api.get(
        path: '/config',
        token: _sessionStore.token,
      );
      if (response.statusCode == 200) {
        final root = getApiData(response.body);
        final list = root['config'] is List
            ? root['config'] as List
            : (root is List ? root : null);
        if (list != null) {
          for (final item in list) {
            if (item is Map) {
              final map = Map<String, dynamic>.from(item);
              final key = map['meta_key']?.toString();
              if (key != null && key.isNotEmpty) {
                _configs[key] = map;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('ConfigController: fetch error $e');
    } finally {
      isLoading.value = false;
    }
  }
}
