import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/quiz_leaderboard_entry_model.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/services/reports_service.dart';
import 'package:hero_app_flutter/features/user/profile/user_profile_view_page.dart';
import 'package:hero_app_flutter/features/user/sheet/controllers/preview_sheet_page_controller.dart';
import 'package:hero_app_flutter/features/user/sheet/quiz_page.dart';
import 'package:hero_app_flutter/features/user/sheet/sheet_preview_reader.dart';
import 'package:hero_app_flutter/features/user/sheet/widgets/preview_sheet_bottom_action_bar.dart';
import 'package:hero_app_flutter/features/user/sheet/widgets/preview_sheet_content_section.dart';
import 'package:hero_app_flutter/features/user/profile/profile_wallet_page.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:hero_app_flutter/shared/widgets/profile_avatar.dart';

class PreviewSheetPage extends StatefulWidget {
  const PreviewSheetPage({super.key, required this.sheetId, this.controller});

  final String sheetId;
  final PreviewSheetPageController? controller;

  @override
  State<PreviewSheetPage> createState() => _PreviewSheetPageState();
}

class _PreviewSheetPageState extends State<PreviewSheetPage> {
  late final PreviewSheetPageController _controller;

  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        PreviewSheetPageController(sheetId: widget.sheetId);
    _controller.load();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_controller.errorMessage.isNotEmpty || _controller.sheet == null) {
          return Scaffold(
            body: Center(
              child: Text(
                _controller.errorMessage.isNotEmpty
                    ? _controller.errorMessage
                    : 'Failed to load sheet',
              ),
            ),
          );
        }

        final sheet = _controller.sheet!;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildHeader(sheet),
                  PreviewSheetContentSection(
                    sheet: sheet,
                    onAuthorTap: () => _openAuthorProfile(sheet),
                    onReportTap: () => _reportSheet(sheet.id),
                  ),
                  _SheetReviewsSection(
                    reviews: _controller.reviews,
                    isLoading: _controller.isLoadingReviews,
                    errorMessage: _controller.reviewErrorMessage,
                    currentUserId: _controller.currentUserId,
                    hasExistingReview: _controller.hasExistingReview,
                    currentUserReviewId: _controller.currentUserReviewId,
                    onSubmitReview: _submitReview,
                    onDeleteReview: _deleteReview,
                  ),
                  if (sheet.questions?.isNotEmpty ?? false)
                    _LeaderboardSection(
                      leaderboard: _controller.leaderboard,
                      isLoading: _controller.isLoadingLeaderboard,
                      totalQuestions: sheet.questions!.length,
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
              PreviewSheetBottomActionBar(
                canReadFull: _controller.canReadFull,
                hasQuestions: sheet.questions?.isNotEmpty ?? false,
                onReadPreview: () => _openReader(fullVersion: false),
                onReadFull: () => _openReader(fullVersion: true),
                onBuy: _buySheet,
                onQuiz: _openQuiz,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openReader({required bool fullVersion}) {
    final sheet = _controller.sheet;
    if (sheet == null) {
      return;
    }

    final previewImages = _controller.previewImages;
    if (previewImages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่มีเนื้อหาให้อ่าน')));
      return;
    }

    final imagesToRead = fullVersion
        ? (sheet.files?.map((file) => file.fullOriginalUrl).toList() ??
              previewImages)
        : previewImages;

    Get.to(
      () => SheetPreviewReader(
        images: imagesToRead,
        title: fullVersion ? '${sheet.title} (ฉบับเต็ม)' : sheet.title,
      ),
    );
  }

  void _buySheet() {
    final sheet = _controller.sheet;
    if (sheet == null) {
      return;
    }

    showCustomDialog(
      title: 'ยืนยันการซื้อ',
      message: 'คุณต้องการซื้อ "${sheet.title}" ในราคา ${sheet.price} บาท?',
      isConfirm: true,
      onOk: () async {
        final result = await _controller.purchase();
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message)));

        if (!result.success &&
            (result.message.contains('เงิน') ||
                result.message.contains('wallet') ||
                result.message.contains('ยอด'))) {
          Get.to(() => const ProfileWalletPage());
        } else if (result.success) {
          await _controller.load();
        }
      },
    );
  }

  Future<void> _submitReview(int score, String content) async {
    if (_controller.hasExistingReview) {
      if (!mounted) return;
      showCustomDialog(
        title: 'รีวิวแล้ว',
        message:
            'คุณมีรีวิวอยู่แล้ว กรุณาลบรีวิวเก่าก่อนจึงจะสามารถรีวิวใหม่ได้',
        onOk: () {},
      );
      return;
    }

    final result = await _controller.submitReview(
      score: score,
      content: content,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _deleteReview(String reviewId) async {
    await showCustomDialog(
      title: 'ลบรีวิว',
      message: 'คุณต้องการลบรีวิวนี้ใช่ไหม?',
      isConfirm: true,
      isDanger: true,
      onOk: () async {
        final result = await _controller.deleteReview(reviewId);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message)));
      },
    );
  }

  void _openQuiz() {
    final sheet = _controller.sheet;
    if (sheet == null) {
      return;
    }

    if (sheet.questions == null || sheet.questions!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('หน้านี้ยังไม่มีโจทย์ท้ายบท')),
      );
      return;
    }

    Get.to(
      () => QuizPage(
        id: sheet.id,
        title: 'โจทย์ท้ายบท: ${sheet.title}',
        questions: sheet.questions!,
      ),
    );
  }

  void _openAuthorProfile(SheetModel sheet) {
    if (sheet.authorId.isEmpty) return;
    Get.to(() => UserProfileViewPage(userId: sheet.authorId));
  }

  void _toggleFavorite() {
    final sheet = _controller.sheet;
    if (sheet == null) {
      return;
    }

    final isCurrentlyFavorite = sheet.isFavorite;
    showCustomDialog(
      title: isCurrentlyFavorite ? 'นำออกจากรายการโปรด' : 'เพิ่มเป็นรายการโปรด',
      message: isCurrentlyFavorite
          ? 'คุณต้องการลบจากรายการโปรดไหม'
          : 'คุณยืนยันที่จะเพิ่มเป็นรายการโปรดไหม',
      isConfirm: true,
      onOk: () async {
        final result = await _controller.toggleFavorite();
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  void _reportSheet(String sheetId) {
    final detailController = TextEditingController();
    final reportTypes = ReportType.forTable('sheets');
    var selectedType = reportTypes.first;

    showCustomDialog(
      title: 'รายงานชีต',
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
          referenceId: sheetId,
          referenceTable: 'sheets',
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

  

  Widget _buildHeader(SheetModel sheet) {
    return SliverAppBar(
      expandedHeight: 400.0,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: _buildCircleButton(
          icon: Icons.arrow_back,
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        _buildCircleButton(
          icon: sheet.isFavorite
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          iconColor: sheet.isFavorite ? Colors.amber : Colors.white,
          onPressed: _toggleFavorite,
        ),
        const SizedBox(width: 8),
        _buildCircleButton(
          icon: Icons.flag_outlined,
          onPressed: () => _reportSheet(sheet.id),
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: GestureDetector(
          onTap: () => _openReader(fullVersion: _controller.canReadFull),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'sheet_image_${sheet.id}',
                child: sheet.thumbnail.isNotEmpty
                    ? Image.network(
                        sheet.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fullscreen_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _controller.canReadFull
                                ? 'แตะเพื่ออ่านฉบับเต็ม'
                                : 'แตะเพื่อดูตัวอย่าง',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 60),
    );
  }
}

String _formatReviewDate(DateTime dt) {
  final local = dt.toLocal();
  final now = DateTime.now();
  final diff = now.difference(dt);
  String dayStr;
  if (diff.inDays == 0) {
    dayStr = 'วันนี้';
  } else if (diff.inDays == 1) {
    dayStr = 'เมื่อวาน';
  } else {
    dayStr = '${local.day}/${local.month}/${local.year}';
  }
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$dayStr  $hour:$minute';
}

class _SheetReviewsSection extends StatefulWidget {
  const _SheetReviewsSection({
    required this.reviews,
    required this.isLoading,
    required this.errorMessage,
    required this.currentUserId,
    required this.hasExistingReview,
    required this.currentUserReviewId,
    required this.onSubmitReview,
    required this.onDeleteReview,
  });

  final List<SheetReviewModel> reviews;
  final bool isLoading;
  final String errorMessage;
  final String currentUserId;
  final bool hasExistingReview;
  final String? currentUserReviewId;
  final Future<void> Function(int score, String content) onSubmitReview;
  final Future<void> Function(String reviewId) onDeleteReview;

  @override
  State<_SheetReviewsSection> createState() => _SheetReviewsSectionState();
}

class _SheetReviewsSectionState extends State<_SheetReviewsSection> {
  final TextEditingController _reviewController = TextEditingController();
  int _score = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รีวิวชีต',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildReviewForm(),
            const SizedBox(height: 20),
            if (widget.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (widget.errorMessage.isNotEmpty)
              _EmptyReviewMessage(message: widget.errorMessage)
            else if (widget.reviews.isEmpty)
              const _EmptyReviewMessage(message: 'ยังไม่มีรีวิวสำหรับชีตนี้')
            else
              ...widget.reviews.map(
                (r) => _ReviewTile(
                  review: r,
                  isOwnReview: r.userId == widget.currentUserId,
                  onDelete: r.userId == widget.currentUserId
                      ? () => widget.onDeleteReview(r.id)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewForm() {
    if (widget.hasExistingReview) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE082)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFF57F17), size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'คุณมีรีวิวอยู่แล้ว กรุณาลบรีวิวเก่าก่อนจึงจะสามารถรีวิวใหม่ได้',
                style: TextStyle(fontSize: 13, color: Color(0xFF795548)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F9FF), Color(0xFFF5F7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'ให้คะแนน',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4A6A),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _score = value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        value <= _score
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 32,
                        color: value <= _score
                            ? const Color(0xFFFFB300)
                            : const Color(0xFFD0D0D0),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _reviewController,
            minLines: 3,
            maxLines: 5,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'เขียนรีวิวของคุณ…',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF6C63FF),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _isSubmitting ? 'กำลังส่ง…' : 'ส่งรีวิว',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await widget.onSubmitReview(_score, _reviewController.text.trim());
    if (!mounted) {
      return;
    }
    _reviewController.clear();
    setState(() => _isSubmitting = false);
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
    this.isOwnReview = false,
    this.onDelete,
  });

  final SheetReviewModel review;
  final bool isOwnReview;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOwnReview
              ? const Color(0xFFFFE082)
              : const Color(0xFFEEF0F6),
          width: isOwnReview ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                uid: review.userId,
                username: review.username,
                imageUrl: review.profileImage,
                size: 34,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.username ?? 'ผู้ใช้',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF2D2D3A),
                          ),
                        ),
                        if (isOwnReview) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'คุณ',
                              style: TextStyle(
                                color: Color(0xFFE65100),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < review.score
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 14,
                            color: const Color(0xFFFFB300),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${review.score}',
                          style: const TextStyle(
                            color: Color(0xFFFFB300),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isOwnReview && onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
            ],
          ),
          if (review.content != null && review.content!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                review.content!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3D3D4A),
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                _formatReviewDate(review.createdAt),
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection({
    required this.leaderboard,
    required this.isLoading,
    required this.totalQuestions,
  });

  final List<QuizLeaderboardEntryModel> leaderboard;
  final bool isLoading;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'อันดับผู้ทำโจทย์ท้ายบท',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (leaderboard.isEmpty)
              _buildEmptyState()
            else
              ..._buildLeaderboardEntries(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'ยังไม่มีผู้ทำโจทย์ท้ายบท',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  List<Widget> _buildLeaderboardEntries() {
    return List.generate(leaderboard.length, (index) {
      final entry = leaderboard[index];
      return _buildLeaderboardTile(entry, index);
    });
  }

  Widget _buildLeaderboardTile(QuizLeaderboardEntryModel entry, int rank) {
    final Color rankColor;
    final IconData rankIcon;
    if (rank == 0) {
      rankColor = const Color(0xFFFFD700);
      rankIcon = Icons.emoji_events;
    } else if (rank == 1) {
      rankColor = const Color(0xFFC0C0C0);
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = const Color(0xFFCD7F32);
      rankIcon = Icons.emoji_events;
    } else {
      rankColor = Colors.grey;
      rankIcon = Icons.person;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rank < 3
            ? rankColor.withValues(alpha: 0.08)
            : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        border: rank < 3
            ? Border.all(color: rankColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Icon(rankIcon, color: rankColor, size: 22),
          const SizedBox(width: 10),
          ProfileAvatar(
            uid: entry.userId,
            username: entry.username,
            imageUrl: entry.profileImage,
            size: 32,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.username.isNotEmpty ? entry.username : 'ผู้ใช้',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${entry.correctCount}/${totalQuestions}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: entry.correctCount == totalQuestions
                  ? const Color(0xFF4CAF50)
                  : Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReviewMessage extends StatelessWidget {
  const _EmptyReviewMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
