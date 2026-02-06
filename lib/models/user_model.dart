import 'enums.dart';

class UserModel {
  final String id;
  final String? username;
  final String? email;
  final String? profileImage;
  final AuthProvider authProvider;
  final String roleId;
  final String? roleName;
  final int point;
  final bool visibleFlag;
  final StatusFlag statusFlag;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? statusModifiedAt;

  UserModel({
    required this.id,
    this.username,
    this.email,
    this.profileImage,
    required this.authProvider,
    required this.roleId,
    this.roleName,
    required this.point,
    required this.visibleFlag,
    required this.statusFlag,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.statusModifiedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle nested flag object if present
    final flagData = json['flag'] is Map<String, dynamic> ? json['flag'] : null;

    // Extremely Robust Role Parsing
    Map<String, dynamic>? rolesMap;
    String? nameFromData;
    String? idFromData;

    if (json['roles'] is Map<String, dynamic>) {
      rolesMap = json['roles'] as Map<String, dynamic>;
    } else if (json['role'] is Map<String, dynamic>) {
      rolesMap = json['role'] as Map<String, dynamic>;
    } else if (json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      if ((json['roles'] as List)[0] is Map<String, dynamic>) {
        rolesMap = (json['roles'] as List)[0] as Map<String, dynamic>;
      } else if ((json['roles'] as List)[0] is String) {
        nameFromData = (json['roles'] as List)[0] as String;
      }
    } else if (json['roles'] is String) {
      nameFromData = json['roles'] as String;
    } else if (json['role'] is String) {
      nameFromData = json['role'] as String;
    }

    // Ultimate Fallback: Search ALL keys for any value containing 'PREMIUM'
    String? ultimateName;
    json.forEach((key, value) {
      if (key.toLowerCase().contains('role')) {
        if (value is String && value.toUpperCase().contains('PREMIUM')) {
          ultimateName = value;
        } else if (value is Map && value['name'] != null) {
          if (value['name'].toString().toUpperCase().contains('PREMIUM')) {
            ultimateName = value['name'].toString();
          }
        }
      }
    });

    final roleName =
        json['role_name'] ??
        json['roleName'] ??
        nameFromData ??
        rolesMap?['name'] ??
        ultimateName;
    final roleId = json['role_id'] ?? idFromData ?? rolesMap?['id'] ?? '';

    return UserModel(
      id: json['id'] ?? json['uid'] ?? '',
      username: json['username'],
      email: json['email'],
      profileImage: json['profile_image'],
      authProvider: AuthProvider.fromString(
        json['auth_provider'] ?? 'EMAIL_PASSWORD',
      ),
      roleId: roleId,
      roleName: roleName,
      point: json['point'] != null ? int.parse(json['point'].toString()) : 0,
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
            json['operation']?['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
      createdBy:
          json['created_by'] ?? json['operation']?['created_by'] ?? 'SYSTEM',
      updatedAt:
          (json['updated_at'] ?? json['operation']?['updated_at']) != null
          ? DateTime.parse(
              json['updated_at'] ?? json['operation']?['updated_at'],
            )
          : null,
      updatedBy: json['updated_by'] ?? json['operation']?['updated_by'],
      statusModifiedAt:
          (json['status_modified_at'] ?? flagData?['status_modified_at']) !=
              null
          ? DateTime.parse(
              json['status_modified_at'] ?? flagData?['status_modified_at'],
            )
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? profileImage,
    AuthProvider? authProvider,
    String? roleId,
    String? roleName,
    int? point,
    bool? visibleFlag,
    StatusFlag? statusFlag,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
    DateTime? statusModifiedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      authProvider: authProvider ?? this.authProvider,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      point: point ?? this.point,
      visibleFlag: visibleFlag ?? this.visibleFlag,
      statusFlag: statusFlag ?? this.statusFlag,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      statusModifiedAt: statusModifiedAt ?? this.statusModifiedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile_image': profileImage,
      'auth_provider': authProvider.name,
      'role_id': roleId,
      'role_name': roleName,
      'point': point,
      'visible_flag': visibleFlag,
      'status_flag': statusFlag.name,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
      'updated_by': updatedBy,
      'status_modified_at': statusModifiedAt?.toIso8601String(),
    };
  }
}

class UserProviderModel {
  final String id;
  final String userId;
  final String providerUserId;
  final String providerName; // e.g., 'GOOGLE'
  final String providerUsername;
  final String providerEmail;

  UserProviderModel({
    required this.id,
    required this.userId,
    required this.providerUserId,
    required this.providerName,
    required this.providerUsername,
    required this.providerEmail,
  });

  factory UserProviderModel.fromJson(Map<String, dynamic> json) {
    return UserProviderModel(
      id: json['id'],
      userId: json['user_id'],
      providerUserId: json['provider_user_id'],
      providerName: json['provider_name'],
      providerUsername: json['provider_username'],
      providerEmail: json['provider_email'],
    );
  }
}
