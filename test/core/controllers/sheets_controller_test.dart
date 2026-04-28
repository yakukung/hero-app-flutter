import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/models/category_model.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../support/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageKey = 'sheets_controller_test';
  late GetStorage storage;
  late SheetsController controller;

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    await GetStorage.init(storageKey);
  });

  setUp(() async {
    storage = GetStorage(storageKey);
    await storage.erase();
    controller = SheetsController(storage: storage);
  });

  test('searchSheets matches by title and category name', () {
    controller.sheets.addAll([
      _buildSheet(
        id: 'sheet-1',
        title: 'Biology Basics',
        categoryIds: const ['cat-science'],
      ),
      _buildSheet(
        id: 'sheet-2',
        title: 'History 101',
        categoryIds: const ['cat-social'],
      ),
    ]);

    controller.categories.addAll([
      CategoryModel(
        id: 'cat-science',
        name: 'Science',
        visibleFlag: true,
        statusFlag: StatusFlag.ACTIVE,
      ),
    ]);

    expect(controller.searchSheets('bio').map((sheet) => sheet.id).toList(), [
      'sheet-1',
    ]);
    expect(
      controller.searchSheets('science').map((sheet) => sheet.id).toList(),
      ['sheet-1'],
    );
  });

  test('resetState clears cached sheet data', () {
    controller.sheets.addAll([_buildSheet(id: 'sheet-1', title: 'Sheet A')]);
    controller.favoriteSheets.addAll([
      _buildSheet(id: 'sheet-1', title: 'Sheet A', isFavorite: true),
    ]);
    controller.categories.addAll([
      CategoryModel(
        id: 'cat-1',
        name: 'General',
        visibleFlag: true,
        statusFlag: StatusFlag.ACTIVE,
      ),
    ]);
    controller.errorMessage.value = 'error';
    controller.isLoading.value = true;

    controller.resetState();

    expect(controller.sheets, isEmpty);
    expect(controller.favoriteSheets, isEmpty);
    expect(controller.categories, isEmpty);
    expect(controller.errorMessage.value, isEmpty);
    expect(controller.isLoading.value, isFalse);
  });
}

SheetModel _buildSheet({
  required String id,
  required String title,
  List<String>? categoryIds,
  bool isFavorite = false,
}) {
  return SheetModel(
    id: id,
    authorId: 'author-1',
    title: title,
    visibleFlag: true,
    statusFlag: StatusFlag.ACTIVE,
    createdAt: DateTime.utc(2026, 1, 1),
    createdBy: 'tester',
    categoryIds: categoryIds,
    isFavorite: isFavorite,
  );
}
