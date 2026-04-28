import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/features/user/community/controllers/create_post_page_controller.dart';
import 'package:hero_app_flutter/features/user/community/widgets/create_post_composer.dart';
import 'package:hero_app_flutter/features/user/community/widgets/selected_sheet_card.dart';
import 'package:hero_app_flutter/features/user/community/widgets/sheet_selection_modal.dart';
import 'package:hero_app_flutter/features/user/sheet/preview_sheet_page.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key, this.controller});

  final CreatePostPageController? controller;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late final CreatePostPageController _controller;

  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CreatePostPageController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _openSheetSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          SheetSelectionModal(onSheetSelected: _controller.selectSheet),
    );
  }

  Future<void> _submit() async {
    final result = await _controller.submit();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (result.success) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final selectedSheet = _controller.selectedSheet;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'สร้างโพสต์',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            actions: [
              TextButton(
                key: const Key('create_post_submit_button'),
                onPressed: _controller.isSubmitting ? null : _submit,
                child: Text(
                  _controller.isSubmitting ? 'กำลังโพสต์...' : 'โพสต์',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CreatePostComposer(controller: _controller.contentController),
                const SizedBox(height: 20),
                if (selectedSheet != null)
                  SelectedSheetCard(
                    sheet: selectedSheet,
                    onOpenSheet: () {
                      Get.to(() => PreviewSheetPage(sheetId: selectedSheet.id));
                    },
                    onRemove: _controller.removeSelectedSheet,
                  ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'เพิ่มชีตลงในโพสต์ของคุณ?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _openSheetSelection,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F0FE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'เลือกชีตสรุป',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
