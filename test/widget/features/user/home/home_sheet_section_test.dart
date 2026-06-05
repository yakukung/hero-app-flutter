import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/features/user/home/widgets/home_sheet_section.dart';

void main() {
  testWidgets('show all action is a TextButton and invokes callback', (
    tester,
  ) async {
    var showAllTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeSheetSection(
            title: 'ชีตยอดนิยม',
            sheets: const [],
            onOpenSheet: (_) {},
            onFavoriteTap: (_) {},
            onShowAll: () => showAllTapCount++,
          ),
        ),
      ),
    );

    final showAllButton = find.widgetWithText(TextButton, 'แสดงทั้งหมด');

    expect(showAllButton, findsOneWidget);

    await tester.tap(showAllButton);
    await tester.pump();

    expect(showAllTapCount, 1);
  });
}
