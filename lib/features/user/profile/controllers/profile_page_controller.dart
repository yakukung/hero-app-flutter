import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/core/models/upload_state.dart';
import 'package:hero_app_flutter/core/services/users_service.dart';
import 'package:hero_app_flutter/core/session/app_session_coordinator.dart';

typedef UploadProfileImage =
    Future<UserProfileImageUploadResult> Function({
      required String uid,
      required File imageFile,
      String? token,
      void Function(int bytes, int total)? onProgress,
    });

class ProfilePageController {
  ProfilePageController({
    AppController? appController,
    AppSessionCoordinator? sessionCoordinator,
    UploadProfileImage? uploadProfileImage,
  }) : _appController = appController ?? Get.find<AppController>(),
       _sessionCoordinator = sessionCoordinator ?? AppSessionCoordinator(),
       _uploadProfileImage =
           uploadProfileImage ?? UsersService.updateProfileImage;

  final AppController _appController;
  final AppSessionCoordinator _sessionCoordinator;
  final UploadProfileImage _uploadProfileImage;

  final ValueNotifier<UploadState> uploadStateNotifier = ValueNotifier(
    const UploadState(),
  );

  AppController get appController => _appController;

  Future<void> refresh() => _appController.fetchUserData();

  String? validateUserSheetsAccess() {
    if (_appController.uid.isEmpty) {
      return 'กรุณาเข้าสู่ระบบใหม่แล้วลองอีกครั้ง';
    }
    return null;
  }

  Future<UserProfileImageUploadResult> uploadProfileImage(
    File imageFile,
  ) async {
    uploadStateNotifier.value = const UploadState(isUploading: true);

    try {
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        const message = 'ไฟล์รูปภาพใหญ่เกิน 5MB';
        uploadStateNotifier.value = const UploadState(
          isUploading: false,
          isSuccess: false,
          errorMessage: message,
        );
        return const UserProfileImageUploadResult(
          success: false,
          statusCode: 0,
          message: message,
        );
      }

      final result = await _uploadProfileImage(
        uid: _appController.uid,
        imageFile: imageFile,
        onProgress: (bytes, total) {
          uploadStateNotifier.value = uploadStateNotifier.value.copyWith(
            progress: total == 0 ? 0 : bytes / total,
          );
        },
      );

      if (result.success) {
        if (result.profileImage != null && result.profileImage!.isNotEmpty) {
          _appController.setProfileImage(result.profileImage!);
        } else {
          await _appController.fetchUserData();
        }
      }

      uploadStateNotifier.value = UploadState(
        progress: result.success ? 1.0 : uploadStateNotifier.value.progress,
        isUploading: false,
        isSuccess: result.success,
        errorMessage: result.success ? null : result.message,
      );

      return result;
    } catch (error) {
      final message = 'อัปโหลดรูปภาพไม่สำเร็จ: $error';
      debugPrint('Error uploading profile image: $error');
      uploadStateNotifier.value = UploadState(
        isUploading: false,
        isSuccess: false,
        errorMessage: message,
      );
      return UserProfileImageUploadResult(
        success: false,
        statusCode: 0,
        message: message,
      );
    }
  }

  Future<SessionDestination> logout() => _sessionCoordinator.logout();

  void dispose() {
    uploadStateNotifier.dispose();
  }
}
