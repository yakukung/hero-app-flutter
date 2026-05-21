class QuizLeaderboardEntryModel {
  final String userId;
  final String username;
  final String? profileImage;
  final int correctCount;

  QuizLeaderboardEntryModel({
    required this.userId,
    required this.username,
    this.profileImage,
    required this.correctCount,
  });

  factory QuizLeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return QuizLeaderboardEntryModel(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      profileImage: json['profile_image'],
      correctCount: json['correct_count'] ?? 0,
    );
  }
}
