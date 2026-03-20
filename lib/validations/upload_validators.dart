import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/validations/validation_error.dart';
import 'package:flutter_application_1/validations/validation_messages.dart';

ValidationError? validateSheetUpload({
  required List<File> images,
  required String title,
  required String description,
  required String? selectedSubject,
  required String? selectedPrice,
  required bool isQuestionsEnabled,
  required int questionCount,
  required Map<int, TextEditingController> questionControllers,
  required Map<int, Map<int, TextEditingController>> answerControllers,
  required Map<int, int> answerCounts,
  required Map<int, int> correctAnswers,
}) {
  if (images.isEmpty) {
    return const ValidationError(
      title: ValidationMessages.incompleteInfoTitle,
      message: ValidationMessages.uploadImageRequired,
    );
  }
  if (title.trim().isEmpty) {
    return const ValidationError(
      title: ValidationMessages.incompleteInfoTitle,
      message: ValidationMessages.uploadTitleRequired,
    );
  }
  if (description.trim().isEmpty) {
    return const ValidationError(
      title: ValidationMessages.incompleteInfoTitle,
      message: ValidationMessages.uploadDescriptionRequired,
    );
  }
  if (selectedSubject == null) {
    return const ValidationError(
      title: ValidationMessages.incompleteInfoTitle,
      message: ValidationMessages.uploadSubjectRequired,
    );
  }
  if (selectedPrice == null) {
    return const ValidationError(
      title: ValidationMessages.incompleteInfoTitle,
      message: ValidationMessages.uploadPriceRequired,
    );
  }

  if (isQuestionsEnabled) {
    for (int i = 0; i < questionCount; i++) {
      final questionText = questionControllers[i]?.text.trim() ?? '';
      if (questionText.isEmpty) {
        return ValidationError(
          title: ValidationMessages.incompleteInfoTitle,
          message: ValidationMessages.uploadQuestionRequired(i + 1),
        );
      }

      if (!correctAnswers.containsKey(i)) {
        return ValidationError(
          title: ValidationMessages.incompleteInfoTitle,
          message: ValidationMessages.uploadCorrectAnswerRequired(i + 1),
        );
      }

      final answerCount = answerCounts[i] ?? 2;
      final answersForQuestion = answerControllers[i];
      for (int j = 0; j < answerCount; j++) {
        final answerText = answersForQuestion?[j]?.text.trim() ?? '';
        if (answerText.isEmpty) {
          final label = String.fromCharCode(65 + j); // A, B, C, D...
          return ValidationError(
            title: ValidationMessages.incompleteInfoTitle,
            message: ValidationMessages.uploadAnswerRequired(label, i + 1),
          );
        }
      }
    }
  }

  return null;
}
