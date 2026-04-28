import 'package:flutter/material.dart';

import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/shared/widgets/upload/question_section.dart';

class UploadSubmissionSection extends StatelessWidget {
  const UploadSubmissionSection({
    super.key,
    required this.isQuestionsEnabled,
    required this.questionCount,
    required this.answerCounts,
    required this.correctAnswers,
    required this.questionControllers,
    required this.explanationControllers,
    required this.answerControllers,
    required this.onToggleQuestions,
    required this.onQuestionCountChanged,
    required this.onAnswerCountChanged,
    required this.onCorrectAnswerChanged,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final bool isQuestionsEnabled;
  final int questionCount;
  final Map<int, int> answerCounts;
  final Map<int, int> correctAnswers;
  final Map<int, TextEditingController> questionControllers;
  final Map<int, TextEditingController> explanationControllers;
  final Map<int, Map<int, TextEditingController>> answerControllers;
  final ValueChanged<bool> onToggleQuestions;
  final ValueChanged<int> onQuestionCountChanged;
  final void Function(int questionIndex, int count) onAnswerCountChanged;
  final void Function(int questionIndex, int answerIndex)
  onCorrectAnswerChanged;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionSection(
          isEnabled: isQuestionsEnabled,
          questionCount: questionCount,
          answerCounts: answerCounts,
          correctAnswers: correctAnswers,
          questionControllers: questionControllers,
          explanationControllers: explanationControllers,
          answerControllers: answerControllers,
          onToggle: onToggleQuestions,
          onQuestionCountChanged: onQuestionCountChanged,
          onAnswerCountChanged: onAnswerCountChanged,
          onCorrectAnswerChanged: onCorrectAnswerChanged,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            key: const Key('upload_submit_button'),
            onPressed: isSubmitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isSubmitting ? 'กำลังอัปโหลด...' : 'อัปโหลดชีต',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
