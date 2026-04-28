import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/features/user/sheet/controllers/preview_sheet_page_controller.dart';

import '../../../../support/test_app_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load marks free sheet as readable and builds preview images', () async {
    final dependencies = await createTestAppDependencies(
      'preview_sheet_controller_test',
    );
    final sheet = SheetModel(
      id: 'sheet-1',
      authorId: 'author-1',
      title: 'Free Sheet',
      price: 0,
      visibleFlag: true,
      statusFlag: StatusFlag.ACTIVE,
      createdAt: DateTime.utc(2026, 1, 1),
      createdBy: 'SYSTEM',
      files: [
        SheetFileModel(
          id: 'file-1',
          sheetId: 'sheet-1',
          format: 'png',
          size: '10',
          originalPath: '/uploads/free-sheet-1.png',
          index: 1,
        ),
        SheetFileModel(
          id: 'file-2',
          sheetId: 'sheet-1',
          format: 'png',
          size: '10',
          originalPath: '/uploads/free-sheet-2.png',
          index: 2,
        ),
        SheetFileModel(
          id: 'file-3',
          sheetId: 'sheet-1',
          format: 'png',
          size: '10',
          originalPath: '/uploads/free-sheet-3.png',
          index: 3,
        ),
      ],
    );

    final controller = PreviewSheetPageController(
      sheetId: sheet.id,
      sheetsController: dependencies.sheetsController,
      sessionCoordinator: dependencies.sessionCoordinator,
      fetchSheetById: (_) async => sheet,
    );

    await controller.load();

    expect(controller.canReadFull, isTrue);
    expect(controller.previewImages, hasLength(2));
    expect(controller.sheet?.title, 'Free Sheet');
  });
}
