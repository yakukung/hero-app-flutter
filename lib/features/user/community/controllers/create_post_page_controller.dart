import 'package:flutter/material.dart';

import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/services/posts_service.dart';

typedef SubmitPost =
    Future<bool> Function({required String content, String? sheetId});

class CreatePostSubmissionResult {
  const CreatePostSubmissionResult({
    required this.success,
    required this.message,
    this.isValidationError = false,
  });

  final bool success;
  final String message;
  final bool isValidationError;
}

class CreatePostPageController extends ChangeNotifier {
  CreatePostPageController({SubmitPost? submitPost})
    : _submitPost = submitPost ?? PostsService.createPost;

  final SubmitPost _submitPost;

  final TextEditingController contentController = TextEditingController();

  SheetModel? _selectedSheet;
  bool _isSubmitting = false;

  SheetModel? get selectedSheet => _selectedSheet;
  bool get isSubmitting => _isSubmitting;

  void selectSheet(SheetModel sheet) {
    _selectedSheet = sheet;
    notifyListeners();
  }

  void removeSelectedSheet() {
    _selectedSheet = null;
    notifyListeners();
  }

  Future<CreatePostSubmissionResult> submit() async {
    if (contentController.text.trim().isEmpty) {
      return const CreatePostSubmissionResult(
        success: false,
        message: 'กรุณาใส่ข้อความ',
        isValidationError: true,
      );
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final success = await _submitPost(
        content: contentController.text,
        sheetId: _selectedSheet?.id,
      );
      return CreatePostSubmissionResult(
        success: success,
        message: success ? 'สร้างโพสต์สำเร็จ' : 'เกิดข้อผิดพลาดในการสร้างโพสต์',
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }
}
