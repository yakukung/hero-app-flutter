import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_colors.dart';
import 'package:flutter_application_1/core/models/sheet_model.dart';
import 'package:flutter_application_1/core/services/sheets.service.dart';
import 'package:flutter_application_1/features/user/sheet/preview_sheet_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserSheetsPage extends StatefulWidget {
  final String userId;

  const UserSheetsPage({super.key, required this.userId});

  @override
  State<UserSheetsPage> createState() => _UserSheetsPageState();
}

class _UserSheetsPageState extends State<UserSheetsPage> {
  bool _isLoading = false;
  String _errorMessage = '';
  List<SheetModel> _sheets = [];
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _currentUserId = GetStorage().read('uid')?.toString() ?? '';
    _fetchUserSheets();
  }

  Future<void> _fetchUserSheets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sheets = await SheetsService.fetchSheetsByUserId(widget.userId);
      if (!mounted) return;

      setState(() {
        _sheets = sheets;
      });
    } catch (e) {
      debugPrint('Error fetching user sheets: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'ไม่สามารถดึงข้อมูลชีตของคุณได้';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('รายการชีตทั้งหมดของคุณ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _buildBody(),
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
                onPressed: _fetchUserSheets,
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

    return RefreshIndicator(
      onRefresh: _fetchUserSheets,
      child: _sheets.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 220),
                Center(
                  child: Text(
                    'คุณยังไม่มีชีตที่สร้างไว้',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: _sheets.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'ทั้งหมด ${_sheets.length} รายการ',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                final sheet = _sheets[index - 1];
                return _buildSheetCard(sheet);
              },
            ),
    );
  }

  Widget _buildSheetCard(SheetModel sheet) {
    final bool canManageSheet =
        _currentUserId.isNotEmpty && sheet.authorId == _currentUserId;

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
                  if (sheet.buyerCount > 0)
                    Text(
                      'มีผู้ซื้อแล้ว ${sheet.buyerCount} คน',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w600,
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
      await _fetchUserSheets();
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
