import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/core/services/pdf_page_render_service.dart';
import 'package:hero_app_flutter/features/user/upload/controllers/upload_page_controller.dart';
import 'package:hero_app_flutter/features/user/upload/widgets/upload_metadata_section.dart';
import 'package:hero_app_flutter/features/user/upload/widgets/upload_page_header.dart';
import 'package:hero_app_flutter/features/user/upload/widgets/upload_submission_section.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:hero_app_flutter/shared/widgets/upload/image_upload_section.dart';
import 'package:hero_app_flutter/shared/widgets/upload/keyword_section.dart';
import 'package:hero_app_flutter/shared/widgets/upload/upload_progress_dialog.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key, this.controller});

  final UploadPageController? controller;

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  late final UploadPageController _controller;
  final ImagePicker _picker = ImagePicker();
  final PdfPageRenderService _pdfPageRenderService =
      const PdfPageRenderService();
  final ValueNotifier<_PdfRenderProgress> _pdfRenderProgressNotifier =
      ValueNotifier(const _PdfRenderProgress());
  NavigatorState? _pdfRenderNavigator;
  bool _isPdfRenderDialogOpen = false;

  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? UploadPageController();
    unawaited(_controller.loadCategories());
  }

  @override
  void dispose() {
    _hidePdfRenderDialog();
    _pdfRenderProgressNotifier.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isEmpty) {
      return;
    }

    _controller.addImages(images.map((image) => File(image.path)));
  }

  Future<void> _pickPdf() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
    } catch (error) {
      await _showPdfRenderError('ไม่สามารถเลือกไฟล์ PDF ได้: $error');
      return;
    }

    if (result == null) {
      return;
    }

    final pdfPath = result.files.single.path;
    if (pdfPath == null || pdfPath.isEmpty) {
      await _showPdfRenderError('ไม่สามารถอ่านไฟล์ PDF จากอุปกรณ์นี้ได้');
      return;
    }

    final pdfFile = File(pdfPath);
    if (!await pdfFile.exists()) {
      await _showPdfRenderError('ไม่พบไฟล์ PDF ที่เลือก');
      return;
    }

    var renderedPages = <File>[];
    String? errorMessage;

    _pdfRenderProgressNotifier.value = const _PdfRenderProgress();
    _showPdfRenderDialog();

    try {
      renderedPages = await _pdfPageRenderService.renderPages(
        pdfFile,
        onProgress: (pageNumber, pageCount) {
          _pdfRenderProgressNotifier.value = _PdfRenderProgress(
            pageNumber: pageNumber,
            pageCount: pageCount,
          );
        },
      );
      if (renderedPages.isEmpty) {
        errorMessage = 'ไม่พบหน้าที่แยกได้จาก PDF';
      }
    } on PdfPageRenderException catch (error) {
      errorMessage = error.message;
    } catch (error) {
      errorMessage = 'ไม่สามารถแยกหน้า PDF ได้: $error';
    } finally {
      _hidePdfRenderDialog();
    }

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      await _showPdfRenderError(errorMessage);
      return;
    }

    _controller.addImages(renderedPages);
  }

  void _showPdfRenderDialog() {
    if (!mounted || _isPdfRenderDialogOpen) {
      return;
    }

    _isPdfRenderDialogOpen = true;
    _pdfRenderNavigator = Navigator.of(context, rootNavigator: true);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _buildPdfRenderProgressDialog(),
      ).whenComplete(() {
        _isPdfRenderDialogOpen = false;
        _pdfRenderNavigator = null;
      }),
    );
  }

  void _hidePdfRenderDialog() {
    if (!_isPdfRenderDialogOpen) {
      return;
    }

    _pdfRenderNavigator?.pop();
    _pdfRenderNavigator = null;
    _isPdfRenderDialogOpen = false;
  }

  Widget _buildPdfRenderProgressDialog() {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: ValueListenableBuilder<_PdfRenderProgress>(
          valueListenable: _pdfRenderProgressNotifier,
          builder: (context, progress, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                const Text(
                  'กำลังแยกหน้า PDF',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  progress.label,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(value: progress.value),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showPdfRenderError(String message) {
    if (!mounted) {
      return Future<void>.value();
    }

    return showCustomDialog(title: 'แยก PDF ไม่สำเร็จ', message: message);
  }

  Future<void> _handleSubmit() async {
    final validationError = _controller.validate();
    if (validationError != null) {
      await showCustomDialog(
        title: validationError.title,
        message: validationError.message,
      );
      return;
    }

    UploadProgressDialog.show(
      stateNotifier: _controller.uploadStateNotifier,
      onComplete: () {
        Get.find<NavigationController>().changeIndex(0);
      },
    );

    await _controller.submit();
  }

  Future<void> _openKeywordDialog() async {
    final keyword = await KeywordSection.showAddDialog(context);
    if (keyword == null) {
      return;
    }

    _controller.addKeyword(keyword);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const UploadPageHeader(),
                          const SizedBox(height: 24),
                          const Text(
                            'รูปภาพชีต',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ImageUploadSection(
                            images: _controller.uploadedImages,
                            onPickImage: _pickImages,
                            onPickPdf: _pickPdf,
                            onReorder: _controller.reorderImages,
                            onRemove: _controller.removeImageAt,
                          ),
                          const SizedBox(height: 24),
                          UploadMetadataSection(
                            titleController: _controller.titleController,
                            descriptionController:
                                _controller.descriptionController,
                            categories: _controller.categories,
                            selectedSubject: _controller.selectedSubject,
                            isLoadingCategories:
                                _controller.isLoadingCategories,
                            onSelectSubject: _controller.setSelectedSubject,
                            keywords: _controller.keywords,
                            onAddKeyword: _openKeywordDialog,
                            onRemoveKeyword: _controller.removeKeyword,
                            prices: UploadPageController.availablePrices,
                            selectedPrice: _controller.selectedPrice,
                            onSelectPrice: _controller.setSelectedPrice,
                          ),
                          const SizedBox(height: 32),
                          UploadSubmissionSection(
                            isQuestionsEnabled: _controller.isQuestionsEnabled,
                            questionCount: _controller.questionCount,
                            answerCounts: _controller.answerCounts,
                            correctAnswers: _controller.correctAnswers,
                            questionControllers:
                                _controller.questionControllers,
                            explanationControllers:
                                _controller.explanationControllers,
                            answerControllers: _controller.answerControllers,
                            onToggleQuestions: _controller.toggleQuestions,
                            onQuestionCountChanged:
                                _controller.setQuestionCount,
                            onAnswerCountChanged: _controller.setAnswerCount,
                            onCorrectAnswerChanged:
                                _controller.setCorrectAnswer,
                            onSubmit: _handleSubmit,
                            isSubmitting: _controller.isSubmitting,
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PdfRenderProgress {
  const _PdfRenderProgress({this.pageNumber = 0, this.pageCount = 0});

  final int pageNumber;
  final int pageCount;

  double? get value {
    if (pageCount == 0) {
      return null;
    }
    return pageNumber / pageCount;
  }

  String get label {
    if (pageCount == 0) {
      return 'กำลังเตรียมไฟล์...';
    }
    if (pageNumber == 0) {
      return 'พบทั้งหมด $pageCount หน้า';
    }
    return 'หน้า $pageNumber จาก $pageCount';
  }
}
