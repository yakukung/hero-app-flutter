import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/controllers/sheets_controller.dart';
import 'package:flutter_application_1/core/models/product_model.dart';
import 'package:flutter_application_1/core/models/sheet_model.dart';
import 'package:flutter_application_1/features/user/sheet/preview_sheet.dart';
import 'package:flutter_application_1/shared/widgets/product/product_card.dart';
import 'package:flutter_application_1/shared/widgets/search/search_sheet_box.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/shared/widgets/custom_dialog.dart';
import 'package:flutter_application_1/constants/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SheetsController _sheetsController = Get.find<SheetsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetsController.fetchSheets();
    });
  }

  Future<void> _onRefresh() async {
    await _sheetsController.refreshSheets();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = _sheetsController.isLoading.value;
      final errorMessage = _sheetsController.errorMessage.value;
      final sheets = _sheetsController.sheets.toList();

      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : (errorMessage.isNotEmpty && !errorMessage.contains('404'))
              ? _buildErrorView()
              : (sheets.isEmpty || errorMessage.contains('404'))
              ? _buildEmptyView()
              : _buildContent(sheets),
        ),
      );
    });
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _sheetsController.errorMessage.value,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _sheetsController.fetchSheets,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'ลองใหม่',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'ไม่พบชีต',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _sheetsController.fetchSheets,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'รีเฟรช',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<SheetModel> sheets) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 35),
            const SearchSheetBox(),
            const SizedBox(height: 35),
            _buildSectionHeader('ชีตยอดนิยม'),
            const SizedBox(height: 16),
            _buildProductList(sheets),
            const SizedBox(height: 20),
            _buildSectionHeader('ชีตใหม่ล่าสุด'),
            const SizedBox(height: 16),
            _buildProductList(sheets),
            const SizedBox(height: 140),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Handle see all action
            },
            child: const Text(
              'แสดงทั้งหมด',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<SheetModel> sheets) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        children: [
          for (int i = 0; i < sheets.length; i++)
            GestureDetector(
              onTap: () {
                Get.to(() => PreviewSheetPage(sheetId: sheets[i].id));
              },
              child: ProductCard(
                product: Product(
                  id: sheets[i].id,
                  imageUrl: sheets[i].thumbnail,
                  title: sheets[i].title,
                  author: sheets[i].authorName ?? 'Unknown',
                  rating: sheets[i].rating ?? 0.0,
                  price: sheets[i].price == 0 || sheets[i].price == null
                      ? 'ฟรี'
                      : '${sheets[i].price} บาท',
                  isFavorite: sheets[i].isFavorite,
                ),
                colorIndex: i,
                onFavoriteTap: () {
                  final isCurrentlyFavorite = sheets[i].isFavorite;
                  showCustomDialog(
                    title: isCurrentlyFavorite
                        ? 'นำออกจากรายการโปรด'
                        : 'เพิ่มเป็นรายการโปรด',
                    message: isCurrentlyFavorite
                        ? 'คุณต้องการลบจากรายการโปรดไหม'
                        : 'คุณยืนยันที่จะเพิ่มเป็นรายการโปรดไหม',
                    isConfirm: true,
                    onOk: () async {
                      bool success;
                      if (isCurrentlyFavorite) {
                        success = await _sheetsController.removeFavorite(
                          sheets[i].id,
                        );
                      } else {
                        success = await _sheetsController.addFavorite(
                          sheets[i].id,
                        );
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? (isCurrentlyFavorite
                                        ? 'ลบจากรายการโปรดแล้ว'
                                        : 'เพิ่มเป็นรายการโปรดแล้ว')
                                  : 'เกิดข้อผิดพลาด กรุณาลองใหม่',
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
