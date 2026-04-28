import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/features/user/home/controllers/home_page_controller.dart';

import '../../../../support/test_app_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toggleFavorite returns success message for add action', () async {
    final dependencies = await createTestAppDependencies(
      'home_controller_test',
    );
    final controller = HomePageController(
      sheetsController: dependencies.sheetsController,
      addFavorite: (_) async => true,
      removeFavorite: (_) async => true,
    );
    final sheet = SheetModel(
      id: 'sheet-1',
      authorId: 'author-1',
      title: 'Biology Basics',
      visibleFlag: true,
      statusFlag: StatusFlag.ACTIVE,
      createdAt: DateTime.utc(2026, 1, 1),
      createdBy: 'SYSTEM',
    );

    final result = await controller.toggleFavorite(sheet);

    expect(result.success, isTrue);
    expect(result.message, 'เพิ่มเป็นรายการโปรดแล้ว');
  });
}
