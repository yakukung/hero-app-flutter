import 'enums.dart';

class PostModel {
  final String id;
  final String sheetId;
  final String userId;
  final String content;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool visibleFlag;
  final StatusFlag statusFlag;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.sheetId,
    required this.userId,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.visibleFlag,
    required this.statusFlag,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      sheetId: json['sheet_id'],
      userId: json['user_id'],
      content: json['content'],
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      shareCount: json['share_count'] ?? 0,
      visibleFlag: json['visible_flag'] == 1 || json['visible_flag'] == true,
      statusFlag: StatusFlag.fromString(json['status_flag']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class PostCommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;

  PostCommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
