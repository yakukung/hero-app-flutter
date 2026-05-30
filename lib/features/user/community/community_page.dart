import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/post_model.dart';
import 'package:hero_app_flutter/core/models/user_model.dart';
import 'package:hero_app_flutter/core/services/posts_service.dart';
import 'package:hero_app_flutter/features/user/community/controllers/community_page_controller.dart';
import 'package:hero_app_flutter/features/user/community/create_post_page.dart';
import 'package:hero_app_flutter/features/user/community/widgets/comment_sheet.dart';
import 'package:hero_app_flutter/features/user/community/widgets/community_page_header.dart';
import 'package:hero_app_flutter/features/user/community/widgets/community_post_card.dart';
import 'package:hero_app_flutter/features/user/community/widgets/create_post_prompt.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/features/user/profile/user_profile_view_page.dart';
import 'package:hero_app_flutter/features/user/sheet/preview_sheet_page.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';

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
    final formattedDate = post.createdAt.toLocal().toString().substring(0, 16);

    return CommunityPostCard(
      post: post,
      formattedDate: formattedDate,
      onUserTap: () => _openUserProfile(post.author),
      onReportTap: () {
        if (post.userId == _controller.currentUserId) {
          _showOwnPostOptions(post);
        } else {
          _showReportOptions(post);
        }
      },
      onSheetTap: post.sheetId == null
          ? null
          : () => Get.to(() => PreviewSheetPage(sheetId: post.sheetId!)),
      onLikeTap: () async {
        await _controller.toggleLike(post);
      },
      onCommentTap: () => _openComments(post),
      onShareTap: post.userId == _controller.currentUserId
          ? null
          : () => _toggleSharePost(post),
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

  void _showOwnPostOptions(PostModel post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
              const SizedBox(height: 16),
              _OptionTile(
                icon: Icons.edit_outlined,
                label: 'แก้ไขโพสต์',
                onTap: () {
                  Get.back();
                  Get.to(() => CreatePostPage(
                    postId: post.id,
                    initialContent: post.content,
                    initialSheetId: post.sheetId,
                  ));
                },
              ),
              _OptionTile(
                icon: Icons.delete_outline,
                label: 'ลบโพสต์',
                color: const Color(0xFFC62828),
                onTap: () {
                  Get.back();
                  showCustomDialog(
                    title: 'ลบโพสต์',
                    message: 'คุณแน่ใจหรือไม่ว่าต้องการลบโพสต์นี้?',
                    isConfirm: true,
                    isDanger: true,
                    okButtonLabel: 'ลบ',
                    onOk: () async {
                      final success = await PostsService.deletePost(post.id);
                      if (!mounted) return;
                      if (success) {
                        await _controller.refreshPosts();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ลบโพสต์แล้ว')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ไม่สามารถลบโพสต์ได้')),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
        final success = await _controller.reportPost(
          postId: post.id,
          reportType: selectedType,
          content: detailController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'ส่งรายงานแล้ว' : 'ระบบรายงานยังไม่พร้อมใช้งาน',
            ),
          ),
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Colors.black87;
    return ListTile(
      leading: Icon(icon, color: themeColor),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: themeColor,
        ),
      ),
      onTap: onTap,
    );
  }
}
