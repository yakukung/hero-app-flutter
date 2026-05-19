import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/services/sheets_service.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_widgets.dart';

class AdminSheetDetailPage extends StatefulWidget {
  const AdminSheetDetailPage({super.key, required this.sheetId});

  final String sheetId;

  @override
  State<AdminSheetDetailPage> createState() => _AdminSheetDetailPageState();
}

class _AdminSheetDetailPageState extends State<AdminSheetDetailPage> {
  final _sessionStore = SessionStore();
  SheetModel? _sheet;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSheet();
  }

  Future<void> _fetchSheet() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final sheet = await SheetsService.fetchSheetById(
        widget.sheetId,
        token: _sessionStore.token,
      );
      if (!mounted) return;
      if (sheet != null) {
        setState(() {
          _sheet = sheet;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'โหลดรายละเอียดชีตไม่สำเร็จ';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _sheet == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: AdminEmptyStatePage(
          title: 'รายละเอียดชีต',
          icon: Icons.error_outline,
          message: _error ?? 'ไม่พบข้อมูลชีต',
          onRefresh: _fetchSheet,
        ),
      );
    }

    final sheet = _sheet!;
    final statusFlag = sheet.statusFlag;
    final effectiveStatus =
        _effectiveContentStatus(statusFlag, sheet.visibleFlag);
    final statusColor = _contentStatusColor(effectiveStatus);
    final statusLabel = _contentStatusLabel(effectiveStatus);
    final priceLabel = sheet.price == null
        ? 'ฟรี'
        : '฿${sheet.price!.toStringAsFixed(2)}';
    final formattedDate = _formatDateTime(sheet.createdAt);
    final updatedDate = sheet.updatedAt != null
        ? _formatDateTime(sheet.updatedAt!)
        : null;
    final hasCategories =
        sheet.categoryIds != null && sheet.categoryIds!.isNotEmpty;
    final hasKeywords =
        sheet.keywordIds != null && sheet.keywordIds!.isNotEmpty;
    final hasFiles = sheet.files != null && sheet.files!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _fetchSheet,
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sheet.title,
              style: const TextStyle(
                fontFamily: AppFonts.sukhumvit,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AdminColors.text,
              ),
            ),
            if (sheet.description?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                sheet.description!,
                style: const TextStyle(
                  fontFamily: AppFonts.sukhumvit,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AdminColors.muted,
                ),
              ),
            ],
            const SizedBox(height: 24),
            const AdminSectionHeader(title: 'ข้อมูลชีต', subtitle: ''),
            const SizedBox(height: 8),
            AdminCard(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.tag_outlined,
                    label: 'ID',
                    value: sheet.id,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'เจ้าของ',
                    value: sheet.authorName?.isNotEmpty == true
                        ? sheet.authorName!
                        : sheet.authorId,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.star_outline,
                    label: 'คะแนน',
                    value: sheet.rating != null
                        ? sheet.rating!.toStringAsFixed(1)
                        : '-',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.sell_outlined,
                    label: 'ราคา',
                    value: priceLabel,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.flag_outlined,
                    label: 'สถานะ',
                    value: statusLabel,
                    valueColor: statusColor,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.shopping_bag_outlined,
                    label: 'ผู้ซื้อ',
                    value: '${sheet.buyerCount} คน',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'วันที่สร้าง',
                    value: formattedDate,
                  ),
                  if (updatedDate != null) ...[
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.update_outlined,
                      label: 'อัปเดตล่าสุด',
                      value: updatedDate,
                    ),
                  ],
                ],
              ),
            ),
            if (hasFiles) ...[
              const SizedBox(height: 24),
              AdminSectionHeader(
                title: 'ไฟล์',
                subtitle: '${sheet.files!.length} รายการ',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: sheet.files!.map((file) => _FileGridItem(file: file)).toList(),
              ),
            ],
            if (hasCategories || hasKeywords) ...[
              const SizedBox(height: 24),
              const AdminSectionHeader(
                title: 'หมวดหมู่ / คีย์เวิร์ด',
                subtitle: '',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (hasCategories)
                    ...sheet.categoryIds!.map((c) => _LabelChip(text: c)),
                  if (hasKeywords)
                    ...sheet.keywordIds!.map((k) => _LabelChip(text: k)),
                ],
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      title: const Text(
        'รายละเอียดชีต',
        style: TextStyle(
          fontFamily: AppFonts.sukhumvit,
          color: AdminColors.text,
          fontWeight: FontWeight.w800,
        ),
      ),
      centerTitle: true,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AdminColors.muted),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.sukhumvit,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AdminColors.muted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.sukhumvit,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AdminColors.text,
          ),
        ),
      ],
    );
  }
}

class _FileGridItem extends StatelessWidget {
  const _FileGridItem({required this.file});

  final SheetFileModel file;

  bool get _isImage => file.format.toLowerCase().startsWith('image/');

  IconData get _formatIcon {
    final fmt = file.format.toUpperCase();
    if (fmt == 'PDF' || fmt == 'APPLICATION/PDF') return Icons.picture_as_pdf;
    if (fmt == 'DOC' || fmt == 'DOCX' || fmt == 'APPLICATION/Msword' ||
        fmt == 'APPLICATION/VND.OPENXMLFORMATS-OFFICEDOCUMENT.WORDPROCESSINGML.DOCUMENT')
      return Icons.description_outlined;
    if (fmt == 'XLS' || fmt == 'XLSX' ||
        fmt == 'APPLICATION/VND.MS-EXCEL' ||
        fmt == 'APPLICATION/VND.OPENXMLFORMATS-OFFICEDOCUMENT.SPREADSHEETML.SHEET')
      return Icons.table_chart_outlined;
    if (fmt.startsWith('IMAGE/')) return Icons.image_outlined;
    return Icons.insert_drive_file_outlined;
  }

  String get _formatLabel {
    if (_isImage) {
      final parts = file.format.split('/');
      return parts.length > 1 ? parts[1].toUpperCase() : 'IMAGE';
    }
    return file.format.toUpperCase();
  }

  void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  file.fullOriginalUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double itemSize = 130;
    return GestureDetector(
      onTap: _isImage ? () => _showImagePreview(context) : null,
      child: Container(
        width: itemSize,
        height: itemSize + 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: itemSize,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: Container(
                  color: AdminColors.background,
                  child: _isImage
                      ? Image.network(
                          file.fullThumbnailUrl,
                          fit: BoxFit.cover,
                          width: itemSize,
                          height: itemSize,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                          errorBuilder: (_, __, ___) => Icon(
                            _formatIcon,
                            size: 36,
                            color: AdminColors.muted,
                          ),
                        )
                      : Icon(_formatIcon, size: 36, color: AdminColors.primary),
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.sukhumvit,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.text,
                      ),
                    ),
                    Text(
                      file.size,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.sukhumvit,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AdminColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppFonts.sukhumvit,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AdminColors.primary,
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${_two(local.day)}/${_two(local.month)}/${local.year} '
      '${_two(local.hour)}:${_two(local.minute)}';
}

String _two(int value) => value.toString().padLeft(2, '0');

String _contentStatusLabel(StatusFlag status) {
  switch (status) {
    case StatusFlag.PENDING:
      return 'รอตรวจ';
    case StatusFlag.ACTIVE:
      return 'แสดง';
    case StatusFlag.INACTIVE:
      return 'ซ่อน';
    case StatusFlag.SUSPENDED:
      return 'ระงับ';
    case StatusFlag.TERMINATED:
      return 'ยุติ';
  }
}

StatusFlag _effectiveContentStatus(StatusFlag status, bool visibleFlag) {
  if (!visibleFlag && status == StatusFlag.ACTIVE) {
    return StatusFlag.INACTIVE;
  }
  return status;
}

Color _contentStatusColor(StatusFlag status) {
  switch (status) {
    case StatusFlag.PENDING:
      return const Color(0xFFB26A00);
    case StatusFlag.ACTIVE:
      return const Color(0xFF1B7F3A);
    case StatusFlag.INACTIVE:
      return const Color(0xFF4B5563);
    case StatusFlag.SUSPENDED:
      return const Color(0xFFC62828);
    case StatusFlag.TERMINATED:
      return const Color(0xFF7F1D1D);
  }
}
