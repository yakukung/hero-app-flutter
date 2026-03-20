import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:flutter_application_1/core/services/users_service.dart';
import 'package:flutter_application_1/shared/widgets/custom_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/constants/app_assets.dart';

class UserProfileViewPage extends StatefulWidget {
  final String userId;
  final UserModel? initialUser;

  const UserProfileViewPage({
    super.key,
    required this.userId,
    this.initialUser,
  });

  @override
  State<UserProfileViewPage> createState() => _UserProfileViewPageState();
}

class _UserProfileViewPageState extends State<UserProfileViewPage> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isFollowBusy = false;
  String? _error;
  String? _currentUserId;
  DateTime? _lastFollowActionAt;
  static const Duration _followCooldown = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _currentUserId = GetStorage().read('uid')?.toString();
    _user = widget.initialUser;
    _fetchUser();
  }

  Future<void> _fetchUser({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final user = await UsersService.fetchUserById(widget.userId);
      if (!mounted) return;
      setState(() {
        _user = user ?? _user;
        _error = user == null ? 'ไม่พบข้อมูลผู้ใช้' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'ไม่สามารถดึงข้อมูลผู้ใช้ได้';
      });
    } finally {
      if (mounted && showLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isFollowing(UserModel user) {
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) return false;
    final followers = user.followersUid.map((e) => e.toString());
    return user.isFollowing || followers.contains(currentUserId);
  }

  int _followersCount(UserModel user) {
    final listCount = user.followersUid.length;
    return user.followersCount < listCount ? listCount : user.followersCount;
  }

  int _followingsCount(UserModel user) {
    final listCount = user.followingsUid.length;
    return user.followingsCount < listCount ? listCount : user.followingsCount;
  }

  String? _resolveProfileImageUrl(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) return null;
    return profileImage.startsWith('http')
        ? profileImage
        : '$apiEndpoint/$profileImage';
  }

  Future<void> _toggleFollow() async {
    final user = _user;
    final currentUserId = _currentUserId;

    if (user == null ||
        currentUserId == null ||
        currentUserId.isEmpty ||
        user.id == currentUserId) {
      return;
    }

    if (_isFollowBusy) return;

    final currentlyFollowing = _isFollowing(user);
    if (currentlyFollowing) {
      _showUnfollowConfirmDialog(user);
      return;
    }

    await _performFollowAction(currentlyFollowing: false);
  }

  void _showUnfollowConfirmDialog(UserModel user) {
    showCustomDialog(
      title: 'เลิกติดตาม',
      message:
          'คุณแน่ใจหรือไม่ว่าต้องการเลิกติดตาม ${user.username ?? 'ผู้ใช้นี้'}?',
      isConfirm: true,
      onOk: () async {
        await _performFollowAction(currentlyFollowing: true);
      },
    );
  }

  Future<void> _performFollowAction({
    required bool currentlyFollowing,
  }) async {
    final user = _user;
    final currentUserId = _currentUserId;

    if (user == null ||
        currentUserId == null ||
        currentUserId.isEmpty ||
        user.id == currentUserId) {
      return;
    }

    if (_isFollowBusy) return;
    final now = DateTime.now();
    if (_lastFollowActionAt != null &&
        now.difference(_lastFollowActionAt!) < _followCooldown) {
      return;
    }
    _lastFollowActionAt = now;

    setState(() => _isFollowBusy = true);

    try {
      final success = currentlyFollowing
          ? await UsersService.unfollowUser(user.id)
          : await UsersService.followUser(user.id);

      if (!mounted) return;

      if (success) {
        final updatedFollowers =
            user.followersUid.map((e) => e.toString()).toList();
        if (currentlyFollowing) {
          updatedFollowers.remove(currentUserId);
        } else {
          if (!updatedFollowers.contains(currentUserId)) {
            updatedFollowers.add(currentUserId);
          }
        }
        final delta = currentlyFollowing ? -1 : 1;
        final updatedCount = _followersCount(user) + delta;

        setState(() {
          _user = user.copyWith(
            followersUid: updatedFollowers,
            followersCount: updatedCount < 0 ? 0 : updatedCount,
            isFollowing: !currentlyFollowing,
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ดำเนินการไม่สำเร็จ ลองใหม่อีกครั้ง')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFollowBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'โปรไฟล์ผู้ใช้',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchUser(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            if (_isLoading && user == null)
              const SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && user == null)
              _buildErrorState()
            else if (user != null)
              _buildProfile(user)
            else
              _buildErrorState(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 120),
        Text(
          _error ?? 'ไม่พบข้อมูลผู้ใช้',
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _fetchUser(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'ลองใหม่',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildProfile(UserModel user) {
    final profileUrl = _resolveProfileImageUrl(user.profileImage);
    final isSelf = _currentUserId == user.id;

    return Column(
      children: [
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          child: ClipOval(
            child: profileUrl != null
                ? Image.network(
                    profileUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      AppAssets.defaultAvatar,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    AppAssets.defaultAvatar,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.username?.isNotEmpty == true ? user.username! : 'ผู้ใช้',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem('ผู้ติดตาม', _followersCount(user)),
            const SizedBox(width: 20),
            _buildStatItem('กำลังติดตาม', _followingsCount(user)),
          ],
        ),
        const SizedBox(height: 20),
        if (!isSelf)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isFollowBusy ? null : _toggleFollow,
              style: FilledButton.styleFrom(
                backgroundColor:
                    _isFollowing(user) ? Colors.grey[200] : AppColors.primary,
                foregroundColor:
                    _isFollowing(user) ? Colors.black87 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                _isFollowBusy
                    ? 'กำลังดำเนินการ...'
                    : _isFollowing(user)
                        ? 'เลิกติดตาม'
                        : 'ติดตาม',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        if (isSelf)
          Text(
            'นี่คือโปรไฟล์ของคุณ',
            style: TextStyle(color: Colors.grey[600]),
          ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
