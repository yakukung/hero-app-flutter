import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/models/category_model.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/services/sheet_upload_service.dart';
import 'package:hero_app_flutter/features/user/upload/controllers/upload_page_controller.dart';
import 'package:hero_app_flutter/validations/validation_messages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'submit returns validation error when required fields are missing',
    () async {
      final controller = UploadPageController(
        fetchCategories: () async => const <CategoryModel>[],
        submitUpload: ({required data, onProgress}) async {
          return const SheetUploadResult(
            success: true,
            statusCode: 201,
            message: 'unexpected',
          );
        },
      );

      final result = await controller.submit();

      expect(result.validationError, isNotNull);
      expect(
        result.validationError?.message,
        ValidationMessages.uploadImageRequired,
      );
      controller.dispose();
    },
  );

  test('loadCategories and submit build payload with progress state', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'upload_page_controller_test',
    );
    final imageFile = File('${tempDir.path}/sheet.png')
      ..writeAsBytesSync(<int>[1, 2, 3, 4]);
    late SheetUploadData capturedData;

    final controller = UploadPageController(
      fetchCategories: () async => [
        CategoryModel(
          id: 'cat-1',
          name: 'Biology',
          visibleFlag: true,
          statusFlag: StatusFlag.ACTIVE,
        ),
      ],
      submitUpload: ({required data, onProgress}) async {
        capturedData = data;
        onProgress?.call(5, 10);
        return const SheetUploadResult(
          success: true,
          statusCode: 201,
          message: 'อัปโหลดชีตสำเร็จ',
        );
      },
    );

    try {
      await controller.loadCategories();
      controller.addImages([imageFile]);
      controller.titleController.text = 'Biology Sheet';
      controller.descriptionController.text = 'Summary description';
      controller.setSelectedSubject('Biology');
      controller.setSelectedPrice('50');
      controller.addKeyword('cell');
      controller.toggleQuestions(true);
      controller.questionControllers[0]?.text = 'What is a cell?';
      controller.answerControllers[0]?[0]?.text = 'Answer A';
      controller.answerControllers[0]?[1]?.text = 'Answer B';
      controller.setCorrectAnswer(0, 0);

      final result = await controller.submit();

      expect(controller.categories, hasLength(1));
      expect(result.isSuccess, isTrue);
      expect(capturedData.title, 'Biology Sheet');
      expect(capturedData.categoryId, 'Biology');
      expect(capturedData.keywords, ['cell']);
      expect(capturedData.questions, isNotEmpty);
      expect(controller.uploadStateNotifier.value.progress, 1.0);
      expect(controller.uploadStateNotifier.value.isSuccess, isTrue);
    } finally {
      controller.dispose();
      await tempDir.delete(recursive: true);
    }
  });
}
