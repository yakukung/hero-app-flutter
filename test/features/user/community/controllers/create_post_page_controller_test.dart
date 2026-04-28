import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/features/user/community/controllers/create_post_page_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('submit returns validation error when content is empty', () async {
    final controller = CreatePostPageController(
      submitPost: ({required content, sheetId}) async => true,
    );

    final result = await controller.submit();

    expect(result.success, isFalse);
    expect(result.isValidationError, isTrue);
    expect(result.message, 'กรุณาใส่ข้อความ');
    controller.dispose();
  });

  test('selectSheet and submit pass selected sheet id to service', () async {
    final sheet = SheetModel(
      id: 'sheet-1',
      authorId: 'author-1',
      title: 'Biology Sheet',
      visibleFlag: true,
      statusFlag: StatusFlag.ACTIVE,
      createdAt: DateTime.utc(2026, 1, 1),
      createdBy: 'SYSTEM',
    );
    String? capturedSheetId;

    final controller = CreatePostPageController(
      submitPost: ({required content, sheetId}) async {
        capturedSheetId = sheetId;
        return true;
      },
    );

    controller.contentController.text = 'โพสต์ใหม่';
    controller.selectSheet(sheet);
    final result = await controller.submit();

    expect(result.success, isTrue);
    expect(capturedSheetId, 'sheet-1');

    controller.removeSelectedSheet();
    expect(controller.selectedSheet, isNull);
    controller.dispose();
  });
}
