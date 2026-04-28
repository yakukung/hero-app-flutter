import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/features/user/upload/controllers/upload_page_controller.dart';
import 'package:hero_app_flutter/features/user/upload/upload_page.dart';
import 'package:hero_app_flutter/validations/validation_messages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('shows validation dialog when upload data is incomplete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = UploadPageController(
      fetchCategories: () async => const [],
    );

    await tester.pumpWidget(
      GetMaterialApp(home: UploadPage(controller: controller)),
    );

    await tester.tap(find.byKey(const Key('upload_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text(ValidationMessages.incompleteInfoTitle), findsOneWidget);
    expect(find.text(ValidationMessages.uploadImageRequired), findsOneWidget);
    controller.dispose();
  });
}
