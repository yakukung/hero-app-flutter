import 'enums.dart';
import 'question_model.dart';
import 'package:flutter_application_1/config/api_connect.dart';

class SheetModel {
  final String id;
  final String authorId;
  final String title;
  final String? description;
  final double? rating;
  final double? price;
  final bool visibleFlag;
  final StatusFlag statusFlag;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final String? authorName;
  final String? authorAvatar;
  final List<SheetFileModel>? files;
  final List<QuestionModel>? questions;
  final List<String>? categoryIds;
  final List<String>? keywordIds;
  final bool isPurchased;
  final bool isFavorite;

  SheetModel({
    required this.id,
    required this.authorId,
    required this.title,
    this.description,
    this.rating,
    this.price,
    required this.visibleFlag,
    required this.statusFlag,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.authorName,
    this.authorAvatar,
    this.files,
    this.questions,
    this.categoryIds,
    this.keywordIds,
    this.isPurchased = false,
    this.isFavorite = false,
  });

  factory SheetModel.fromJson(Map<String, dynamic> json) {
    // Handle nested objects if present
    final flagData = json['flag'] is Map<String, dynamic> ? json['flag'] : null;
    final operationData = json['operation'] is Map<String, dynamic>
        ? json['operation']
        : null;

    return SheetModel(
      id: json['id'] ?? '',
      authorId: json['author_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      rating: json['rating'] != null
          ? double.parse(json['rating'].toString())
          : null,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      visibleFlag:
          json['visible_flag'] == true ||
          json['visible_flag'] == 1 ||
          flagData?['visible_flag'] == true ||
          flagData?['visible_flag'] == 1,
      statusFlag: StatusFlag.fromString(
        json['status_flag'] ?? flagData?['status_flag'] ?? 'ACTIVE',
      ),
      createdAt: DateTime.parse(
        json['created_at'] ??
            operationData?['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
      createdBy: json['created_by'] ?? operationData?['created_by'] ?? 'SYSTEM',
      updatedAt: (json['updated_at'] ?? operationData?['updated_at']) != null
          ? DateTime.parse(json['updated_at'] ?? operationData?['updated_at'])
          : null,
      updatedBy: json['updated_by'] ?? operationData?['updated_by'],
      authorName: json['author_name'],
      authorAvatar: json['user_avatar'] ?? json['author_avatar'],
      files:
          (json['files'] as List?)
              ?.map((e) => SheetFileModel.fromJson(e))
              .toList()
            ?..sort((a, b) => a.index.compareTo(b.index)),
      questions:
          (json['questions'] as List?)
              ?.map((e) => QuestionModel.fromJson(e))
              .toList()
            ?..sort((a, b) => a.index.compareTo(b.index)),
      categoryIds: (json['category_ids'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      keywordIds: (json['keyword_ids'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      isPurchased:
          json['is_purchased'] == true ||
          json['purchased'] == true ||
          json['is_owned'] == true ||
          json['owned'] == true ||
          json['is_purchased'] == 1 ||
          json['purchased'] == 1,
      isFavorite:
          json['is_favorite'] == true ||
          json['favorite'] == true ||
          json['is_favorited'] == true ||
          json['favorited'] == true ||
          json['is_favorite'] == 1 ||
          json['favorite'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'title': title,
      'description': description,
      'rating': rating,
      'price': price,
      'visible_flag': visibleFlag,
      'status_flag': statusFlag.name,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
      'updated_by': updatedBy,
      'author_name': authorName,
    };
  }

  String get thumbnail {
    if (files == null || files!.isEmpty) return '';
    return files!.first.fullThumbnailUrl;
  }
}

class SheetFileModel {
  final String id;
  final String sheetId;
  final String format;
  final String size;
  final String originalPath;
  final String? thumbnailPath;
  final int index;
  final String? checksum;

  SheetFileModel({
    required this.id,
    required this.sheetId,
    required this.format,
    required this.size,
    required this.originalPath,
    this.thumbnailPath,
    required this.index,
    this.checksum,
  });

  factory SheetFileModel.fromJson(Map<String, dynamic> json) {
    // Handle potential nesting for paths (e.g., json['path']['original'])
    final pathData = json['path'] is Map<String, dynamic> ? json['path'] : null;

    return SheetFileModel(
      id: json['id'] ?? '',
      sheetId: json['sheet_id'] ?? '',
      format: json['format'] ?? '',
      size: json['size']?.toString() ?? '',
      originalPath:
          json['original_path'] ??
          pathData?['original_path'] ??
          pathData?['original'] ??
          '',
      thumbnailPath:
          json['thumbnail_path'] ??
          pathData?['thumbnail_path'] ??
          pathData?['thumbnail'] ??
          json['thumbnail'],
      index: json['index'] != null ? int.parse(json['index'].toString()) : 1,
      checksum: json['checksum'],
    );
  }

  String _resolveUrl(String path) {
    if (path.isEmpty) return '';
    final sanitizedPath = path.replaceAll('`', '').trim();
    if (sanitizedPath.startsWith('http')) return sanitizedPath;
    try {
      // Ensure apiEndpoint ends with a slash if needed, or use resolve
      // resolvelink requires the base to have a trailing slash if it's a directory
      final base = apiEndpoint.endsWith('/') ? apiEndpoint : '$apiEndpoint/';
      return Uri.parse(base).resolve(sanitizedPath).toString();
    } catch (e) {
      return sanitizedPath;
    }
  }

  String get fullOriginalUrl => _resolveUrl(originalPath);

  String get fullThumbnailUrl {
    if (thumbnailPath == null || thumbnailPath!.isEmpty) {
      return fullOriginalUrl;
    }
    return _resolveUrl(thumbnailPath!);
  }
}

class SheetReviewModel {
  final String id;
  final String sheetId;
  final String userId;
  final String? content;
  final int score;
  final DateTime createdAt;

  SheetReviewModel({
    required this.id,
    required this.sheetId,
    required this.userId,
    this.content,
    required this.score,
    required this.createdAt,
  });

  factory SheetReviewModel.fromJson(Map<String, dynamic> json) {
    return SheetReviewModel(
      id: json['id'],
      sheetId: json['sheet_id'],
      userId: json['user_id'],
      content: json['content'],
      score: json['score'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
