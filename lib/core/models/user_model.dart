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
  final double wallet;
  final bool visibleFlag;
  final StatusFlag statusFlag;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? statusModifiedAt;
  final int followersCount;
  final List<String> followersUid;
  final int followingsCount;
  final List<String> followingsUid;
  final bool isFollowing;

  UserModel({
    required this.id,
    this.username,
    this.email,
    this.profileImage,
    required this.authProvider,
    required this.roleId,
    this.roleName,
    required this.point,
    this.wallet = 0.0,
    required this.visibleFlag,
    required this.statusFlag,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.statusModifiedAt,
    this.followersCount = 0,
    this.followersUid = const [],
    this.followingsCount = 0,
    this.followingsUid = const [],
    this.isFollowing = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle nested flag object if present
    final flagData = json['flag'] is Map<String, dynamic> ? json['flag'] : null;

    // Extremely Robust Role Parsing
    Map<String, dynamic>? rolesMap;
    String? nameFromData;
    String? idFromData;

    final rolesJson = json['roles'];
    final roleJson = json['role'];

    if (rolesJson is Map) {
      rolesMap = rolesJson.cast<String, dynamic>();
    } else if (roleJson is Map) {
      rolesMap = roleJson.cast<String, dynamic>();
    } else if (rolesJson is List && rolesJson.isNotEmpty) {
      if (rolesJson[0] is Map) {
        rolesMap = (rolesJson[0] as Map).cast<String, dynamic>();
      } else if (rolesJson[0] is String) {
        nameFromData = rolesJson[0] as String;
      }
    } else if (rolesJson is String) {
      nameFromData = rolesJson;
    } else if (roleJson is String) {
      nameFromData = roleJson;
    }

    // Ultimate Fallback: Search ALL keys for any value containing 'PREMIUM' or 'ADMIN'
    String? ultimateName;
    json.forEach((key, value) {
      if (key.toLowerCase().contains('role')) {
        final valStr = value.toString().toUpperCase();
        if (valStr.contains('PREMIUM') || valStr.contains('ADMIN')) {
          if (value is String) {
            ultimateName = value;
          } else if (value is Map && value['name'] != null) {
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
      wallet: json['wallet'] != null
          ? double.tryParse(json['wallet'].toString()) ?? 0.0
          : (json['total_wallet'] != null
                ? double.tryParse(json['total_wallet'].toString()) ?? 0.0
                : 0.0),
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
      followersCount: json['followers'] != null
          ? (json['followers'] is Map && json['followers']['count'] != null
                ? int.tryParse(json['followers']['count'].toString()) ?? 0
                : 0)
          : 0,
      followersUid:
          json['followers'] != null && json['followers']['uid'] != null
          ? List<String>.from(json['followers']['uid'])
          : [],
      followingsCount: json['followings'] != null
          ? (json['followings'] is Map && json['followings']['count'] != null
                ? int.tryParse(json['followings']['count'].toString()) ?? 0
                : 0)
          : 0,
      followingsUid:
          json['followings'] != null && json['followings']['uid'] != null
          ? List<String>.from(json['followings']['uid'])
          : [],
      isFollowing:
          json['is_following'] == true ||
          json['is_followed'] == true ||
          json['is_followed_by_me'] == true,
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
    double? wallet,
    bool? visibleFlag,
    StatusFlag? statusFlag,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
    DateTime? statusModifiedAt,
    int? followersCount,
    List<String>? followersUid,
    int? followingsCount,
    List<String>? followingsUid,
    bool? isFollowing,
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
      wallet: wallet ?? this.wallet,
      visibleFlag: visibleFlag ?? this.visibleFlag,
      statusFlag: statusFlag ?? this.statusFlag,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      statusModifiedAt: statusModifiedAt ?? this.statusModifiedAt,
      followersCount: followersCount ?? this.followersCount,
      followersUid: followersUid ?? this.followersUid,
      followingsCount: followingsCount ?? this.followingsCount,
      followingsUid: followingsUid ?? this.followingsUid,
      isFollowing: isFollowing ?? this.isFollowing,
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
      'wallet': wallet,
      'visible_flag': visibleFlag,
      'status_flag': statusFlag.name,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
      'updated_by': updatedBy,
      'status_modified_at': statusModifiedAt?.toIso8601String(),
      'followers': {'count': followersCount, 'uid': followersUid},
      'followings': {'count': followingsCount, 'uid': followingsUid},
      'is_following': isFollowing,
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
