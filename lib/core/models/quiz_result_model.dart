class QuizResultModel {
  const QuizResultModel({
    required this.sheetId,
    required this.score,
    required this.totalQuestions,
    required this.answers,
    required this.elapsedSeconds,
    this.pointsEarned = 0,
  });

  final String sheetId;
  final int score;
  final int totalQuestions;
  final Map<int, int?> answers;
  final int elapsedSeconds;
  final int pointsEarned;

  Map<String, dynamic> toJson() {
    return {
      'sheet_id': sheetId,
      'score': score,
      'total_questions': totalQuestions,
      'elapsed_seconds': elapsedSeconds,
      'answers': answers.map((key, value) => MapEntry(key.toString(), value)),
      'points_earned': pointsEarned,
    };
  }
}
