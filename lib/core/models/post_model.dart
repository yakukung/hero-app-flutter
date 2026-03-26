import 'enums.dart';
import 'user_model.dart';

class PostModel {
  final String id;
  final String? sheetId;
  final String userId;
  final String content;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final UserModel author;
  final bool visibleFlag;
  final StatusFlag statusFlag;
  final DateTime createdAt;
  final String createdBy; // Added createdBy from operation
  final bool isLiked; // Added to track user's like status
  final List<PostLikeModel> likes;
  final List<PostCommentModel> comments;
  final List<PostShareModel> shares;

  PostModel({
    required this.id,
    this.sheetId,
    required this.userId,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.author,
    required this.visibleFlag,
    required this.statusFlag,
    required this.createdAt,
    required this.createdBy,
    this.isLiked = false,
    this.likes = const [],
    this.comments = const [],
    this.shares = const [],
  });

  factory PostModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final flag = json['flag'] ?? {};
    final operation = json['operation'] ?? {};
    int safeCount(dynamic value) =>
        value is num ? value.toInt() : int.tryParse(value.toString()) ?? 0;

    int extractCount(dynamic raw, dynamic totalItems, List<dynamic>? dataList) {
      if (totalItems != null) return safeCount(totalItems);
      if (dataList != null) return dataList.length;
      if (raw != null) return safeCount(raw);
      return 0;
    }

    final likesNode = json['likes'];
    final commentsNode = json['comments'];
    final sharesNode = json['shares'];
    final likesData = (likesNode is Map && likesNode['data'] is List)
        ? likesNode['data'] as List
        : null;
    final commentsData = (commentsNode is Map && commentsNode['data'] is List)
        ? commentsNode['data'] as List
        : null;
    final sharesData = (sharesNode is Map && sharesNode['data'] is List)
        ? sharesNode['data'] as List
        : null;
    final likesTotal = (likesNode is Map && likesNode['total_items'] != null)
        ? likesNode['total_items']
        : null;
    final commentsTotal =
        (commentsNode is Map && commentsNode['total_items'] != null)
        ? commentsNode['total_items']
        : null;
    final sharesTotal = (sharesNode is Map && sharesNode['total_items'] != null)
        ? sharesNode['total_items']
        : null;

    return PostModel(
      id: json['id'],
      sheetId: json['sheet_id'],
      userId: json['user_id'],
      content: json['content'],
      likeCount: extractCount(json['like_count'], likesTotal, likesData),
      commentCount: extractCount(
        json['comment_count'],
        commentsTotal,
        commentsData,
      ),
      shareCount: extractCount(json['share_count'], sharesTotal, sharesData),
      author: UserModel.fromJson(json['author'] ?? {}),
      visibleFlag: flag['visible_flag'] == true || flag['visible_flag'] == 1,
      statusFlag: StatusFlag.fromString(flag['status_flag']),
      createdAt: DateTime.parse(
        operation['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      createdBy: operation['created_by'] ?? 'SYSTEM',
      isLiked:
          (json['is_liked'] == true || json['is_liked'] == 1) ||
          (json['likes'] != null &&
              json['likes']['data'] is List &&
              currentUserId != null &&
              (json['likes']['data'] as List).any((like) {
                if (like is! Map) return false;
                final likeUserId = like['user_id']?.toString();
                final likeId = like['id']?.toString();
                return likeUserId == currentUserId || likeId == currentUserId;
              })),
      likes: json['likes'] != null && json['likes']['data'] is List
          ? (json['likes']['data'] as List)
                .where((e) => e is Map<String, dynamic> || e is Map)
                .map((e) => PostLikeModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      comments: json['comments'] != null && json['comments']['data'] is List
          ? (json['comments']['data'] as List)
                .where((e) => e is Map<String, dynamic> || e is Map)
                .map(
                  (e) => PostCommentModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
      shares: json['shares'] != null && json['shares']['data'] is List
          ? (json['shares']['data'] as List)
                .where((e) => e is Map<String, dynamic> || e is Map)
                .map((e) => PostShareModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  PostModel copyWith({
    String? id,
    String? sheetId,
    String? userId,
    String? content,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    UserModel? author,
    bool? visibleFlag,
    StatusFlag? statusFlag,
    DateTime? createdAt,
    String? createdBy,
    bool? isLiked,
    List<PostLikeModel>? likes,
    List<PostCommentModel>? comments,
    List<PostShareModel>? shares,
  }) {
    return PostModel(
      id: id ?? this.id,
      sheetId: sheetId ?? this.sheetId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      author: author ?? this.author,
      visibleFlag: visibleFlag ?? this.visibleFlag,
      statusFlag: statusFlag ?? this.statusFlag,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isLiked: isLiked ?? this.isLiked,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
    );
  }
}

class PostCommentModel {
  final String id;
  final String postId;
  final String userId;
  final UserModel? user;
  final String content;
  final DateTime createdAt;

  PostCommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.user,
    required this.content,
    required this.createdAt,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw =
        json['created_at'] ?? json['operation']?['created_at'] ?? '';
    final parsedDate = DateTime.tryParse(createdAtRaw.toString());
    final postId =
        json['post_id']?.toString() ?? json['postId']?.toString() ?? '';
    final userId =
        json['user_id']?.toString() ?? json['userId']?.toString() ?? '';
    final rawId = json['id'] ?? json['comment_id'] ?? json['commentId'];
    final synthesizedId =
        'gen-$postId-$userId-${createdAtRaw.toString()}-${json['content']?.hashCode ?? ''}';

    return PostCommentModel(
      id: (rawId?.toString().isNotEmpty ?? false)
          ? rawId.toString()
          : synthesizedId,
      postId: postId,
      userId: userId,
      user: json['user'] is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
      content: json['content']?.toString() ?? '',
      createdAt: parsedDate ?? DateTime.now(),
    );
  }
}

class PostLikeModel {
  final String userId;

  PostLikeModel({required this.userId});

  factory PostLikeModel.fromJson(Map<String, dynamic> json) {
    return PostLikeModel(userId: json['user_id']);
  }
}

class PostShareModel {
  final String userId;

  PostShareModel({required this.userId});

  factory PostShareModel.fromJson(Map<String, dynamic> json) {
    return PostShareModel(userId: json['user_id']);
  }
}
