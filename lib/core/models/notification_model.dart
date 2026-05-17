class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'การแจ้งเตือน').toString(),
      message: (json['message'] ?? json['content'] ?? '').toString(),
      createdAt:
          DateTime.tryParse(
            (json['created_at'] ?? json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      isRead:
          json['is_read'] == true ||
          json['read'] == true ||
          json['is_read'] == 1,
    );
  }
}
