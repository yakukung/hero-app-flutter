import 'dart:io';
import 'dart:math' as math;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

typedef PdfPageRenderProgress = void Function(int pageNumber, int pageCount);

class PdfPageRenderException implements Exception {
  const PdfPageRenderException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() {
    if (cause == null) {
      return message;
    }
    return '$message: $cause';
  }
}

class PdfPageRenderService {
  const PdfPageRenderService({
    this.renderScale = 2.0,
    this.maxRenderDimension = 2200,
    this.jpegQuality = 92,
  });

  final double renderScale;
  final double maxRenderDimension;
  final int jpegQuality;

  Future<List<File>> renderPages(
    File pdfFile, {
    PdfPageRenderProgress? onProgress,
  }) async {
    PdfDocument? document;
    final renderedPages = <File>[];

    try {
      document = await PdfDocument.openFile(pdfFile.path);
      final pageCount = document.pagesCount;
      if (pageCount < 1) {
        throw const PdfPageRenderException('PDF นี้ไม่มีหน้าที่สามารถแยกได้');
      }

      onProgress?.call(0, pageCount);

      final outputDirectory = await _createOutputDirectory();
      final outputPrefix = _buildOutputPrefix(pdfFile);

      for (var pageNumber = 1; pageNumber <= pageCount; pageNumber++) {
        PdfPage? page;
        try {
          page = await document.getPage(pageNumber);
          final size = _targetSizeFor(page);
          final pageImage = await page.render(
            width: size.width,
            height: size.height,
            format: PdfPageImageFormat.jpeg,
            backgroundColor: '#FFFFFF',
            quality: jpegQuality,
          );

          if (pageImage == null) {
            throw PdfPageRenderException(
              'ไม่สามารถแยกหน้า PDF หน้า $pageNumber ได้',
            );
          }

          final outputFile = File(
            p.join(
              outputDirectory.path,
              '${outputPrefix}_page_${pageNumber.toString().padLeft(3, '0')}.jpg',
            ),
          );
          await outputFile.writeAsBytes(pageImage.bytes, flush: true);
          renderedPages.add(outputFile);
          onProgress?.call(pageNumber, pageCount);
        } finally {
          await page?.close();
        }
      }

      return renderedPages;
    } catch (error) {
      for (final file in renderedPages) {
        try {
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {
          // Best effort cleanup for partially rendered pages.
        }
      }

      if (error is PdfPageRenderException) {
        rethrow;
      }
      throw PdfPageRenderException('ไม่สามารถแยกหน้า PDF ได้', error);
    } finally {
      await document?.close();
    }
  }

  Future<Directory> _createOutputDirectory() async {
    final tempDirectory = await getTemporaryDirectory();
    final outputDirectory = Directory(
      p.join(tempDirectory.path, 'sheet_pdf_pages'),
    );
    return outputDirectory.create(recursive: true);
  }

  String _buildOutputPrefix(File pdfFile) {
    final rawName = p.basenameWithoutExtension(pdfFile.path);
    final safeName = rawName.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
    final normalizedName = safeName.isEmpty ? 'sheet_pdf' : safeName;
    return '${normalizedName}_${DateTime.now().microsecondsSinceEpoch}';
  }

  ({double width, double height}) _targetSizeFor(PdfPage page) {
    if (page.width <= 0 || page.height <= 0) {
      throw PdfPageRenderException(
        'ไม่สามารถอ่านขนาดของหน้า PDF หน้า ${page.pageNumber} ได้',
      );
    }

    final scaledWidth = page.width * renderScale;
    final scaledHeight = page.height * renderScale;
    final longestSide = math.max(scaledWidth, scaledHeight);
    if (longestSide <= maxRenderDimension) {
      return (width: scaledWidth, height: scaledHeight);
    }

    final resizeRatio = maxRenderDimension / longestSide;
    return (
      width: scaledWidth * resizeRatio,
      height: scaledHeight * resizeRatio,
    );
  }
}
