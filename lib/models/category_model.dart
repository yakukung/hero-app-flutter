import 'enums.dart';

class CategoryModel {
  final String id;
  final String name;
  final bool visibleFlag;
  final StatusFlag statusFlag;

  CategoryModel({
    required this.id,
    required this.name,
    required this.visibleFlag,
    required this.statusFlag,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Handle nested flag object if present
    final flagData = json['flag'] is Map<String, dynamic> ? json['flag'] : null;

    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      visibleFlag:
          json['visible_flag'] == true ||
          json['visible_flag'] == 1 ||
          flagData?['visible_flag'] == true ||
          flagData?['visible_flag'] == 1,
      statusFlag: StatusFlag.fromString(
        json['status_flag'] ?? flagData?['status_flag'] ?? 'ACTIVE',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'visible_flag': visibleFlag,
      'status_flag': statusFlag.name,
    };
  }
}

class KeywordModel {
  final String id;
  final String name;
  final int usageCount;
  final bool visibleFlag;
  final StatusFlag statusFlag;

  KeywordModel({
    required this.id,
    required this.name,
    required this.usageCount,
    required this.visibleFlag,
    required this.statusFlag,
  });

  factory KeywordModel.fromJson(Map<String, dynamic> json) {
    // Handle nested flag object if present
    final flagData = json['flag'] is Map<String, dynamic> ? json['flag'] : null;

    return KeywordModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      usageCount: json['usage_count'] != null
          ? int.parse(json['usage_count'].toString())
          : 0,
      visibleFlag:
          json['visible_flag'] == true ||
          json['visible_flag'] == 1 ||
          flagData?['visible_flag'] == true ||
          flagData?['visible_flag'] == 1,
      statusFlag: StatusFlag.fromString(
        json['status_flag'] ?? flagData?['status_flag'] ?? 'ACTIVE',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'usage_count': usageCount,
      'visible_flag': visibleFlag,
      'status_flag': statusFlag.name,
    };
  }
}
