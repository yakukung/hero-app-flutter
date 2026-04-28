import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/services/users_service.dart';
import 'package:hero_app_flutter/features/user/profile/controllers/profile_page_controller.dart';

import '../../../../support/test_app_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'uploadProfileImage updates app state and upload progress on success',
    () async {
      final dependencies = await createTestAppDependencies(
        'profile_page_controller_test',
        userData: {
          'id': 'user-1',
          'username': 'hero',
          'email': 'hero@example.com',
          'auth_provider': 'EMAIL_PASSWORD',
          'role_name': 'USER',
          'role_id': 'role-user',
          'visible_flag': true,
          'status_flag': 'ACTIVE',
          'point': 0,
          'created_at': '2026-01-01T00:00:00.000Z',
          'created_by': 'SYSTEM',
        },
      );
      final tempDir = await Directory.systemTemp.createTemp(
        'profile_page_controller_image_test',
      );
      final imageFile = File('${tempDir.path}/avatar.png')
        ..writeAsBytesSync(List<int>.filled(64, 1));

      final controller = ProfilePageController(
        appController: dependencies.appController,
        sessionCoordinator: dependencies.sessionCoordinator,
        uploadProfileImage:
            ({required uid, required imageFile, token, onProgress}) async {
              onProgress?.call(5, 10);
              return const UserProfileImageUploadResult(
                success: true,
                statusCode: 200,
                message: 'ok',
                profileImage: '/uploads/avatar.png',
              );
            },
      );

      try {
        final result = await controller.uploadProfileImage(imageFile);

        expect(result.success, isTrue);
        expect(controller.uploadStateNotifier.value.isSuccess, isTrue);
        expect(controller.uploadStateNotifier.value.progress, 1.0);
        expect(
          dependencies.appController.profileImage,
          contains('/uploads/avatar.png'),
        );
      } finally {
        controller.dispose();
        await tempDir.delete(recursive: true);
      }
    },
  );

  test(
    'validateUserSheetsAccess returns message when uid is missing',
    () async {
      final dependencies = await createTestAppDependencies(
        'profile_page_controller_validation_test',
      );
      final controller = ProfilePageController(
        appController: dependencies.appController,
        sessionCoordinator: dependencies.sessionCoordinator,
      );

      expect(
        controller.validateUserSheetsAccess(),
        'กรุณาเข้าสู่ระบบใหม่แล้วลองอีกครั้ง',
      );
      controller.dispose();
    },
  );
}
