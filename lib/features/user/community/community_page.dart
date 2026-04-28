import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:hero_app_flutter/core/config/api_connect.dart';
import 'package:hero_app_flutter/core/models/post_model.dart';
import 'package:hero_app_flutter/core/models/user_model.dart';
import 'package:hero_app_flutter/features/user/community/controllers/community_page_controller.dart';
import 'package:hero_app_flutter/features/user/community/create_post_page.dart';
import 'package:hero_app_flutter/features/user/community/widgets/comment_sheet.dart';
import 'package:hero_app_flutter/features/user/community/widgets/community_page_header.dart';
import 'package:hero_app_flutter/features/user/community/widgets/community_post_card.dart';
import 'package:hero_app_flutter/features/user/community/widgets/create_post_prompt.dart';
import 'package:hero_app_flutter/features/user/profile/profile_page.dart';
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
      onShareTap: () => _sharePost(post),
    );
  }

  void _openUserProfile(UserModel author) {
    final currentUserId = _controller.currentUserId;
    if (currentUserId.isNotEmpty && currentUserId == author.id) {
      Get.to(() => const ProfilePage());
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

  Future<void> _sharePost(PostModel post) async {
    if (!_controller.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนแชร์โพสต์')),
      );
      return;
    }

    final shareText = post.content.isNotEmpty
        ? post.content
        : 'แชร์โพสต์จากผู้ใช้ ${post.author.username ?? ''}';

    try {
      await Share.share(
        shareText,
        subject: 'แชร์โพสต์จากคอมมูนิตี้',
        sharePositionOrigin: _shareOrigin(context),
      );
    } catch (error) {
      debugPrint('Error opening share sheet: $error');
    }

    final result = await _controller.registerShare(post);
    if (!mounted) {
      return;
    }

    if (result.success && !result.alreadyShared) {
      return;
    }

    if (result.alreadyShared) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('คุณแชร์โพสต์นี้ไปแล้ว')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('แชร์ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง')),
    );
  }

  Rect _shareOrigin(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      final origin = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;
      if (size.width > 0 && size.height > 0) {
        return origin & size;
      }
    }

    final overlay = Overlay.of(context).context.findRenderObject();
    if (overlay is RenderBox) {
      final origin = overlay.localToGlobal(Offset.zero);
      final size = overlay.size;
      if (size.width > 0 && size.height > 0) {
        return origin & size;
      }
    }

    return const Rect.fromLTWH(0, 0, 1, 1);
  }

  void _showReportOptions(PostModel post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'เลือกเหตุผลที่คุณต้องการรายงานโพสต์นี้',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 20),
              _buildReportTile('สแปม (SPAM)', post),
              _buildReportTile('การละเมิด (ABUSE)', post),
              _buildReportTile('พบข้อผิดพลาด (BUG)', post),
              _buildReportTile('อื่นๆ (OTHER)', post),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportTile(String reason, PostModel post) {
    return ListTile(
      title: Text(reason),
      onTap: () async {
        Get.back();
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ส่งรายงานของคุณเรียบร้อยแล้ว ขอบคุณที่ช่วยแจ้งให้เราทราบ',
            ),
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
