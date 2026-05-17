import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/core/config/api_connect.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/post_model.dart';
import 'package:hero_app_flutter/core/models/user_model.dart';
import 'package:hero_app_flutter/features/user/community/controllers/community_page_controller.dart';
import 'package:hero_app_flutter/features/user/community/create_post_page.dart';
import 'package:hero_app_flutter/features/user/community/widgets/comment_sheet.dart';
import 'package:hero_app_flutter/features/user/community/widgets/community_page_header.dart';
import 'package:hero_app_flutter/features/user/community/widgets/community_post_card.dart';
import 'package:hero_app_flutter/features/user/community/widgets/create_post_prompt.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/features/user/profile/user_profile_view_page.dart';
import 'package:hero_app_flutter/features/user/sheet/preview_sheet_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key, this.controller});

  final CommunityPageController? controller;

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late final CommunityPageController _controller;

  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CommunityPageController();
    unawaited(_controller.loadPosts());
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return RefreshIndicator(
              onRefresh: _controller.refreshPosts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommunityPageHeader(),
                      const SizedBox(height: 24),
                      CreatePostPrompt(onTap: _openCreatePostPage),
                      const SizedBox(height: 32),
                      _buildBody(),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null) {
      return Center(child: Text('Error: ${_controller.errorMessage}'));
    }

    if (_controller.posts.isEmpty) {
      return const Center(child: Text('ไม่พบโพสต์'));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _controller.posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_controller.posts[index]);
      },
    );
  }

  Future<void> _openCreatePostPage() async {
    final result = await Get.to(() => const CreatePostPage());
    if (result == true) {
      await _controller.refreshPosts();
    }
  }

  Widget _buildPostCard(PostModel post) {
    final formattedDate = post.createdAt.toString().substring(0, 16);
    final avatarProvider = _resolveAvatar(post.author.profileImage);

    return CommunityPostCard(
      post: post,
      formattedDate: formattedDate,
      avatarProvider: avatarProvider,
      onUserTap: () => _openUserProfile(post.author),
      onReportTap: () => _showReportOptions(post),
      onSheetTap: post.sheetId == null
          ? null
          : () => Get.to(() => PreviewSheetPage(sheetId: post.sheetId!)),
      onLikeTap: () async {
        await _controller.toggleLike(post);
      },
      onCommentTap: () => _openComments(post),
      onShareTap: () => _toggleSharePost(post),
    );
  }

  void _openUserProfile(UserModel author) {
    final currentUserId = _controller.currentUserId;
    if (currentUserId.isNotEmpty && currentUserId == author.id) {
      final navigationController = Get.find<NavigationController>();
      navigationController.changeIndex(4);
      return;
    }

    Get.to(() => UserProfileViewPage(userId: author.id, initialUser: author));
  }

  Future<void> _openComments(PostModel post) async {
    if (!_controller.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบเพื่อแสดงความคิดเห็น')),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return CommentSheet(
          post: post,
          currentUserId: _controller.currentUserId,
          onCommentCountChanged: (count) {
            _controller.updateCommentCount(
              postId: post.id,
              commentCount: count,
            );
          },
        );
      },
    );
  }

  Future<void> _toggleSharePost(PostModel post) async {
    if (!_controller.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนแชร์โพสต์')),
      );
      return;
    }

    final result = await _controller.toggleShare(post);
    if (!mounted) {
      return;
    }

    if (result.success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('แชร์ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง')),
    );
  }

  void _showReportOptions(PostModel post) {
    if (!_controller.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนรายงานโพสต์')),
      );
      return;
    }

    final detailController = TextEditingController();
    var selectedType = ReportType.SPAM;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'รายงานโพสต์',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ReportType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'เหตุผล',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ReportType.SPAM,
                          child: Text('สแปม'),
                        ),
                        DropdownMenuItem(
                          value: ReportType.ABUSE,
                          child: Text('เนื้อหาไม่เหมาะสม'),
                        ),
                        DropdownMenuItem(
                          value: ReportType.BUG,
                          child: Text('ข้อมูลผิดพลาด'),
                        ),
                        DropdownMenuItem(
                          value: ReportType.OTHER,
                          child: Text('อื่นๆ'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() => selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'รายละเอียดเพิ่มเติม',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(this.context);
                          final success = await _controller.reportPost(
                            postId: post.id,
                            reportType: selectedType,
                            content: detailController.text.trim(),
                          );
                          if (!mounted) return;
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'ส่งรายงานแล้ว'
                                    : 'ระบบรายงานยังไม่พร้อมใช้งาน',
                              ),
                            ),
                          );
                        },
                        child: const Text('ส่งรายงาน'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  ImageProvider? _resolveAvatar(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) {
      return null;
    }

    final url = profileImage.startsWith('http')
        ? profileImage
        : '$apiEndpoint/$profileImage';
    return NetworkImage(url);
  }
}
