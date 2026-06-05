import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/services/pdf_page_render_service.dart';

void main() {
  test('validatePageCount rejects PDFs over the max page count', () {
    expect(
      () => PdfPageRenderService.validatePageCount(11, maxPages: 10),
      throwsA(
        isA<PdfPageRenderException>().having(
          (error) => error.message,
          'message',
          'อัปโหลดชีตได้สูงสุด 10 หน้า',
        ),
      ),
    );
  });

  test('validatePageCount allows PDFs at the max page count', () {
    expect(
      () => PdfPageRenderService.validatePageCount(10, maxPages: 10),
      returnsNormally,
    );
  });
}
