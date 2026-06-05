import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_app_flutter/features/user/sheet/widgets/preview_sheet_bottom_action_bar.dart';

void main() {
  Widget buildSubject({
    required bool canReadFull,
    required bool hasQuestions,
    required bool showQuizAction,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            PreviewSheetBottomActionBar(
              canReadFull: canReadFull,
              hasQuestions: hasQuestions,
              showQuizAction: showQuizAction,
              onReadPreview: () {},
              onReadFull: () {},
              onBuy: () {},
              onQuiz: () {},
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('hides quiz action until the full read action is unlocked', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        canReadFull: true,
        hasQuestions: true,
        showQuizAction: false,
      ),
    );

    expect(find.text('อ่านฉบับเต็ม'), findsOneWidget);
    expect(find.text('ทำโจทย์บทนี้'), findsNothing);
  });

  testWidgets('shows quiz action after the full read action is unlocked', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(canReadFull: true, hasQuestions: true, showQuizAction: true),
    );

    expect(find.text('อ่านฉบับเต็ม'), findsOneWidget);
    expect(find.text('ทำโจทย์บทนี้'), findsOneWidget);
  });

  testWidgets('keeps quiz action hidden when there are no questions', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        canReadFull: true,
        hasQuestions: false,
        showQuizAction: true,
      ),
    );

    expect(find.text('อ่านฉบับเต็ม'), findsOneWidget);
    expect(find.text('ทำโจทย์บทนี้'), findsNothing);
  });
}
