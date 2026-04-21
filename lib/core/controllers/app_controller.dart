import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:flutter_application_1/core/session/session_store.dart';
import 'package:flutter_application_1/core/services/users_service.dart';

class AppController extends GetxController {
  AppController({GetStorage? storage, SessionStore? sessionStore})
    : _sessionStore = sessionStore ?? SessionStore(storage: storage);

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxBool isReady = false.obs;
  final RxString errorMessage = ''.obs;

  final SessionStore _sessionStore;

  String get uid => user.value?.id ?? '';
  String get username => user.value?.username ?? '';
  String get email => user.value?.email ?? '';
  String get provider => user.value?.authProvider.name ?? 'EMAIL';
  double get wallet => user.value?.wallet ?? 0.0;
  int get followersCount => user.value?.followersCount ?? 0;
  int get followingsCount => user.value?.followingsCount ?? 0;
  String get profileImage {
    final String imagePath = user.value?.profileImage ?? '';
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return Uri.parse(apiEndpoint).resolve(imagePath).toString();
  }

  bool get hasUser => user.value != null;

  @override
  void onInit() {
    super.onInit();
    _hydrateSession();
  }

  Future<void> _hydrateSession() async {
    final String storedUid = _sessionStore.uid;
    if (storedUid.isEmpty) {
      isReady.value = true;
      return;
    }

    await fetchUserData();
    isReady.value = true;
  }

  void setProfileImage(String url) {
    if (user.value == null) return;
    user.value = user.value!.copyWith(profileImage: url);
  }

  Future<void> fetchUserData() async {
    final String storedUid = _sessionStore.uid;
    isLoading.value = true;

    try {
      if (storedUid.isNotEmpty) {
        final String token = _sessionStore.token;
        final response = await UsersService.fetchUserByIdRaw(
          storedUid,
          token: token.isNotEmpty ? token : null,
        );

        if (response.statusCode == 200) {
          final userData = _extractUserMap(jsonDecode(response.body));
          if (userData.isNotEmpty) {
            _applyUserData(userData);
            errorMessage.value = '';
          } else {
            _handleUserError('ไม่พบข้อมูลผู้ใช้ในข้อมูลตอบกลับ');
          }
        } else {
          _handleUserError(
            'ไม่สามารถดึงข้อมูลผู้ใช้ได้: ${response.statusCode}',
          );
          if (response.statusCode == 401 ||
              response.statusCode == 403 ||
              response.statusCode == 404) {
            clearUserData();
          }
        }
      } else {
        clearUserData();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      _handleUserError('เกิดข้อผิดพลาดในการดึงข้อมูล: $e');
    } finally {
      isLoading.value = false;
      isReady.value = true;
    }
  }

  void updateFromMap(Map<String, dynamic> userData) {
    _applyUserData(userData);
    isReady.value = true;
  }

  Map<String, dynamic> _extractUserMap(dynamic responseBody) {
    if (responseBody is Map<String, dynamic>) {
      if (responseBody['data'] is Map<String, dynamic>) {
        return responseBody['data'] as Map<String, dynamic>;
      }
      return responseBody;
    }
    return <String, dynamic>{};
  }

  void _applyUserData(Map<String, dynamic> userData) {
    try {
      final newUser = UserModel.fromJson(userData);
      String? resolvedRole = newUser.roleName;

      if (resolvedRole == null || resolvedRole.isEmpty) {
        if (user.value?.roleName != null && user.value!.roleName!.isNotEmpty) {
          resolvedRole = user.value!.roleName;
        } else {
          resolvedRole = _sessionStore.roleName;
        }
      }

      if (resolvedRole != null && resolvedRole.isNotEmpty) {
        user.value = newUser.copyWith(roleName: resolvedRole);
        _sessionStore.writeRoleName(resolvedRole);
      } else {
        user.value = newUser;
      }

      _sessionStore.writeUid(user.value!.id);

      if (userData['tokens'] is Map<String, dynamic>) {
        _sessionStore.persistTokens(userData['tokens'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error parsing user data: $e');
      _handleUserError('Error parsing user data: $e');
    }
  }

  void _handleUserError(String message) {
    errorMessage.value = message;
  }

  void clearUserData() {
    user.value = null;
    errorMessage.value = '';
    _sessionStore.clearSession();
    isReady.value = true;
  }
}
