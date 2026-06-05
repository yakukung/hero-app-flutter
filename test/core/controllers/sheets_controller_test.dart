import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/models/category_model.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/services/preferences_service.dart';
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
    controller.backendRecommendedSheets.addAll([
      _buildSheet(id: 'sheet-2', title: 'Sheet B'),
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
    expect(controller.backendRecommendedSheets, isEmpty);
    expect(controller.categories, isEmpty);
    expect(controller.errorMessage.value, isEmpty);
    expect(controller.isLoading.value, isFalse);
  });

  test('recommendedSheets prefers backend recommendations when present', () {
    controller.sheets.addAll([
      _buildSheet(id: 'sheet-1', title: 'Local Sheet'),
    ]);
    controller.backendRecommendedSheets.addAll([
      _buildSheet(id: 'sheet-2', title: 'Backend Sheet'),
    ]);

    final recommended = controller.recommendedSheets();

    expect(recommended.map((sheet) => sheet.id), ['sheet-2']);
  });

  test('recommendedSheets matches saved keyword and subject names', () async {
    final preferencesService = PreferencesService(storage: storage);
    await preferencesService.save(
      const UserPreferences(keywords: ['calculus'], subjects: ['science']),
    );

    controller.sheets.addAll([
      _buildSheet(
        id: 'sheet-1',
        title: 'Math Sheet',
        keywordIds: const ['kw-1'],
        keywordNames: const ['Calculus'],
      ),
      _buildSheet(
        id: 'sheet-2',
        title: 'Lab Sheet',
        categoryIds: const ['cat-1'],
        categoryNames: const ['Science'],
      ),
      _buildSheet(id: 'sheet-3', title: 'History Sheet'),
    ]);

    final recommended = controller.recommendedSheets(
      preferencesService: preferencesService,
    );

    expect(recommended.map((sheet) => sheet.id), ['sheet-1', 'sheet-2']);
  });

  test(
    'recommendedSheets falls back to local preference matches when backend misses',
    () async {
      final preferencesService = PreferencesService(storage: storage);
      await preferencesService.save(
        const UserPreferences(keywords: ['biology']),
      );

      controller.sheets.addAll([
        _buildSheet(
          id: 'sheet-1',
          title: 'Biology Basics',
          keywordNames: const ['Biology'],
        ),
        _buildSheet(id: 'sheet-2', title: 'Unrelated Local Sheet'),
      ]);
      controller.backendRecommendedSheets.addAll([
        _buildSheet(id: 'sheet-3', title: 'Backend Sheet'),
      ]);

      final recommended = controller.recommendedSheets(
        preferencesService: preferencesService,
      );

      expect(recommended.map((sheet) => sheet.id), ['sheet-1']);
    },
  );

  test('markPurchased updates cached sheet lists', () {
    controller.sheets.addAll([_buildSheet(id: 'sheet-1', title: 'Sheet A')]);
    controller.favoriteSheets.addAll([
      _buildSheet(id: 'sheet-1', title: 'Sheet A', isFavorite: true),
    ]);
    controller.backendRecommendedSheets.addAll([
      _buildSheet(id: 'sheet-1', title: 'Sheet A'),
    ]);

    controller.markPurchased('sheet-1');

    expect(controller.sheets.single.isPurchased, isTrue);
    expect(controller.favoriteSheets.single.isPurchased, isTrue);
    expect(controller.backendRecommendedSheets.single.isPurchased, isTrue);
  });
}

SheetModel _buildSheet({
  required String id,
  required String title,
  List<String>? categoryIds,
  List<String>? keywordIds,
  List<String>? categoryNames,
  List<String>? keywordNames,
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
    keywordIds: keywordIds,
    categoryNames: categoryNames,
    keywordNames: keywordNames,
    isFavorite: isFavorite,
  );
}
