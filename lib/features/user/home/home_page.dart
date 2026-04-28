import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/features/user/home/controllers/home_page_controller.dart';
import 'package:hero_app_flutter/features/user/home/widgets/home_sheet_section.dart';
import 'package:hero_app_flutter/features/user/home/widgets/home_state_view.dart';
import 'package:hero_app_flutter/features/user/sheet/preview_sheet_page.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';
import 'package:hero_app_flutter/shared/widgets/search/search_sheet_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.controller});

  final HomePageController? controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomePageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? HomePageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sheetsController = _controller.sheetsController;

    return Obx(() {
      final isLoading = sheetsController.isLoading.value;
      final errorMessage = sheetsController.errorMessage.value;
      final sheets = sheetsController.sheets.toList();

      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: isLoading
              ? const HomeStateView.loading()
              : (errorMessage.isNotEmpty && !errorMessage.contains('404'))
              ? HomeStateView(
                  icon: Icons.error_outline,
                  title: 'เกิดข้อผิดพลาด',
                  message: errorMessage,
                  actionLabel: 'ลองใหม่',
                  isError: true,
                  onAction: _controller.load,
                )
              : (sheets.isEmpty || errorMessage.contains('404'))
              ? HomeStateView(
                  icon: Icons.inbox_outlined,
                  title: 'ไม่พบชีต',
                  message: '',
                  actionLabel: 'รีเฟรช',
                  onAction: _controller.load,
                )
              : RefreshIndicator(
                  onRefresh: _controller.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 35),
                        const SearchSheetBox(),
                        const SizedBox(height: 35),
                        HomeSheetSection(
                          title: 'ชีตยอดนิยม',
                          sheets: sheets,
                          onOpenSheet: _openSheet,
                          onFavoriteTap: _confirmToggleFavorite,
                        ),
                        const SizedBox(height: 20),
                        HomeSheetSection(
                          title: 'ชีตใหม่ล่าสุด',
                          sheets: sheets,
                          onOpenSheet: _openSheet,
                          onFavoriteTap: _confirmToggleFavorite,
                        ),
                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ),
        ),
      );
    });
  }

  void _openSheet(SheetModel sheet) {
    Get.to(() => PreviewSheetPage(sheetId: sheet.id));
  }

  void _confirmToggleFavorite(SheetModel sheet) {
    final isCurrentlyFavorite = sheet.isFavorite;
    showCustomDialog(
      title: isCurrentlyFavorite ? 'นำออกจากรายการโปรด' : 'เพิ่มเป็นรายการโปรด',
      message: isCurrentlyFavorite
          ? 'คุณต้องการลบจากรายการโปรดไหม'
          : 'คุณยืนยันที่จะเพิ่มเป็นรายการโปรดไหม',
      isConfirm: true,
      onOk: () async {
        final result = await _controller.toggleFavorite(sheet);
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
}
