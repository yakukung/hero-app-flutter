import 'package:flutter/material.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/services/admin_service.dart';
import 'package:hero_app_flutter/core/services/sheets_service.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_widgets.dart';

class AdminSheetsPage extends StatefulWidget {
  const AdminSheetsPage({super.key});

  @override
  State<AdminSheetsPage> createState() => _AdminSheetsPageState();
}

class _AdminSheetsPageState extends State<AdminSheetsPage> {
  final _sessionStore = SessionStore();
  final Set<String> _updatingSheetIds = <String>{};
  final Map<String, StatusFlag> _sheetStatusOverrides = <String, StatusFlag>{};
  late Future<List<SheetModel>> _sheetsFuture;

  @override
  void initState() {
    super.initState();
    _sheetsFuture = _fetchSheets();
  }

  Future<List<SheetModel>> _fetchSheets() async {
    final response = await AdminService.fetchSheets(token: _sessionStore.token);
    if (_isOkResponse(response.statusCode)) {
      return getApiList(response.body, const ['sheets', 'items', 'data'])
          .whereType<Map>()
          .map((item) => SheetModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (response.statusCode == 404) {
      return SheetsService.fetchSheets(token: _sessionStore.token);
    }
    throw Exception(
      getErrorMessage(response, fallback: 'โหลดรายการชีตไม่สำเร็จ'),
    );
  }

  Future<void> _refresh() async {
    final nextSheetsFuture = _fetchSheets();
    setState(() => _sheetsFuture = nextSheetsFuture);
    await nextSheetsFuture;
  }

  Future<void> _updateSheetStatus(SheetModel sheet, StatusFlag status) async {
    if (_updatingSheetIds.contains(sheet.id)) return;
    setState(() => _updatingSheetIds.add(sheet.id));
    try {
      final response = await AdminService.updateSheetStatus(
        sheetId: sheet.id,
        statusFlag: status.name,
        token: _sessionStore.token,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      if (_isOkResponse(response.statusCode)) {
        setState(() => _sheetStatusOverrides[sheet.id] = status);
        messenger.showSnackBar(
          SnackBar(
            content: Text('อัปเดตชีตเป็น ${_contentStatusLabel(status)} แล้ว'),
          ),
        );
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            getErrorMessage(response, fallback: 'อัปเดตสถานะชีตไม่สำเร็จ'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _updatingSheetIds.remove(sheet.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        surfaceTintColor: AdminColors.background,
        elevation: 0,
        title: const Text(
          'จัดการชีต',
          style: TextStyle(
            color: AdminColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<SheetModel>>(
        future: _sheetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return AdminEmptyStatePage(
              title: 'จัดการชีต',
              icon: Icons.error_outline,
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRefresh: _refresh,
            );
          }
          final sheets = snapshot.data ?? const <SheetModel>[];
          if (sheets.isEmpty) {
            return AdminEmptyStatePage(
              title: 'จัดการชีต',
              icon: Icons.description_outlined,
              message: 'ยังไม่มีชีตในระบบ',
              onRefresh: _refresh,
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
              itemCount: sheets.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return AdminSectionHeader(
                    title: 'ชีตทั้งหมด',
                    subtitle: '${sheets.length} รายการ',
                  );
                }
                final sheet = sheets[index - 1];
                final overriddenStatus = _sheetStatusOverrides[sheet.id];
                final statusFlag = overriddenStatus ?? sheet.statusFlag;
                final visibleFlag = overriddenStatus == null
                    ? sheet.visibleFlag
                    : overriddenStatus == StatusFlag.ACTIVE;
                final isVisible = _isContentVisible(statusFlag, visibleFlag);
                return _AdminSheetCard(
                  sheet: sheet,
                  statusFlag: statusFlag,
                  visibleFlag: visibleFlag,
                  isUpdating: _updatingSheetIds.contains(sheet.id),
                  onToggleStatus: () => _updateSheetStatus(
                    sheet,
                    isVisible ? StatusFlag.INACTIVE : StatusFlag.ACTIVE,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AdminSheetCard extends StatelessWidget {
  const _AdminSheetCard({
    required this.sheet,
    required this.statusFlag,
    required this.visibleFlag,
    required this.isUpdating,
    required this.onToggleStatus,
  });

  final SheetModel sheet;
  final StatusFlag statusFlag;
  final bool visibleFlag;
  final bool isUpdating;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = _effectiveContentStatus(statusFlag, visibleFlag);
    final statusColor = _contentStatusColor(effectiveStatus);
    final isVisible = _isContentVisible(statusFlag, visibleFlag);
    final actionIcon = isUpdating
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(
            isVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          );
    final priceLabel =
        sheet.price == null ? 'ฟรี' : '฿${sheet.price!.toStringAsFixed(2)}';

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AdminColors.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sheet.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (sheet.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          sheet.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AdminStatusPill(
                  label: _contentStatusLabel(effectiveStatus),
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                AdminInfoText(
                  icon: Icons.person_outline,
                  text: sheet.authorName?.isNotEmpty == true
                      ? sheet.authorName!
                      : sheet.authorId,
                ),
                AdminInfoText(icon: Icons.sell_outlined, text: priceLabel),
                AdminInfoText(
                  icon: Icons.shopping_bag_outlined,
                  text: '${sheet.buyerCount} ผู้ซื้อ',
                ),
                AdminInfoText(
                  icon: Icons.schedule_outlined,
                  text: _formatDateTime(sheet.createdAt),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: isVisible
                  ? OutlinedButton.icon(
                      onPressed: isUpdating ? null : onToggleStatus,
                      icon: actionIcon,
                      label: const Text('ซ่อนชีต'),
                    )
                  : FilledButton.icon(
                      onPressed: isUpdating ? null : onToggleStatus,
                      icon: actionIcon,
                      label: const Text('แสดงชีต'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isOkResponse(int statusCode) => statusCode >= 200 && statusCode < 300;

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
      return 'เปิดใช้งาน';
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

bool _isContentVisible(StatusFlag status, bool visibleFlag) {
  return visibleFlag && status == StatusFlag.ACTIVE;
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
