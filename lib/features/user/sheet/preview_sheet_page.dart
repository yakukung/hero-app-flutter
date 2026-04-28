import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/features/user/sheet/controllers/preview_sheet_page_controller.dart';
import 'package:hero_app_flutter/features/user/sheet/quiz_page.dart';
import 'package:hero_app_flutter/features/user/sheet/sheet_preview_reader.dart';
import 'package:hero_app_flutter/features/user/sheet/widgets/preview_sheet_bottom_action_bar.dart';
import 'package:hero_app_flutter/features/user/sheet/widgets/preview_sheet_content_section.dart';
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
      onOk: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ระบบชำระเงินกำลังจะมาเร็วๆ นี้')),
        );
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
