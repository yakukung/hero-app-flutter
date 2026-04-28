import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
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

  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? UploadPageController();
    unawaited(_controller.loadCategories());
  }

  @override
  void dispose() {
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
