import 'dart:io';

import 'package:flutter/material.dart';

import 'package:hero_app_flutter/core/models/category_model.dart';
import 'package:hero_app_flutter/core/models/upload_state.dart';
import 'package:hero_app_flutter/core/services/sheet_upload_service.dart';
import 'package:hero_app_flutter/core/services/sheets_service.dart';
import 'package:hero_app_flutter/validations/upload_validators.dart';
import 'package:hero_app_flutter/validations/validation_error.dart';

typedef FetchUploadCategories = Future<List<CategoryModel>> Function();
typedef SubmitSheetUpload =
    Future<SheetUploadResult> Function({
      required SheetUploadData data,
      void Function(int bytes, int total)? onProgress,
    });

class UploadPageSubmissionResult {
  const UploadPageSubmissionResult({this.validationError, this.uploadResult});

  final ValidationError? validationError;
  final SheetUploadResult? uploadResult;

  bool get isSuccess => uploadResult?.success ?? false;
}

class UploadPageController extends ChangeNotifier {
  UploadPageController({
    FetchUploadCategories? fetchCategories,
    SubmitSheetUpload? submitUpload,
  }) : _fetchCategories = fetchCategories ?? SheetsService.fetchCategories,
       _submitUpload = submitUpload ?? SheetUploadService.uploadSheet {
    _syncQuestionControllers();
  }

  static const List<String> availablePrices = <String>[
    '0',
    '50',
    '100',
    '150',
    '200',
    '250',
    '300',
  ];

  final FetchUploadCategories _fetchCategories;
  final SubmitSheetUpload _submitUpload;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final Map<int, TextEditingController> questionControllers = {};
  final Map<int, TextEditingController> explanationControllers = {};
  final Map<int, Map<int, TextEditingController>> answerControllers = {};
  final Map<int, int> answerCounts = <int, int>{0: 2};
  final Map<int, int> correctAnswers = <int, int>{};
  final ValueNotifier<UploadState> uploadStateNotifier = ValueNotifier(
    const UploadState(),
  );

  List<CategoryModel> _categories = const <CategoryModel>[];
  bool _isLoadingCategories = true;
  String? _selectedSubject;
  String? _selectedPrice;
  List<String> _keywords = <String>[];
  List<File> _uploadedImages = <File>[];
  int _questionCount = 1;
  bool _isQuestionsEnabled = false;
  bool _isSubmitting = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get selectedSubject => _selectedSubject;
  String? get selectedPrice => _selectedPrice;
  List<String> get keywords => _keywords;
  List<File> get uploadedImages => _uploadedImages;
  int get questionCount => _questionCount;
  bool get isQuestionsEnabled => _isQuestionsEnabled;
  bool get isSubmitting => _isSubmitting;

  Future<void> loadCategories() async {
    try {
      _categories = await _fetchCategories();
    } catch (error) {
      debugPrint('Error fetching categories: $error');
      _categories = const <CategoryModel>[];
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  void setSelectedSubject(String subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void setSelectedPrice(String price) {
    _selectedPrice = price;
    notifyListeners();
  }

  void addKeyword(String keyword) {
    if (keyword.trim().isEmpty) {
      return;
    }
    _keywords = List<String>.from(_keywords)..add(keyword.trim());
    notifyListeners();
  }

  void removeKeyword(String keyword) {
    _keywords = List<String>.from(_keywords)..remove(keyword);
    notifyListeners();
  }

  void addImages(Iterable<File> images) {
    _uploadedImages = List<File>.from(_uploadedImages)..addAll(images);
    notifyListeners();
  }

  void removeImageAt(int index) {
    _uploadedImages = List<File>.from(_uploadedImages)..removeAt(index);
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    final images = List<File>.from(_uploadedImages);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = images.removeAt(oldIndex);
    images.insert(newIndex, item);
    _uploadedImages = images;
    notifyListeners();
  }

  void toggleQuestions(bool enabled) {
    _isQuestionsEnabled = enabled;
    notifyListeners();
  }

  void setQuestionCount(int count) {
    _questionCount = count.clamp(1, 10).toInt();
    _syncQuestionControllers();
    notifyListeners();
  }

  void setAnswerCount(int questionIndex, int count) {
    answerCounts[questionIndex] = count.clamp(1, 6).toInt();
    _syncAnswerControllers(questionIndex);

    final correctAnswer = correctAnswers[questionIndex];
    if (correctAnswer != null &&
        correctAnswer >= (answerCounts[questionIndex] ?? 0)) {
      correctAnswers.remove(questionIndex);
    }
    notifyListeners();
  }

  void setCorrectAnswer(int questionIndex, int answerIndex) {
    correctAnswers[questionIndex] = answerIndex;
    notifyListeners();
  }

  ValidationError? validate() {
    return validateSheetUpload(
      images: _uploadedImages,
      title: titleController.text,
      description: descriptionController.text,
      selectedSubject: _selectedSubject,
      selectedPrice: _selectedPrice,
      isQuestionsEnabled: _isQuestionsEnabled,
      questionCount: _questionCount,
      questionControllers: questionControllers,
      answerControllers: answerControllers,
      answerCounts: answerCounts,
      correctAnswers: correctAnswers,
    );
  }

  Future<UploadPageSubmissionResult> submit() async {
    final validationError = validate();
    if (validationError != null) {
      return UploadPageSubmissionResult(validationError: validationError);
    }

    _isSubmitting = true;
    uploadStateNotifier.value = const UploadState(isUploading: true);
    notifyListeners();

    final data = SheetUploadData(
      title: titleController.text,
      description: descriptionController.text,
      categoryId: _selectedSubject ?? '',
      keywords: _keywords,
      price: _selectedPrice ?? '',
      images: _uploadedImages,
      questions: _buildQuestionsData(),
    );

    final result = await _submitUpload(
      data: data,
      onProgress: (bytes, total) {
        uploadStateNotifier.value = uploadStateNotifier.value.copyWith(
          progress: total == 0 ? 0 : bytes / total,
        );
      },
    );

    uploadStateNotifier.value = UploadState(
      progress: result.success ? 1.0 : uploadStateNotifier.value.progress,
      isUploading: false,
      isSuccess: result.success,
      errorMessage: result.success ? null : result.message,
    );
    _isSubmitting = false;
    notifyListeners();

    return UploadPageSubmissionResult(uploadResult: result);
  }

  List<Map<String, dynamic>> _buildQuestionsData() {
    if (!_isQuestionsEnabled) {
      return <Map<String, dynamic>>[];
    }

    final questionsList = <Map<String, dynamic>>[];
    for (int i = 0; i < _questionCount; i++) {
      final answersList = <Map<String, dynamic>>[];
      final answerCount = answerCounts[i] ?? 2;

      for (int j = 0; j < answerCount; j++) {
        answersList.add({
          'index': j + 1,
          'answer_text': answerControllers[i]?[j]?.text ?? '',
          'is_correct': correctAnswers[i] == j,
        });
      }

      questionsList.add({
        'index': i + 1,
        'question_text': questionControllers[i]?.text ?? '',
        'explanation': explanationControllers[i]?.text ?? '',
        'answers': answersList,
      });
    }

    return questionsList;
  }

  void _syncQuestionControllers() {
    for (int i = 0; i < _questionCount; i++) {
      questionControllers.putIfAbsent(i, TextEditingController.new);
      explanationControllers.putIfAbsent(i, TextEditingController.new);
      answerCounts.putIfAbsent(i, () => 2);
      _syncAnswerControllers(i);
    }

    final removableQuestions = questionControllers.keys
        .where((index) => index >= _questionCount)
        .toList();
    for (final index in removableQuestions) {
      questionControllers.remove(index)?.dispose();
      explanationControllers.remove(index)?.dispose();
      final removedAnswers = answerControllers.remove(index);
      if (removedAnswers != null) {
        for (final controller in removedAnswers.values) {
          controller.dispose();
        }
      }
      answerCounts.remove(index);
      correctAnswers.remove(index);
    }
  }

  void _syncAnswerControllers(int questionIndex) {
    final count = answerCounts[questionIndex] ?? 2;
    final controllers = answerControllers.putIfAbsent(
      questionIndex,
      () => <int, TextEditingController>{},
    );

    for (int i = 0; i < count; i++) {
      controllers.putIfAbsent(i, TextEditingController.new);
    }

    final removableAnswers = controllers.keys
        .where((index) => index >= count)
        .toList();
    for (final index in removableAnswers) {
      controllers.remove(index)?.dispose();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    for (final controller in questionControllers.values) {
      controller.dispose();
    }
    for (final controller in explanationControllers.values) {
      controller.dispose();
    }
    for (final questionMap in answerControllers.values) {
      for (final controller in questionMap.values) {
        controller.dispose();
      }
    }
    uploadStateNotifier.dispose();
    super.dispose();
  }
}
