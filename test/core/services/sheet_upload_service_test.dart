import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:hero_app_flutter/core/services/sheet_upload_service.dart';

import '../../support/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    dotenv.loadFromString(
      envString: 'HTTP_SCHEME=http\nAPI_HOST=localhost\nAPI_PORT=3000',
    );
    await GetStorage.init();
  });

  test(
    'uploadSheet returns success result and forwards multipart payload',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'sheet_upload_service_test',
      );
      final imageFile = File('${tempDir.path}/sheet.png')
        ..writeAsBytesSync(<int>[1, 2, 3, 4]);
      final progressUpdates = <double>[];

      try {
        final result = await SheetUploadService.uploadSheet(
          data: SheetUploadData(
            title: 'Biology Sheet',
            description: 'Summary description',
            categoryId: 'biology',
            keywords: const ['cell', 'exam'],
            price: '50',
            images: [imageFile],
            questions: const [
              {
                'index': 1,
                'question_text': 'What is a cell?',
                'explanation': 'Basic unit',
                'answers': [
                  {'index': 1, 'answer_text': 'Answer A', 'is_correct': true},
                  {'index': 2, 'answer_text': 'Answer B', 'is_correct': false},
                ],
              },
            ],
          ),
          onProgress: (bytes, total) {
            progressUpdates.add(total == 0 ? 0 : bytes / total);
          },
          sendRequest: (request) async {
            expect(request.fields['title'], 'Biology Sheet');
            expect(request.fields['description'], 'Summary description');
            expect(request.fields['category'], 'biology');
            expect(request.fields['keywords'], jsonEncode(['cell', 'exam']));
            expect(request.fields['price'], '50');
            expect(request.fields['questions'], contains('What is a cell?'));
            expect(request.files, hasLength(1));

            await request.finalize().drain<void>();
            return http.Response('{}', 201);
          },
        );

        expect(result.success, isTrue);
        expect(result.statusCode, 201);
        expect(result.message, 'อัปโหลดชีตสำเร็จ');
        expect(progressUpdates, isNotEmpty);
      } finally {
        await tempDir.delete(recursive: true);
      }
    },
  );

  test(
    'uploadSheet returns failure result for non-success status codes',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'sheet_upload_service_failure_test',
      );
      final imageFile = File('${tempDir.path}/sheet.jpg')
        ..writeAsBytesSync(<int>[1, 2, 3, 4]);

      try {
        final result = await SheetUploadService.uploadSheet(
          data: SheetUploadData(
            title: 'Chemistry Sheet',
            description: 'Summary description',
            categoryId: 'chemistry',
            keywords: const ['acid'],
            price: '0',
            images: [imageFile],
          ),
          sendRequest: (request) async {
            await request.finalize().drain<void>();
            return http.Response('bad request', 400);
          },
        );

        expect(result.success, isFalse);
        expect(result.statusCode, 400);
        expect(result.message, 'อัปโหลดล้มเหลว: 400');
      } finally {
        await tempDir.delete(recursive: true);
      }
    },
  );
}
