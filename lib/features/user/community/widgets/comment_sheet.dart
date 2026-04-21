import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/config/api_connect.dart';
import 'package:flutter_application_1/core/models/post_model.dart';
import 'package:flutter_application_1/core/services/posts_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_application_1/constants/app_colors.dart';

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
    final isCommentOwner =
        currentUserId != null &&
        (comment.userId == currentUserId || comment.user?.id == currentUserId);
    final isPostOwner =
        currentUserId != null && widget.post.userId.toString() == currentUserId;

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

    if (!mounted) return;
    if (confirmed != true) return;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ลบความคิดเห็นไม่สำเร็จ')));
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
                          separatorBuilder: (context, index) =>
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
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
                        color: AppColors.primary,
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
    final formattedDate = rawDate.length >= 16
        ? rawDate.substring(0, 16)
        : rawDate;
    final avatarProvider = _resolveAvatar(profileImage);
    final currentUserId = _currentUserId;
    final isCommentOwner =
        currentUserId != null &&
        (comment.userId == currentUserId || comment.user?.id == currentUserId);
    final isPostOwner =
        currentUserId != null && widget.post.userId.toString() == currentUserId;
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
                      color: AppColors.primary,
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
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    if (canDelete) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 32,
                          height: 32,
                        ),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.grey[600],
                        ),
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
