class QuestionModel {
  final String id;
  final String sheetId;
  final String questionText;
  final String? explanation;
  final int index;
  final List<AnswerModel>? answers;

  QuestionModel({
    required this.id,
    required this.sheetId,
    required this.questionText,
    this.explanation,
    required this.index,
    this.answers,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      sheetId: json['sheet_id'],
      questionText: json['question_text'],
      explanation: json['explanation'],
      index: json['index'] ?? 1,
      answers: (json['answers'] as List?)
          ?.map((e) => AnswerModel.fromJson(e))
          .toList(),
    );
  }
}

class AnswerModel {
  final String id;
  final String questionId;
  final String answerText;
  final bool isCorrect;
  final int index;

  AnswerModel({
    required this.id,
    required this.questionId,
    required this.answerText,
    required this.isCorrect,
    required this.index,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'],
      questionId: json['question_id'],
      answerText: json['answer_text'],
      isCorrect: json['is_correct'] == 1 || json['is_correct'] == true,
      index: json['index'] ?? 1,
    );
  }
}

class UserSheetAnswerModel {
  final String id;
  final String userId;
  final String questionId;
  final String selectedAnswerId;
  final bool? isCorrect;

  UserSheetAnswerModel({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.selectedAnswerId,
    this.isCorrect,
  });

  factory UserSheetAnswerModel.fromJson(Map<String, dynamic> json) {
    return UserSheetAnswerModel(
      id: json['id'],
      userId: json['user_id'],
      questionId: json['question_id'],
      selectedAnswerId: json['selected_answer_id'],
      isCorrect: json['is_correct'] != null
          ? (json['is_correct'] == 1 || json['is_correct'] == true)
          : null,
    );
  }
}
