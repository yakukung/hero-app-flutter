import 'enums.dart';

class RoleModel {
  final String id;
  final String? name;
  final bool visibleFlag;
  final StatusFlag statusFlag;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  RoleModel({
    required this.id,
    this.name,
    required this.visibleFlag,
    required this.statusFlag,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
      visibleFlag: json['visible_flag'] == 1 || json['visible_flag'] == true,
      statusFlag: StatusFlag.fromString(json['status_flag']),
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      updatedBy: json['updated_by'],
    );
  }
}

class PermissionModel {
  final String id;
  final String? name;
  final bool visibleFlag;
  final StatusFlag statusFlag;

  PermissionModel({
    required this.id,
    this.name,
    required this.visibleFlag,
    required this.statusFlag,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'],
      name: json['name'],
      visibleFlag: json['visible_flag'] == 1 || json['visible_flag'] == true,
      statusFlag: StatusFlag.fromString(json['status_flag']),
    );
  }
}

class ScopeModel {
  final String id;
  final String roleId;
  final String permissionId;

  ScopeModel({
    required this.id,
    required this.roleId,
    required this.permissionId,
  });

  factory ScopeModel.fromJson(Map<String, dynamic> json) {
    return ScopeModel(
      id: json['id'],
      roleId: json['role_id'],
      permissionId: json['permission_id'],
    );
  }
}
