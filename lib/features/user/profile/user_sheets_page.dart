import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/services/sheets_service.dart';
import 'package:hero_app_flutter/features/user/profile/sheet_earnings_page.dart';
import 'package:hero_app_flutter/features/user/sheet/preview_sheet_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum _SheetTab { mySheets, purchasedSheets }

class UserSheetsPage extends StatefulWidget {
  final String userId;

  const UserSheetsPage({super.key, required this.userId});

  @override
  State<UserSheetsPage> createState() => _UserSheetsPageState();
}

class _UserSheetsPageState extends State<UserSheetsPage> {
  _SheetTab _selectedTab = _SheetTab.mySheets;

  bool _isLoading = false;
  String _errorMessage = '';
  List<SheetModel> _mySheets = [];
  List<SheetModel> _purchasedSheets = [];
  bool _purchasedLoaded = false;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _currentUserId = GetStorage().read('uid')?.toString() ?? '';
    _fetchMySheets();
  }

  Future<void> _fetchMySheets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sheets = await SheetsService.fetchSheetsByUserId(widget.userId);
      if (!mounted) return;
      setState(() => _mySheets = sheets);
    } catch (e) {
      debugPrint('Error fetching user sheets: $e');
      if (!mounted) return;
      setState(() => _errorMessage = 'ไม่สามารถดึงข้อมูลชีตของคุณได้');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPurchasedSheets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sheets = await SheetsService.fetchPurchasedSheets();
      if (!mounted) return;
      setState(() {
        _purchasedSheets = sheets;
        _purchasedLoaded = true;
      });
    } catch (e) {
      debugPrint('Error fetching purchased sheets: $e');
      if (!mounted) return;
      setState(() => _errorMessage = 'ไม่สามารถดึงข้อมูลชีตที่ซื้อได้');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshCurrentTab() async {
    if (_selectedTab == _SheetTab.mySheets) {
      await _fetchMySheets();
    } else {
      await _fetchPurchasedSheets();
    }
  }

  void _onTabSelected(_SheetTab tab) {
    if (tab == _selectedTab) return;
    setState(() => _selectedTab = tab);
    if (tab == _SheetTab.purchasedSheets && !_purchasedLoaded) {
      _fetchPurchasedSheets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('จัดการชีตของคุณ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildEarningsButton(),
          _buildTabButtons(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTabItem(
              label: 'ชีตของฉัน',
              tab: _SheetTab.mySheets,
            ),
            _buildTabItem(
              label: 'ชีตที่ซื้อแล้ว',
              tab: _SheetTab.purchasedSheets,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({required String label, required _SheetTab tab}) {
    final bool isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          key: const Key('sheet_earnings_button'),
          icon: const Icon(Icons.bar_chart_rounded, size: 22),
          label: const Text(
            'แสดงรายได้ของชีต',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          onPressed: () {
            Get.to(() => const SheetEarningsPage());
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshCurrentTab,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'ลองใหม่',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sheets = _selectedTab == _SheetTab.mySheets
        ? _mySheets
        : _purchasedSheets;

    final emptyText = _selectedTab == _SheetTab.mySheets
        ? 'คุณยังไม่มีชีตที่สร้างไว้'
        : 'คุณยังไม่มีชีตที่ซื้อ';

    return RefreshIndicator(
      onRefresh: _refreshCurrentTab,
      child: sheets.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 220),
                Center(
                  child: Text(
                    emptyText,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: sheets.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'ทั้งหมด ${sheets.length} รายการ',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                final sheet = sheets[index - 1];
                return _buildSheetCard(sheet);
              },
            ),
    );
  }

  Widget _buildSheetCard(SheetModel sheet) {
    final bool isMyTab = _selectedTab == _SheetTab.mySheets;
    final bool canManageSheet = isMyTab &&
        _currentUserId.isNotEmpty &&
        sheet.authorId == _currentUserId;

    return GestureDetector(
      onTap: () => Get.to(() => PreviewSheetPage(sheetId: sheet.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7EAF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: sheet.thumbnail.isNotEmpty
                  ? Image.network(
                      sheet.thumbnail,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sheet.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if ((sheet.description ?? '').trim().isNotEmpty)
                    Text(
                      sheet.description!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(sheet.price),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isMyTab && sheet.buyerCount > 0)
                    Text(
                      'มีผู้ซื้อแล้ว ${sheet.buyerCount} คน',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (!isMyTab && sheet.authorName != null)
                    Text(
                      'โดย ${sheet.authorName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (canManageSheet)
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.black54,
                ),
                onSelected: (value) async {
                  if (value == 'delete') {
                    await _confirmDeleteSheet(sheet);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sheet.buyerCount > 0 ? 'ลบ (มีผู้ซื้อแล้ว)' : 'ลบ',
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              const Icon(Icons.chevron_right_rounded, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteSheet(SheetModel sheet) async {
    if (sheet.buyerCount > 0) {
      _showSnackBar('ไม่สามารถลบชีตนี้ได้ เพราะมีผู้ซื้อแล้ว', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ยืนยันการลบชีต'),
          content: Text('คุณต้องการลบชีต "${sheet.title}" ใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'ลบ',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final result = await SheetsService.deleteSheet(
      sheetId: sheet.id,
      buyerCount: sheet.buyerCount,
    );

    if (!mounted) return;

    _showSnackBar(result.message, isError: !result.success);
    if (result.success) {
      await _fetchMySheets();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 88,
      height: 88,
      color: const Color(0xFFEFF3FA),
      child: const Icon(Icons.description_outlined, color: AppColors.primary),
    );
  }

  String _formatPrice(double? price) {
    if (price == null || price == 0) return 'ฟรี';
    if (price % 1 == 0) return '${price.toInt()} บาท';
    return '${price.toStringAsFixed(2)} บาท';
  }
}
