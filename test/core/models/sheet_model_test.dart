import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';

void main() {
  test('fromJson parses string keyword and category lists', () {
    final sheet = SheetModel.fromJson({
      'id': 'sheet-1',
      'author_id': 'author-1',
      'title': 'Biology Sheet',
      'visible_flag': true,
      'status_flag': StatusFlag.ACTIVE.name,
      'created_at': DateTime.utc(2026, 1, 1).toIso8601String(),
      'created_by': 'tester',
      'categories': ['Science'],
      'keywords': ['Biology', 'Exam'],
    });

    expect(sheet.categoryIds, ['Science']);
    expect(sheet.categoryNames, ['Science']);
    expect(sheet.keywordIds, ['Biology', 'Exam']);
    expect(sheet.keywordNames, ['Biology', 'Exam']);
  });
}
