import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/validations/upload_validators.dart';
import 'package:hero_app_flutter/validations/validation_messages.dart';

void main() {
  test('validateSheetUpload rejects more than 10 pages', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'upload_validators_page_count_test',
    );
    final imageFiles = List<File>.generate(
      maxSheetUploadPageCount + 1,
      (index) =>
          File('${tempDir.path}/sheet_page_$index.jpg')
            ..writeAsBytesSync(<int>[index]),
    );

    try {
      final result = validateSheetUpload(
        images: imageFiles,
        title: 'Sheet',
        description: 'Description',
        selectedSubject: 'cat-1',
        selectedPrice: '0',
        isQuestionsEnabled: false,
        questionCount: 1,
        questionControllers: const <int, TextEditingController>{},
        answerControllers: const <int, Map<int, TextEditingController>>{},
        answerCounts: const <int, int>{},
        correctAnswers: const <int, int>{},
      );

      expect(result, isNotNull);
      expect(result?.message, ValidationMessages.uploadPageCountTooLarge);
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
