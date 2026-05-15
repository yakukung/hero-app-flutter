import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/shared/widgets/upload/image_upload_section.dart';

void main() {
  testWidgets('shows one add button and opens file type options', (
    tester,
  ) async {
    var pickedImages = false;
    var pickedPdf = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageUploadSection(
            images: const <File>[],
            onPickImage: () => pickedImages = true,
            onPickPdf: () => pickedPdf = true,
            onReorder: (_, _) {},
            onRemove: (_) {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('add_sheet_file_button')), findsOneWidget);
    expect(find.byKey(const Key('pick_image_option')), findsNothing);
    expect(find.byKey(const Key('pick_pdf_option')), findsNothing);

    await tester.tap(find.byKey(const Key('add_sheet_file_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pick_image_option')), findsOneWidget);
    expect(find.byKey(const Key('pick_pdf_option')), findsOneWidget);

    await tester.tap(find.byKey(const Key('pick_image_option')));
    await tester.pumpAndSettle();
    expect(pickedImages, isTrue);
    expect(pickedPdf, isFalse);

    await tester.tap(find.byKey(const Key('add_sheet_file_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pick_pdf_option')));
    await tester.pumpAndSettle();
    expect(pickedPdf, isTrue);
  });
}
