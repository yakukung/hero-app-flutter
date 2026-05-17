import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/features/user/sheet/controllers/preview_sheet_page_controller.dart';
import 'package:hero_app_flutter/features/user/sheet/quiz_page.dart';
import 'package:hero_app_flutter/features/user/sheet/sheet_preview_reader.dart';
import 'package:hero_app_flutter/features/user/sheet/widgets/preview_sheet_bottom_action_bar.dart';
import 'package:hero_app_flutter/features/user/sheet/widgets/preview_sheet_content_section.dart';
import 'package:hero_app_flutter/features/user/profile/profile_wallet_page.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';

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
                  PreviewSheetContentSection(sheet: sheet),
                  _SheetReviewsSection(
                    reviews: _controller.reviews,
                    isLoading: _controller.isLoadingReviews,
                    errorMessage: _controller.reviewErrorMessage,
                    onSubmitReview: _submitReview,
                  ),
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

  Widget _buildHeader(SheetModel sheet) {
    return SliverAppBar(
      expandedHeight: 400.0,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _buildCircleButton(
        icon: Icons.arrow_back,
        onPressed: () => Get.back(),
      ),
      actions: [
        _buildCircleButton(
          icon: sheet.isFavorite
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          iconColor: sheet.isFavorite ? Colors.amber : Colors.white,
          onPressed: _toggleFavorite,
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
    return IconButton(
      icon: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 60),
    );
  }
}

class _SheetReviewsSection extends StatefulWidget {
  const _SheetReviewsSection({
    required this.reviews,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmitReview,
  });

  final List<SheetReviewModel> reviews;
  final bool isLoading;
  final String errorMessage;
  final Future<void> Function(int score, String content) onSubmitReview;

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
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 160),
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
              ...widget.reviews.map(_ReviewTile.new),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                tooltip: '$value ดาว',
                onPressed: () => setState(() => _score = value),
                icon: Icon(
                  value <= _score ? Icons.star_rounded : Icons.star_border,
                  color: const Color(0xFFFFC107),
                ),
              );
            }),
          ),
          TextField(
            controller: _reviewController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'เขียนรีวิวของคุณ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(_isSubmitting ? 'กำลังส่ง...' : 'ส่งรีวิว'),
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
  const _ReviewTile(this.review);

  final SheetReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E8F0)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < review.score
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 18,
                  color: const Color(0xFFFFC107),
                ),
              ),
              const Spacer(),
              Text(
                '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          if (review.content != null && review.content!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.content!),
          ],
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
