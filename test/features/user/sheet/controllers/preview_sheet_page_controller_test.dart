import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/payment_history_model.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
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
    expect(controller.previewImages, hasLength(3));
    expect(controller.sheet?.title, 'Free Sheet');
  });

  test('premium member can read paid sheet without purchase', () async {
    final dependencies = await createTestAppDependencies(
      'preview_sheet_controller_premium_test',
      userData: {'id': 'premium-user', 'role_name': 'PREMIUM_MEMBER'},
    );
    final sheet = SheetModel(
      id: 'sheet-paid',
      authorId: 'author-1',
      title: 'Paid Sheet',
      price: 100,
      visibleFlag: true,
      statusFlag: StatusFlag.ACTIVE,
      createdAt: DateTime.utc(2026, 1, 1),
      createdBy: 'SYSTEM',
      files: const [],
    );

    final controller = PreviewSheetPageController(
      sheetId: sheet.id,
      sheetsController: dependencies.sheetsController,
      sessionCoordinator: dependencies.sessionCoordinator,
      fetchSheetById: (_) async => sheet,
    );

    await controller.load();

    expect(controller.canReadFull, isTrue);
  });

  test('purchase marks paid sheet as readable on success', () async {
    final dependencies = await createTestAppDependencies(
      'preview_sheet_controller_purchase_test',
      userData: {'id': 'buyer-user', 'role_name': 'MEMBER'},
    );
    final sheet = SheetModel(
      id: 'sheet-paid',
      authorId: 'author-1',
      title: 'Paid Sheet',
      price: 100,
      visibleFlag: true,
      statusFlag: StatusFlag.ACTIVE,
      createdAt: DateTime.utc(2026, 1, 1),
      createdBy: 'SYSTEM',
      files: const [],
    );

    final controller = PreviewSheetPageController(
      sheetId: sheet.id,
      sheetsController: dependencies.sheetsController,
      sessionCoordinator: dependencies.sessionCoordinator,
      fetchSheetById: (_) async => sheet,
      purchaseSheet: ({required sheetId, required amount}) async {
        expect(sheetId, 'sheet-paid');
        expect(amount, 100);
        return const ServiceResult(
          success: true,
          statusCode: 201,
          message: 'ซื้อชีตสำเร็จ',
          data: SheetPurchaseResult(isPurchased: true, walletBalance: 25),
        );
      },
    );

    await controller.load();

    expect(controller.canReadFull, isFalse);

    final result = await controller.purchase();

    expect(result.success, isTrue);
    expect(controller.canReadFull, isTrue);
  });
}
