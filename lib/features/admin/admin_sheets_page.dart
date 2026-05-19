import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/models/category_model.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/services/admin_service.dart';
import 'package:hero_app_flutter/core/services/sheets_service.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_sheet_detail_page.dart';
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
  final Map<String, int> _sheetBuyerOverrides = <String, int>{};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  StatusFlag? _statusFilter;
  CategoryModel? _typeFilter;
  List<CategoryModel> _categories = [];
  late Future<List<SheetModel>> _sheetsFuture;

  @override
  void initState() {
    super.initState();
    _sheetsFuture = _fetchSheets();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await SheetsService.fetchCategories(
        token: _sessionStore.token,
      );
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<SheetModel>> _fetchSheets() async {
    final adminResponse = await AdminService.fetchSheets(
      token: _sessionStore.token,
    );
    final Map<String, Map<String, dynamic>> adminDataMap = {};
    if (_isOkResponse(adminResponse.statusCode)) {
      for (final item in getApiList(
        adminResponse.body,
        const ['sheets', 'items', 'data'],
      ).whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        adminDataMap[map['id']?.toString() ?? ''] = map;
      }
    }

    final sheets = await SheetsService.fetchSheets(
      token: _sessionStore.token,
    );

    for (final sheet in sheets) {
      final adminData = adminDataMap[sheet.id];
      if (adminData != null) {
        final buyersCount = adminData['buyers_count'] ?? adminData['buyer_count'];
        if (buyersCount != null) {
          final overrideBuyerCount = int.tryParse(buyersCount.toString()) ?? 0;
          if (overrideBuyerCount > 0) {
            _sheetBuyerOverrides[sheet.id] = overrideBuyerCount;
          }
        }
      }
    }

    return sheets;
  }

  Future<void> _refresh() async {
    final nextSheetsFuture = _fetchSheets();
    setState(() {
      _sheetsFuture = nextSheetsFuture;
    });
    await nextSheetsFuture;
    await _loadCategories();
  }

  List<SheetModel> _applyFilters(List<SheetModel> items) {
    var result = items;
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((e) {
        final titleMatch = e.title.toLowerCase().contains(q);
        final authorMatch =
            e.authorName?.toLowerCase().contains(q) ?? false;
        final categoryMatch = (e.categoryIds ?? [])
            .any((c) => c.toLowerCase().contains(q));
        return titleMatch || authorMatch || categoryMatch;
      }).toList();
    }
    if (_statusFilter != null) {
      final effectiveStatus = _statusFilter!;
      result = result.where((e) {
        final flag = _sheetStatusOverrides[e.id] ?? e.statusFlag;
        return flag == effectiveStatus;
      }).toList();
    }
    if (_typeFilter != null) {
      final selectedName = _typeFilter!.name.trim();
      result = result.where((e) {
        final ids = e.categoryIds;
        if (ids == null || ids.isEmpty) return false;
        return ids.any((c) => c.trim() == selectedName);
      }).toList();
    }
    return result;
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
          final allSheets = snapshot.data ?? const <SheetModel>[];
          final sheets = _applyFilters(allSheets);

          return Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: sheets.isEmpty
                    ? AdminEmptyStatePage(
                        title: 'จัดการชีต',
                        icon: Icons.description_outlined,
                        message: _searchQuery.isNotEmpty ||
                                _statusFilter != null ||
                                _typeFilter != null
                            ? 'ไม่พบชีตที่ตรงกับที่ค้นหา'
                            : 'ยังไม่มีชีตในระบบ',
                        onRefresh: _refresh,
                      )
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                          itemCount: sheets.length + 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 4),
                                child: AdminSectionHeader(
                                  title: 'ชีตทั้งหมด',
                                  subtitle: '${sheets.length} รายการ',
                                ),
                              );
                            }
                            final sheet = sheets[index - 1];
                            final overriddenStatus =
                                _sheetStatusOverrides[sheet.id];
                            final statusFlag =
                                overriddenStatus ?? sheet.statusFlag;
                            final visibleFlag = overriddenStatus == null
                                ? sheet.visibleFlag
                                : overriddenStatus == StatusFlag.ACTIVE;
                            final isVisible = _isContentVisible(
                              statusFlag,
                              visibleFlag,
                            );
                            final displayBuyerCount =
                                _sheetBuyerOverrides[sheet.id] ?? sheet.buyerCount;
                            return _AdminSheetCard(
                              sheet: sheet,
                              statusFlag: statusFlag,
                              visibleFlag: visibleFlag,
                              buyerCount: displayBuyerCount,
                              isUpdating:
                                  _updatingSheetIds.contains(sheet.id),
                              onTap: () => Get.to(
                                () => AdminSheetDetailPage(sheetId: sheet.id),
                              ),
                              onToggleStatus: () => _updateSheetStatus(
                                sheet,
                                isVisible
                                    ? StatusFlag.INACTIVE
                                    : StatusFlag.ACTIVE,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(
                fontFamily: AppFonts.sukhumvit,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AdminColors.text,
              ),
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อชีต, ประเภท, หรือชื่อเจ้าของ',
                hintStyle: const TextStyle(
                  fontFamily: AppFonts.sukhumvit,
                  color: AdminColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 8),
                  child: Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: AdminColors.muted,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: AdminColors.muted,
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: Row(
              children: [
                _FilterLabel(text: 'สถานะชีต'),
                const SizedBox(width: 8),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _FilterChip(
                          label: 'ทั้งหมด',
                          selected: _statusFilter == null,
                          onTap: () => setState(() => _statusFilter = null),
                        );
                      }
                      if (index == 1) {
                        return _FilterChip(
                          label: 'แสดง',
                          color: _contentStatusColor(StatusFlag.ACTIVE),
                          selected: _statusFilter == StatusFlag.ACTIVE,
                          onTap: () => setState(() => _statusFilter = StatusFlag.ACTIVE),
                        );
                      }
                      return _FilterChip(
                        label: 'ซ่อน',
                        color: _contentStatusColor(StatusFlag.INACTIVE),
                        selected: _statusFilter == StatusFlag.INACTIVE,
                        onTap: () => setState(() => _statusFilter = StatusFlag.INACTIVE),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_categories.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  _FilterLabel(text: 'ประเภทชีต'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _FilterChip(
                            label: 'ทุกประเภท',
                            selected: _typeFilter == null,
                            onTap: () => setState(() => _typeFilter = null),
                          );
                        }
                        final cat = _categories[index - 1];
                        return _FilterChip(
                          label: cat.name,
                          selected: _typeFilter?.id == cat.id,
                          onTap: () => setState(() => _typeFilter = cat),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _AdminSheetCard extends StatelessWidget {
  const _AdminSheetCard({
    required this.sheet,
    required this.statusFlag,
    required this.visibleFlag,
    required this.buyerCount,
    required this.isUpdating,
    required this.onToggleStatus,
    this.onTap,
  });

  final SheetModel sheet;
  final StatusFlag statusFlag;
  final bool visibleFlag;
  final int buyerCount;
  final bool isUpdating;
  final VoidCallback onToggleStatus;
  final VoidCallback? onTap;

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
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
                  text: '$buyerCount ผู้ซื้อ',
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

class _FilterLabel extends StatelessWidget {
  const _FilterLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFonts.sukhumvit,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AdminColors.muted.withValues(alpha: 0.8),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AdminColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? chipColor.withValues(alpha: 0.18) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? chipColor.withValues(alpha: 0.4) : AdminColors.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.sukhumvit,
            color: selected ? chipColor : AdminColors.muted,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
