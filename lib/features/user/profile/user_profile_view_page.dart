import 'package:flutter/material.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/post_model.dart';
import 'package:hero_app_flutter/core/models/user_model.dart';
import 'package:hero_app_flutter/core/services/posts_service.dart';
import 'package:hero_app_flutter/core/services/reports_service.dart';
import 'package:hero_app_flutter/core/services/users_service.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/features/user/community/widgets/community_post_card.dart';
import 'package:hero_app_flutter/features/user/sheet/preview_sheet_page.dart';
import 'package:hero_app_flutter/shared/widgets/profile_avatar.dart';

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

class _UserProfileViewPageState extends State<UserProfileViewPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  UserModel? _user;
  bool _isLoading = true;
  bool _isFollowBusy = false;
  String? _error;
  String? _currentUserId;
  DateTime? _lastFollowActionAt;
  static const Duration _followCooldown = Duration(milliseconds: 800);

  List<PostModel> _posts = [];
  bool _isLoadingPosts = true;
  List<PostModel> _sharedPosts = [];
  bool _isLoadingSharedPosts = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _currentUserId = GetStorage().read('uid')?.toString();
    _user = widget.initialUser;
    _fetchUser();
    _fetchPosts();
    _fetchSharedPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _fetchPosts() async {
    setState(() => _isLoadingPosts = true);
    try {
      final posts = await PostsService.getPostsByUserId(widget.userId);
      if (!mounted) return;
      setState(() => _posts = posts);
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _fetchSharedPosts() async {
    setState(() => _isLoadingSharedPosts = true);
    try {
      final posts = await PostsService.getSharedPostsByUserId(widget.userId);
      if (!mounted) return;
      setState(() => _sharedPosts = posts);
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _isLoadingSharedPosts = false);
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

  Future<void> _performFollowAction({required bool currentlyFollowing}) async {
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
        final updatedFollowers = user.followersUid
            .map((e) => e.toString())
            .toList();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: Colors.black54),
            onPressed: _reportUser,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchUser();
          await _fetchPosts();
          await _fetchSharedPosts();
        },
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
            if (user != null) ...[
              const SizedBox(height: 24),
              _buildTabBar(),
              const SizedBox(height: 12),
              _buildPostsTabContent(),
            ],
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
          child: const Text('ลองใหม่', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _reportUser() {
    final detailController = TextEditingController();
    final reportTypes = ReportType.forTable('users');
    var selectedType = reportTypes.first;

    showCustomDialog(
      title: 'รายงานผู้ใช้',
      message: 'ระบุเหตุผลที่ต้องการรายงาน',
      isConfirm: true,
      okButtonLabel: 'ส่งรายงาน',
      isDanger: true,
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonFormField<ReportType>(
                isExpanded: true,
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'เหตุผล',
                  border: InputBorder.none,
                ),
                items: reportTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedType = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: detailController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'รายละเอียดเพิ่มเติม',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      onOk: () async {
        final result = await ReportsService.submitReport(
          referenceId: widget.userId,
          referenceTable: 'users',
          reportType: selectedType,
          content: detailController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success ? 'ส่งรายงานแล้ว' : result.message,
            ),
          ),
        );
      },
    );
  }

  void _reportPost(PostModel post) {
    final detailController = TextEditingController();
    final reportTypes = ReportType.forTable('posts');
    var selectedType = reportTypes.first;

    showCustomDialog(
      title: 'รายงานโพสต์',
      message: 'ระบุเหตุผลที่ต้องการรายงาน',
      isConfirm: true,
      okButtonLabel: 'ส่งรายงาน',
      isDanger: true,
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonFormField<ReportType>(
                isExpanded: true,
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'เหตุผล',
                  border: InputBorder.none,
                ),
                items: reportTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedType = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: detailController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'รายละเอียดเพิ่มเติม',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      onOk: () async {
        final result = await ReportsService.submitReport(
          referenceId: post.id,
          referenceTable: 'posts',
          reportType: selectedType,
          content: detailController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success ? 'ส่งรายงานแล้ว' : result.message,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(999),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: const Color(0xFF1A1A1A),
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        dividerColor: Colors.transparent,
        splashBorderRadius: BorderRadius.circular(999),
        tabs: const [
          Tab(text: 'โพสต์'),
          Tab(text: 'โพสต์ที่แชร์'),
        ],
      ),
    );
  }

  List<PostModel> get _currentPosts =>
      _tabController.index == 0 ? _posts : _sharedPosts;

  bool get _isLoadingCurrentPosts =>
      _tabController.index == 0 ? _isLoadingPosts : _isLoadingSharedPosts;

  String _emptyMessageForTab() =>
      _tabController.index == 0 ? 'ยังไม่มีโพสต์' : 'ยังไม่มีโพสต์ที่แชร์';

  Widget _buildPostsTabContent() {
    final posts = _currentPosts;
    final isLoading = _isLoadingCurrentPosts;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            _emptyMessageForTab(),
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      );
    }

    return Column(
      children: posts
          .take(5)
          .map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CommunityPostCard(
                post: post,
                formattedDate: _formatPostDate(post.createdAt),
                onUserTap: () {},
                onReportTap: () => _reportPost(post),
                onSheetTap: post.sheetId == null
                    ? null
                    : () => Get.to(
                        () => PreviewSheetPage(sheetId: post.sheetId!),
                      ),
                onLikeTap: () {},
                onCommentTap: () {},
                onShareTap: () {},
              ),
            ),
          )
          .toList(),
    );
  }

  String _formatPostDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year}  $hour:$minute';
  }

  Widget _buildProfile(UserModel user) {
    final isSelf = _currentUserId == user.id;

    return Column(
      children: [
        const SizedBox(height: 20),
        ProfileAvatar(
          uid: user.id,
          username: user.username,
          imageUrl: user.profileImage,
          size: 120,
        ),
        const SizedBox(height: 16),
        Text(
          user.username?.isNotEmpty == true ? user.username! : 'ผู้ใช้',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                backgroundColor: _isFollowing(user)
                    ? Colors.grey[200]
                    : AppColors.primary,
                foregroundColor: _isFollowing(user)
                    ? Colors.black87
                    : Colors.white,
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
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
