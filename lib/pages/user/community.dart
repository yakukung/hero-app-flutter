import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post_model.dart';
import 'package:flutter_application_1/pages/user/create_post.dart';
import 'package:flutter_application_1/pages/user/sheet/preview_sheet.dart';
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
  final Set<String> _followLoading = {};
  final Set<String> _followingOverride = {};
  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;
  final String _followingCacheKey = 'community_following_cache';

  @override
  void initState() {
    super.initState();
    final storage = GetStorage();
    _currentUserId = storage.read('uid')?.toString();
    final cached = storage.read<List>(_followingCacheKey);
    if (cached != null) {
      _followingOverride.addAll(cached.map((e) => e.toString()));
    }
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
        final derivedFollowing = posts
            .where((p) {
              if (p.author.isFollowing) return true;
              final uidList = p.author.followersUid.map((e) => e.toString());
              return uidList.contains(_currentUserId);
            })
            .map((p) => p.author.id);
        _followingOverride.addAll(derivedFollowing);
        _persistFollowingOverride();
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

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    post.author.profileImage != null &&
                        post.author.profileImage!.toString().startsWith('http')
                    ? NetworkImage(post.author.profileImage!)
                    : const NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/847/847969.png',
                          )
                          as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author.username ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context) {
                  final currentUserId = _currentUserId;
                  if (currentUserId == null ||
                      currentUserId == post.author.id) {
                    return const SizedBox.shrink();
                  }

                  final isFollowing =
                      _followingOverride.contains(post.author.id) ||
                      post.author.isFollowing == true ||
                      post.author.followersUid
                          .map((e) => e.toString())
                          .contains(currentUserId);
                  final isBusy = _followLoading.contains(post.author.id);

                  return GestureDetector(
                    onTap: isBusy
                        ? null
                        : () {
                            Get.defaultDialog(
                              title: isFollowing ? 'เลิกติดตาม' : 'ติดตาม',
                              middleText: isFollowing
                                  ? 'คุณแน่ใจหรือไม่ว่าต้องการเลิกติดตาม ${post.author.username}?'
                                  : 'คุณต้องการติดตาม ${post.author.username} ใช่หรือไม่?',
                              textConfirm: 'ยืนยัน',
                              textCancel: 'ยกเลิก',
                              confirmTextColor: Colors.white,
                              buttonColor: const Color(0xFF2A5DB9),
                              onConfirm: () async {
                                Get.back();
                                await _handleFollowToggle(post, context);
                              },
                              cancel: TextButton(
                                onPressed: () => Get.back(),
                                child: Text(
                                  'ยกเลิก',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            );
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isFollowing ? Colors.grey[200] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isFollowing
                            ? null
                            : Border.all(color: Colors.blueAccent),
                      ),
                      child: Text(
                        isBusy
                            ? 'กำลังดำเนินการ'
                            : isFollowing
                            ? 'เลิกติดตาม'
                            : 'ติดตาม',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isFollowing
                              ? Colors.grey[700]
                              : Colors.blueAccent,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showReportOptions(post),
                child: const Icon(Icons.more_vert, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          Text(post.content, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              if (post.sheetId != null)
                GestureDetector(
                  onTap: () {
                    Get.to(() => PreviewSheetPage(sheetId: post.sheetId!));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ดูสินค้า',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              const Spacer(),
              _buildActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${post.likeCount}',
                color: post.isLiked ? const Color(0xFF2A5DB9) : Colors.white,
                textColor: post.isLiked ? Colors.white : Colors.black54,
                isActive: post.isLiked,
                onTap: () async {
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
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post.commentCount}',
                color: Colors.white,
                isActive: false,
                onTap: () => _openComments(post),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.share,
                label: '${post.shareCount}',
                color: Colors.white,
                isActive: false,
                onTap: () => _sharePost(post),
              ),
            ],
          ),
        ],
      ),
    );
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
            final newCount =
                result.shareCount ?? (p.shareCount + 1);
            return p.copyWith(shareCount: newCount);
          }
          return p;
        }).toList();
      });
    } else if (result.alreadyShared) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('คุณแชร์โพสต์นี้ไปแล้ว')),
      );
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

  Future<void> _handleFollowToggle(PostModel post, BuildContext context) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อน')));
      return;
    }

    if (_followLoading.contains(post.author.id)) return;

    final isFollowing =
        _followingOverride.contains(post.author.id) ||
        post.author.isFollowing == true ||
        post.author.followersUid.contains(currentUserId);

    _applyFollowLocal(post.author.id, isFollowing ? -1 : 1);

    setState(() {
      _followLoading.add(post.author.id);
    });

    final success = isFollowing
        ? await UsersService.unfollowUser(post.author.id)
        : await UsersService.followUser(post.author.id);

    if (!success && mounted) {
      _applyFollowLocal(post.author.id, isFollowing ? 1 : -1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ดำเนินการไม่สำเร็จ ลองใหม่อีกครั้ง')),
      );
    }

    if (mounted) {
      setState(() {
        _followLoading.remove(post.author.id);
      });
    }
  }

  void _applyFollowLocal(String authorId, int delta) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;

    setState(() {
      _posts = _posts.map((p) {
        if (p.author.id == authorId) {
          final updatedFollowersUid = p.author.followersUid
              .map((e) => e.toString())
              .toList();
          if (delta > 0 && !updatedFollowersUid.contains(currentUserId)) {
            updatedFollowersUid.add(currentUserId);
            _followingOverride.add(authorId);
          } else if (delta < 0) {
            updatedFollowersUid.remove(currentUserId);
            _followingOverride.remove(authorId);
          }

          final updatedCount = p.author.followersCount + delta;
          final safeCount = updatedCount < 0 ? 0 : updatedCount;

          return p.copyWith(
            author: p.author.copyWith(
              followersUid: updatedFollowersUid,
              followersCount: safeCount,
              isFollowing: delta > 0
                  ? true
                  : delta < 0
                  ? false
                  : p.author.isFollowing,
            ),
          );
        }
        return p;
      }).toList();
      _persistFollowingOverride();
    });
  }

  void _persistFollowingOverride() {
    GetStorage().write(_followingCacheKey, _followingOverride.toList());
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
        Get.back(); // Close bottom sheet
        // Mocking report action
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    bool isActive = false,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : textColor ?? Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentSheet extends StatefulWidget {
  final PostModel post;
  final ValueChanged<int>? onCommentCountChanged;

  const CommentSheet({
    super.key,
    required this.post,
    this.onCommentCountChanged,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  List<PostCommentModel> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  late final String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = GetStorage().read('uid')?.toString();
    _comments = widget.post.comments;
    _loadComments();
  }

  Future<void> _loadComments({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final comments = await PostsService.getComments(widget.post.id);
      if (!mounted) return;

      if (comments.isNotEmpty) {
        setState(() {
          _comments = comments;
        });
      }
      widget.onCommentCountChanged?.call(_comments.length);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'ไม่สามารถโหลดคอมเมนต์ได้';
      });
    } finally {
      if (mounted && showLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final newCommentFromApi = await PostsService.commentOnPost(
      postId: widget.post.id,
      content: text,
    );

    if (!mounted) return;

    if (newCommentFromApi != null) {
      final newComment = newCommentFromApi;

      setState(() {
        _controller.clear();
        _comments = [newComment, ..._comments];
      });

      widget.onCommentCountChanged?.call(_comments.length);
      unawaited(_loadComments(showLoading: false));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งคอมเมนต์ไม่สำเร็จ ลองใหม่อีกครั้ง')),
      );
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _deleteComment(PostCommentModel comment) async {
    final currentUserId = _currentUserId;
    final isCommentOwner = currentUserId != null &&
        (comment.userId == currentUserId || comment.user?.id == currentUserId);
    final isPostOwner = currentUserId != null &&
        widget.post.userId.toString() == currentUserId;

    if (!isCommentOwner && !isPostOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('คุณไม่มีสิทธิ์ลบความคิดเห็นนี้')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบความคิดเห็น'),
        content: const Text('คุณต้องการลบความคิดเห็นนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // If the id is synthetic (no real id yet), refresh comments to get the real id
    String commentId = comment.id;
    if (_isSyntheticId(commentId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กำลังดึงข้อมูลคอมเมนต์ล่าสุด...')),
      );
      final refreshed = await PostsService.getComments(widget.post.id);
      if (!mounted) return;

      setState(() {
        _comments = refreshed;
      });
      widget.onCommentCountChanged?.call(_comments.length);

      final matched = _matchComment(refreshed, comment);
      if (matched != null && !_isSyntheticId(matched.id)) {
        commentId = matched.id;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยังไม่พบรหัสคอมเมนต์ที่แท้จริง กรุณาลองใหม่'),
          ),
        );
        return;
      }
    }

    final ok = await PostsService.deleteComment(
      postId: widget.post.id,
      commentId: commentId,
    );

    if (ok && mounted) {
      setState(() {
        _comments = _comments.where((c) => c.id != comment.id).toList();
      });
      widget.onCommentCountChanged?.call(_comments.length);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบความคิดเห็นไม่สำเร็จ')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'ความคิดเห็น',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(child: Text(_error!))
                          : _comments.isEmpty
                              ? const Center(child: Text('ยังไม่มีความคิดเห็น'))
                              : ListView.separated(
                                  itemCount: _comments.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final comment = _comments[index];
                                    return _buildCommentTile(comment);
                                  },
                                ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _buildInput(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'พิมพ์ความคิดเห็น...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _isSubmitting
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : InkWell(
                    onTap: _submitComment,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A5DB9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentTile(PostCommentModel comment) {
    final displayName =
        comment.user?.username ?? 'ผู้ใช้ ${comment.userId}'.trim();
    final profileImage = comment.user?.profileImage;
    final initial = (displayName.isNotEmpty ? displayName : 'ผู้ใช้').trim();
    final displayInitial = initial.length >= 2
        ? initial.substring(0, 2).toUpperCase()
        : initial.toUpperCase();
    final rawDate = comment.createdAt.toString();
    final formattedDate =
        rawDate.length >= 16 ? rawDate.substring(0, 16) : rawDate;
    final avatarProvider = _resolveAvatar(profileImage);
    final currentUserId = _currentUserId;
    final isCommentOwner = currentUserId != null &&
        (comment.userId == currentUserId || comment.user?.id == currentUserId);
    final isPostOwner = currentUserId != null &&
        widget.post.userId.toString() == currentUserId;
    final canDelete = isCommentOwner || isPostOwner;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE6EBF5),
            backgroundImage: avatarProvider,
            child: avatarProvider == null
                ? Text(
                    displayInitial,
                    style: const TextStyle(
                      color: Color(0xFF2A5DB9),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (canDelete) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints.tightFor(width: 32, height: 32),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.delete_outline,
                            size: 18, color: Colors.grey[600]),
                        onPressed: () => _deleteComment(comment),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _resolveAvatar(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) return null;
    final isFullUrl = profileImage.startsWith('http');
    final url = isFullUrl ? profileImage : '$apiEndpoint/$profileImage';
    return NetworkImage(url);
  }

  bool _isSyntheticId(String id) =>
      id.startsWith('local-') || id.startsWith('gen-') || id.isEmpty;

  PostCommentModel? _matchComment(
    List<PostCommentModel> source,
    PostCommentModel target,
  ) {
    return source.firstWhereOrNull((c) {
      final sameUser = c.userId == target.userId || c.user?.id == target.userId;
      final sameContent = c.content.trim() == target.content.trim();
      return sameUser && sameContent;
    });
  }
}
