import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/models/sheet_model.dart';
import 'package:flutter_application_1/pages/user/sheet/preview_sheet.dart';
import 'package:flutter_application_1/widgets/product/product_card.dart';
import 'package:flutter_application_1/widgets/search/search_sheet_box.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:flutter_application_1/services/sheets.service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Appdata>(context, listen: false).fetchUserData();
      Provider.of<SheetData>(context, listen: false).fetchSheets();
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<SheetData>(context, listen: false).refreshSheets();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SheetData>(
      builder: (context, sheetData, child) {
        final isLoading = sheetData.isLoading;
        final errorMessage = sheetData.errorMessage;
        final sheets = sheetData.sheets;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? _buildErrorView(sheetData)
                : sheets.isEmpty
                ? _buildEmptyView()
                : _buildContent(sheets, sheetData),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(SheetData sheetData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            sheetData.errorMessage,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: sheetData.fetchSheets,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A5DB9),
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
    return const Center(
      child: Text(
        'ไม่มีข้อมูลผลิตภัณฑ์',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildContent(List<SheetModel> sheets, SheetData sheetData) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF2A5DB9),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 35),
            const SearchSheetBox(),
            const SizedBox(height: 35),
            _buildSectionHeader('ชีตยอดนิยม'),
            const SizedBox(height: 16),
            _buildProductList(sheets, sheetData),
            const SizedBox(height: 20),
            _buildSectionHeader('ชีตใหม่ล่าสุด'),
            const SizedBox(height: 16),
            _buildProductList(sheets, sheetData),
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

  Widget _buildProductList(List<SheetModel> sheets, SheetData sheetData) {
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
                  isFavorite: false, // Will handle this later
                ),
                colorIndex: i, // Use index for gradient color
                onFavoriteTap: () {
                  sheetData.toggleFavorite(sheets[i].id);
                },
              ),
            ),
        ],
      ),
    );
  }
}
