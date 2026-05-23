import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/post_model.dart';
import 'package:hero_app_flutter/core/services/admin_service.dart';
import 'package:hero_app_flutter/core/services/posts_service.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_widgets.dart';
import 'package:hero_app_flutter/shared/widgets/profile_avatar.dart';

class AdminCommunityModerationPage extends StatefulWidget {
  const AdminCommunityModerationPage({super.key});

  @override
  State<AdminCommunityModerationPage> createState() =>
      _AdminCommunityModerationPageState();
}

class _AdminCommunityModerationPageState
    extends State<AdminCommunityModerationPage> {
  final _sessionStore = SessionStore();
  final Set<String> _updatingPostIds = <String>{};
  final Map<String, StatusFlag> _postStatusOverrides = <String, StatusFlag>{};
  late Future<List<PostModel>> _postsFuture;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  StatusFlag? _statusFilter;

  @override
  void initState() {
    super.initState();
    _postsFuture = PostsService.getPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final nextPostsFuture = PostsService.getPosts();
    setState(() {
      _postsFuture = nextPostsFuture;
    });
    await nextPostsFuture;
  }

  List<PostModel> _applyFilters(List<PostModel> posts) {
    var result = posts;
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((p) {
        final author = p.author.username?.toLowerCase() ?? p.userId.toLowerCase();
        return author.contains(q) || p.content.toLowerCase().contains(q);
      }).toList();
    }
    if (_statusFilter != null) {
      result = result.where((p) {
        final effective = _effectiveContentStatus(p.statusFlag, p.visibleFlag);
        return effective == _statusFilter;
      }).toList();
    }
    return result;
  }

  Future<bool> _updatePostStatus(PostModel post, StatusFlag status) async {
    if (_updatingPostIds.contains(post.id)) return false;

    setState(() {
      _updatingPostIds.add(post.id);
    });
    try {
      final response = await AdminService.updatePostStatus(
        postId: post.id,
        statusFlag: status.name,
        token: _sessionStore.token,
      );

      if (!mounted) return false;
      final messenger = ScaffoldMessenger.of(context);
      if (_isOkResponse(response.statusCode)) {
        setState(() => _postStatusOverrides[post.id] = status);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'อัปเดตโพสต์เป็น ${_contentStatusLabel(status)} แล้ว',
            ),
          ),
        );
        return true;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            getErrorMessage(response, fallback: 'อัปเดตโพสต์ไม่สำเร็จ'),
          ),
        ),
      );
      return false;
    } finally {
      if (mounted) setState(() => _updatingPostIds.remove(post.id));
    }
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(
          fontFamily: AppFonts.sukhumvit,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AdminColors.text,
        ),
        decoration: InputDecoration(
          hintText: 'ค้นหาชื่อผู้ใช้ หรือเนื้อหาโพสต์',
          hintStyle: const TextStyle(
            fontFamily: AppFonts.sukhumvit,
            color: AdminColors.muted,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(Icons.search_rounded, size: 22, color: AdminColors.muted),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AdminColors.muted,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    const statuses = [StatusFlag.ACTIVE, StatusFlag.INACTIVE];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _FilterChip(
              label: 'ทั้งหมด',
              selected: _statusFilter == null,
              onTap: () => setState(() => _statusFilter = null),
            );
          }
          final status = statuses[index - 1];
          return _FilterChip(
            label: status == StatusFlag.ACTIVE ? 'แสดง' : 'ซ่อน',
            color: _contentStatusColor(status),
            selected: _statusFilter == status,
            onTap: () => setState(() => _statusFilter = status),
          );
        },
      ),
    );
  }

  Future<void> _showComments(PostModel post) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AdminPostCommentsSheet(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<PostModel>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return AdminEmptyStatePage(
              title: 'จัดการชุมชน',
              icon: Icons.error_outline,
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRefresh: _refresh,
            );
          }

          final allPosts = (snapshot.data ?? const <PostModel>[])
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (allPosts.isEmpty) {
            return AdminEmptyStatePage(
              title: 'จัดการชุมชน',
              icon: Icons.forum_outlined,
              message: 'ยังไม่มีโพสต์ในระบบ',
              onRefresh: _refresh,
            );
          }

          final posts = _applyFilters(allPosts);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
              itemCount: posts.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminPageHeader(
                        title: 'จัดการชุมชน',
                        subtitle: '${allPosts.length} โพสต์ในระบบ',
                        icon: Icons.forum_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      _buildFilterChips(),
                      const SizedBox(height: 14),
                      AdminSectionHeader(
                        title: 'โพสต์ทั้งหมด',
                        subtitle: '${posts.length} รายการ',
                      ),
                    ],
                  );
                }

                final post = posts[index - 1];
                final overriddenStatus = _postStatusOverrides[post.id];
                final statusFlag = overriddenStatus ?? post.statusFlag;
                final visibleFlag = overriddenStatus == null
                    ? post.visibleFlag
                    : overriddenStatus == StatusFlag.ACTIVE;
                final nextStatus =
                    _isContentVisible(statusFlag, visibleFlag)
                        ? StatusFlag.INACTIVE
                        : StatusFlag.ACTIVE;
                return _AdminPostCard(
                  post: post,
                  isUpdating: _updatingPostIds.contains(post.id),
                  onShowComments: () => _showComments(post),
                  onToggleStatus: () => _updatePostStatus(post, nextStatus),
                  effectiveStatus: _effectiveContentStatus(statusFlag, visibleFlag),
                  isVisible: _isContentVisible(statusFlag, visibleFlag),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AdminPostCard extends StatelessWidget {
  const _AdminPostCard({
    required this.post,
    required this.isUpdating,
    required this.onShowComments,
    required this.onToggleStatus,
    required this.effectiveStatus,
    required this.isVisible,
  });

  final PostModel post;
  final bool isUpdating;
  final VoidCallback onShowComments;
  final VoidCallback onToggleStatus;
  final StatusFlag effectiveStatus;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final statusColor = _contentStatusColor(effectiveStatus);
    final authorName = post.author.username?.isNotEmpty == true
        ? post.author.username!
        : post.userId;
    final actionIcon =
        isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    final actionLabel = isVisible ? 'ซ่อน' : 'แสดง';
    final actionButtonIcon = isUpdating
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(actionIcon, size: 20);

    return AdminCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                uid: post.author.id,
                username: post.author.username,
                imageUrl: post.author.profileImage,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        fontFamily: AppFonts.sukhumvit,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.text,
                      ),
                    ),
                    Text(
                      _formatDateTime(post.createdAt),
                      style: const TextStyle(
                        fontFamily: AppFonts.sukhumvit,
                        fontSize: 12,
                        color: AdminColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              AdminStatusPill(
                label: _contentStatusLabel(effectiveStatus),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppFonts.sukhumvit,
              fontSize: 14,
              color: AdminColors.text,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(icon: Icons.favorite_border, count: post.likeCount),
                _StatItem(
                  icon: Icons.mode_comment_outlined,
                  count: post.commentCount,
                ),
                _StatItem(icon: Icons.share_outlined, count: post.shareCount),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShowComments,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.mode_comment_outlined, size: 18),
                  label: const Text(
                    'คอมเมนต์',
                    style: TextStyle(fontFamily: AppFonts.sukhumvit),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: isVisible
                    ? OutlinedButton.icon(
                        onPressed: isUpdating ? null : onToggleStatus,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: actionButtonIcon,
                        label: Text(
                          actionLabel,
                          style: const TextStyle(fontFamily: AppFonts.sukhumvit),
                        ),
                      )
                    : FilledButton.icon(
                        onPressed: isUpdating ? null : onToggleStatus,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: actionButtonIcon,
                        label: Text(
                          actionLabel,
                          style: const TextStyle(fontFamily: AppFonts.sukhumvit),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AdminColors.muted),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: const TextStyle(
            fontFamily: AppFonts.sukhumvit,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AdminColors.text,
          ),
        ),
      ],
    );
  }
}

class _AdminPostCommentsSheet extends StatefulWidget {
  const _AdminPostCommentsSheet({required this.post});

  final PostModel post;

  @override
  State<_AdminPostCommentsSheet> createState() =>
      _AdminPostCommentsSheetState();
}

class _AdminPostCommentsSheetState extends State<_AdminPostCommentsSheet> {
  final _sessionStore = SessionStore();
  final Set<String> _updatingCommentIds = <String>{};
  final Map<String, StatusFlag> _commentStatusOverrides = <String, StatusFlag>{};
  late Future<List<PostCommentModel>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _fetchComments();
  }

  Future<List<PostCommentModel>> _fetchComments() async {
    final response = await AdminService.fetchPostComments(
      postId: widget.post.id,
      token: _sessionStore.token,
    );

    if (_isOkResponse(response.statusCode)) {
      final adminComments =
          getApiList(response.body, const ['comments', 'items', 'data'])
              .whereType<Map>()
              .map(
                (item) =>
                    PostCommentModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
      if (adminComments.isNotEmpty || widget.post.commentCount == 0) {
        return adminComments;
      }
      return _fallbackComments();
    }

    if (response.statusCode == 404) return _fallbackComments();

    throw Exception(
      getErrorMessage(response, fallback: 'โหลดคอมเมนต์ไม่สำเร็จ'),
    );
  }

  Future<List<PostCommentModel>> _fallbackComments() async {
    final publicComments = await PostsService.getComments(widget.post.id);
    if (publicComments.isNotEmpty) return publicComments;
    if (widget.post.comments.isNotEmpty) return widget.post.comments;
    return const <PostCommentModel>[];
  }

  Future<void> _refresh() async {
    final nextCommentsFuture = _fetchComments();
    setState(() {
      _commentsFuture = nextCommentsFuture;
    });
    await nextCommentsFuture;
  }

  Future<void> _updateCommentStatus(
    PostCommentModel comment,
    StatusFlag status,
  ) async {
    if (_updatingCommentIds.contains(comment.id)) return;

    setState(() => _updatingCommentIds.add(comment.id));
    try {
      final response = await AdminService.updateCommentStatus(
        commentId: comment.id,
        statusFlag: status.name,
        token: _sessionStore.token,
      );

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      if (_isOkResponse(response.statusCode)) {
        setState(() => _commentStatusOverrides[comment.id] = status);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'อัปเดตคอมเมนต์เป็น ${_contentStatusLabel(status)} แล้ว',
            ),
          ),
        );
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            getErrorMessage(response, fallback: 'อัปเดตคอมเมนต์ไม่สำเร็จ'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _updatingCommentIds.remove(comment.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.88,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'จัดการคอมเมนต์',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PostCommentModel>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return AdminEmptyStatePage(
                    title: 'คอมเมนต์',
                    icon: Icons.error_outline,
                    message: snapshot.error
                        .toString()
                        .replaceFirst('Exception: ', ''),
                    onRefresh: _refresh,
                  );
                }

                final comments = snapshot.data ?? const <PostCommentModel>[];
                if (comments.isEmpty) {
                  return AdminEmptyStatePage(
                    title: 'คอมเมนต์',
                    icon: Icons.mode_comment_outlined,
                    message: 'โพสต์นี้ยังไม่มีคอมเมนต์',
                    onRefresh: _refresh,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: comments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final isUpdating =
                          _updatingCommentIds.contains(comment.id);
                      final overriddenStatus =
                          _commentStatusOverrides[comment.id];
                      final statusFlag = overriddenStatus ?? comment.statusFlag;
                      final visibleFlag = overriddenStatus == null
                          ? comment.visibleFlag
                          : overriddenStatus == StatusFlag.ACTIVE;
                      final effectiveStatus =
                          _effectiveContentStatus(statusFlag, visibleFlag);
                      final isVisible =
                          _isContentVisible(statusFlag, visibleFlag);
                      final username = comment.user?.username?.isNotEmpty == true
                          ? comment.user!.username!
                          : comment.userId;
                      return Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: AdminColors.border),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      username,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  AdminStatusPill(
                                    label: _contentStatusLabel(effectiveStatus),
                                    color: _contentStatusColor(effectiveStatus),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(comment.content),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  AdminInfoText(
                                    icon: Icons.schedule_outlined,
                                    text: _formatDateTime(comment.createdAt),
                                  ),
                                  _CommentStatusButton(
                                    isVisible: isVisible,
                                    isUpdating: isUpdating,
                                    onPressed: isUpdating
                                        ? null
                                        : () => _updateCommentStatus(
                                              comment,
                                              isVisible
                                                  ? StatusFlag.INACTIVE
                                                  : StatusFlag.ACTIVE,
                                            ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentStatusButton extends StatelessWidget {
  const _CommentStatusButton({
    required this.isVisible,
    required this.isUpdating,
    required this.onPressed,
  });

  final bool isVisible;
  final bool isUpdating;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = isUpdating
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(
            isVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          );
    final label = Text(isVisible ? 'ซ่อน' : 'แสดง');

    if (isVisible) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: label,
      );
    }

    return FilledButton.icon(onPressed: onPressed, icon: icon, label: label);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? (color ?? AdminColors.primary) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: selected
              ? Border.all(
                  color: (color ?? AdminColors.primary).withValues(alpha: 0.3),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.sukhumvit,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AdminColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isOkResponse(int statusCode) => statusCode >= 200 && statusCode < 300;

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${_two(local.day)}/${_two(local.month)}/${local.year} '
      '${_two(local.hour)}:${_two(local.minute)}';
}

String _two(int value) => value.toString().padLeft(2, '0');

String _contentStatusLabel(StatusFlag status) {
  switch (status) {
    case StatusFlag.PENDING:
      return 'รอตรวจ';
    case StatusFlag.ACTIVE:
      return 'แสดง';
    case StatusFlag.INACTIVE:
      return 'ซ่อน';
    case StatusFlag.SUSPENDED:
      return 'ระงับ';
    case StatusFlag.TERMINATED:
      return 'ยุติ';
  }
}

StatusFlag _effectiveContentStatus(StatusFlag status, bool visibleFlag) {
  if (!visibleFlag && status == StatusFlag.ACTIVE) {
    return StatusFlag.INACTIVE;
  }
  return status;
}

bool _isContentVisible(StatusFlag status, bool visibleFlag) {
  return visibleFlag && status == StatusFlag.ACTIVE;
}

Color _contentStatusColor(StatusFlag status) {
  switch (status) {
    case StatusFlag.PENDING:
      return const Color(0xFFB26A00);
    case StatusFlag.ACTIVE:
      return const Color(0xFF1B7F3A);
    case StatusFlag.INACTIVE:
      return const Color(0xFF4B5563);
    case StatusFlag.SUSPENDED:
      return const Color(0xFFC62828);
    case StatusFlag.TERMINATED:
      return const Color(0xFF7F1D1D);
  }
}
