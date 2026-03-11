import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/user/community/comment_sheet.dart';
import 'package:flutter_application_1/pages/user/community/community_post_card.dart';
import 'package:flutter_application_1/pages/user/create_post.dart';
import 'package:flutter_application_1/pages/user/profile.dart';
import 'package:flutter_application_1/pages/user/sheet/preview_sheet.dart';
import 'package:flutter_application_1/pages/user/user_profile_view.dart';
import 'package:flutter_application_1/widgets/custom_dialog.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/services/posts_service.dart';
import 'package:flutter_application_1/services/users_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:share_plus/share_plus.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;
  final Set<String> _followBusyUserIds = {};

  @override
  void initState() {
    super.initState();
    final storage = GetStorage();
    _currentUserId = storage.read('uid')?.toString();
    _refreshPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final posts = await PostsService.getPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await _refreshPosts();
          },
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
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildCreatePostInput(),
                  const SizedBox(height: 32),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Center(child: Text('Error: $_error'))
                  else if (_posts.isEmpty)
                    const Center(child: Text('ไม่พบโพสต์'))
                  else
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        return _buildPostCard(_posts[index]);
                      },
                    ),
                  const SizedBox(height: 140), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'คอมมูนิตี้',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'สามารถโพสถามหรือแสดงความคิดเห็นกับผู้ใช้คนอื่นได้',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.grey[200], thickness: 1),
      ],
    );
  }

  Widget _buildCreatePostInput() {
    return GestureDetector(
      onTap: () async {
        final result = await Get.to(() => const CreatePostPage());
        if (result == true) {
          _refreshPosts();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'สร้างโพสของคุณที่นี่',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF2A5DB9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    final formattedDate = post.createdAt.toString().substring(0, 16);
    final avatarProvider = _resolveAvatar(post.author.profileImage);
    final isSelf =
        _currentUserId != null && _currentUserId == post.author.id;
    final canFollow = post.author.id.isNotEmpty && !isSelf;

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
        final success = post.isLiked
            ? await PostsService.unlikePost(post.id)
            : await PostsService.likePost(post.id);

        if (success && mounted) {
          setState(() {
            _posts = _posts.map((p) {
              if (p.id == post.id) {
                final increment = p.isLiked ? -1 : 1;
                return p.copyWith(
                  isLiked: !p.isLiked,
                  likeCount: p.likeCount + increment,
                );
              }
              return p;
            }).toList();
          });
        }
      },
      onCommentTap: () => _openComments(post),
      onShareTap: () => _sharePost(post),
      showFollowButton: canFollow,
      isFollowing: _isFollowing(post.author),
      isFollowBusy: _followBusyUserIds.contains(post.author.id),
      onFollowTap: canFollow ? () => _toggleFollow(post) : null,
    );
  }

  void _openUserProfile(UserModel author) {
    final currentUserId = _currentUserId;
    if (currentUserId != null && currentUserId == author.id) {
      Get.to(() => const ProfilePage());
      return;
    }
    Get.to(() => UserProfileViewPage(userId: author.id, initialUser: author));
  }

  bool _isFollowing(UserModel user) {
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) return false;
    final followers = user.followersUid.map((e) => e.toString());
    return user.isFollowing || followers.contains(currentUserId);
  }

  Future<void> _toggleFollow(PostModel post) async {
    final author = post.author;
    final currentUserId = _currentUserId;
    if (author.id.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty ||
        author.id == currentUserId) {
      return;
    }

    if (_followBusyUserIds.contains(author.id)) return;

    final token = GetStorage().read('token')?.toString();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบเพื่อทำการติดตาม')),
      );
      return;
    }

    final currentlyFollowing = _isFollowing(author);
    if (currentlyFollowing) {
      _showUnfollowConfirmDialog(post);
      return;
    }

    await _performFollowAction(post: post, currentlyFollowing: false);
  }

  void _showUnfollowConfirmDialog(PostModel post) {
    final author = post.author;
    showCustomDialog(
      title: 'เลิกติดตาม',
      message:
          'คุณแน่ใจหรือไม่ว่าต้องการเลิกติดตาม ${author.username ?? 'ผู้ใช้นี้'}?',
      isConfirm: true,
      onOk: () async {
        await _performFollowAction(post: post, currentlyFollowing: true);
      },
    );
  }

  Future<void> _performFollowAction({
    required PostModel post,
    required bool currentlyFollowing,
  }) async {
    final author = post.author;
    final currentUserId = _currentUserId;
    if (author.id.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty ||
        author.id == currentUserId) {
      return;
    }

    if (_followBusyUserIds.contains(author.id)) return;

    setState(() => _followBusyUserIds.add(author.id));

    try {
      final success = currentlyFollowing
          ? await UsersService.unfollowUser(author.id)
          : await UsersService.followUser(author.id);

      if (!mounted) return;

      if (success) {
        final updatedFollowers = List<String>.from(author.followersUid);
        if (currentlyFollowing) {
          updatedFollowers.remove(currentUserId);
        } else {
          if (!updatedFollowers.contains(currentUserId)) {
            updatedFollowers.add(currentUserId);
          }
        }
        final delta = currentlyFollowing ? -1 : 1;
        final updatedCount = author.followersCount + delta;

        setState(() {
          _posts = _posts.map((p) {
            if (p.author.id != author.id) return p;
            return p.copyWith(
              author: p.author.copyWith(
                followersUid: List<String>.from(updatedFollowers),
                followersCount: updatedCount < 0 ? 0 : updatedCount,
                isFollowing: !currentlyFollowing,
              ),
            );
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ดำเนินการไม่สำเร็จ ลองใหม่อีกครั้ง')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _followBusyUserIds.remove(author.id));
      }
    }
  }

  Future<void> _openComments(PostModel post) async {
    final token = GetStorage().read('token')?.toString();
    if (token == null || token.isEmpty) {
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
          onCommentCountChanged: (count) {
            if (!mounted) return;
            setState(() {
              _posts = _posts.map((p) {
                if (p.id == post.id) {
                  return p.copyWith(commentCount: count);
                }
                return p;
              }).toList();
            });
          },
        );
      },
    );
  }

  Future<void> _sharePost(PostModel post) async {
    final token = GetStorage().read('token')?.toString();
    if (token == null || token.isEmpty) {
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
    } catch (e) {
      debugPrint('Error opening share sheet: $e');
    }

    final result = await PostsService.sharePost(post.id);
    if (!mounted) return;

    if (result.success && !result.alreadyShared) {
      setState(() {
        _posts = _posts.map((p) {
          if (p.id == post.id) {
            final newCount = result.shareCount ?? (p.shareCount + 1);
            return p.copyWith(shareCount: newCount);
          }
          return p;
        }).toList();
      });
    } else if (result.alreadyShared) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('คุณแชร์โพสต์นี้ไปแล้ว')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('แชร์ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง')),
      );
    }
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
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'ส่งรายงานของคุณเรียบร้อยแล้ว ขอบคุณที่ช่วยแจ้งให้เราทราบ',
              ),
            ),
          );
        }
      },
    );
  }

  ImageProvider? _resolveAvatar(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) return null;
    final isFullUrl = profileImage.startsWith('http');
    final url = isFullUrl ? profileImage : '$apiEndpoint/$profileImage';
    return NetworkImage(url);
  }
}
