import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/services/admin_service.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_models.dart';
import 'package:hero_app_flutter/features/admin/admin_widgets.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  final _sessionStore = SessionStore();
  late Future<List<AdminReportItem>> _reportsFuture;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ReportStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _fetchReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<AdminReportItem>> _fetchReports() async {
    final response = await AdminService.fetchReports(token: _sessionStore.token);
    if (response.statusCode != 200) {
      throw Exception(
        getErrorMessage(response, fallback: 'โหลดรายงานไม่สำเร็จ'),
      );
    }

    return getApiList(response.body, const ['reports', 'items', 'data'])
        .whereType<Map>()
        .map((item) => AdminReportItem.fromJson(Map.from(item)))
        .toList();
  }

  Future<void> _refresh() async {
    final nextReportsFuture = _fetchReports();
    setState(() {
      _reportsFuture = nextReportsFuture;
    });
    await nextReportsFuture;
  }

  Future<void> _updateStatus(AdminReportItem report, ReportStatus status) async {
    final response = await AdminService.updateReportStatus(
      reportId: report.id,
      referenceTable: report.referenceTable,
      statusFlag: status.name,
      token: _sessionStore.token,
    );

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (_isOkResponse(response.statusCode)) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('อัปเดตรายงานเป็น ${_reportStatusLabel(status)} แล้ว'),
        ),
      );
      await _refresh();
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          getErrorMessage(response, fallback: 'อัปเดตรายงานไม่สำเร็จ'),
        ),
      ),
    );
  }

  Future<void> _runAction(AdminReportItem report, String action) async {
    final response = await AdminService.submitReportAction(
      reportId: report.id,
      referenceTable: report.referenceTable,
      action: action,
      token: _sessionStore.token,
    );

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (_isOkResponse(response.statusCode)) {
      messenger.showSnackBar(
        SnackBar(content: Text('ดำเนินการ ${_reportActionLabel(action)} แล้ว')),
      );
      await _refresh();
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          getErrorMessage(response, fallback: 'ดำเนินการกับรายงานไม่สำเร็จ'),
        ),
      ),
    );
  }

  List<AdminReportItem> _reportsForTable(List<AdminReportItem> reports, String table) {
    return reports.where((r) => r.referenceTable == table).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AdminColors.background,
        appBar: AppBar(
          backgroundColor: AdminColors.background,
          surfaceTintColor: AdminColors.background,
          elevation: 0,
          title: const Text(
            'แจ้งปัญหา',
            style: TextStyle(
              color: AdminColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AdminColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: const Color(0xFF1A1A1A),
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: Colors.transparent,
                  splashBorderRadius: BorderRadius.circular(999),
                  tabs: const [
                    Tab(text: 'ชีต'),
                    Tab(text: 'โพสต์'),
                    Tab(text: 'โปรไฟล์'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: FutureBuilder<List<AdminReportItem>>(
                  future: _reportsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return AdminEmptyStatePage(
                        title: 'แจ้งปัญหา',
                        icon: Icons.error_outline,
                        message: snapshot.error.toString().replaceFirst('Exception: ', ''),
                        onRefresh: _refresh,
                      );
                    }

                    final reports = snapshot.data ?? const <AdminReportItem>[];
                    if (reports.isEmpty) {
                      return AdminEmptyStatePage(
                        title: 'แจ้งปัญหา',
                        icon: Icons.report_problem_outlined,
                        message: 'ยังไม่มีรายงานแจ้งปัญหา',
                        onRefresh: _refresh,
                      );
                    }

                    final sheetReports = _reportsForTable(reports, 'sheets');
                    final postReports = _reportsForTable(reports, 'posts');
                    final userReports = _reportsForTable(reports, 'users');

                    return TabBarView(
                      children: [
                        _buildReportTab(sheetReports, 'sheets'),
                        _buildReportTab(postReports, 'posts'),
                        _buildReportTab(userReports, 'users'),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<AdminReportItem> _applyFilters(List<AdminReportItem> items) {
    var result = items;
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((e) =>
        e.reporterName.toLowerCase().contains(q) ||
        e.referenceId.toLowerCase().contains(q) ||
        e.content.toLowerCase().contains(q)
      ).toList();
    }
    if (_statusFilter != null) {
      result = result.where((e) => e.status == _statusFilter).toList();
    }
    return result;
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
                hintText: 'ค้นหาผู้รายงาน หรือ ID เนื้อหา',
                hintStyle: const TextStyle(
                  fontFamily: AppFonts.sukhumvit,
                  color: AdminColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 8),
                  child: Icon(Icons.search_rounded, size: 22, color: AdminColors.muted),
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
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ReportStatus.values.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _FilterChip(
                    label: 'ทั้งหมด',
                    selected: _statusFilter == null,
                    onTap: () => setState(() => _statusFilter = null),
                  );
                }
                final status = ReportStatus.values[index - 1];
                return _FilterChip(
                  label: _reportStatusLabel(status),
                  color: _reportStatusColor(status),
                  selected: _statusFilter == status,
                  onTap: () => setState(() => _statusFilter = status),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildReportTab(List<AdminReportItem> reports, String table) {
    final filtered = _applyFilters(reports);
    if (filtered.isEmpty) {
      return AdminEmptyStatePage(
        title: '',
        icon: Icons.report_problem_outlined,
        message: table == 'sheets'
            ? 'ไม่มีรายงานชีต'
            : table == 'posts'
                ? 'ไม่มีรายงานโพสต์'
                : 'ไม่มีรายงานโปรไฟล์',
        onRefresh: _refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final report = filtered[index];
          return _AdminReportCard(
            report: report,
            onStatusSelected: (status) => _updateStatus(report, status),
            onActionSelected: (action) => _runAction(report, action),
          );
        },
      ),
    );
  }
}

class _AdminReportCard extends StatelessWidget {
  const _AdminReportCard({
    required this.report,
    required this.onStatusSelected,
    required this.onActionSelected,
  });

  final AdminReportItem report;
  final ValueChanged<ReportStatus> onStatusSelected;
  final ValueChanged<String> onActionSelected;

  void _openDetail(BuildContext context) {
    final reporter = report.reporterName.isEmpty
        ? report.reporterId
        : '${report.reporterName} (${report.reporterId})';

    Widget? refCard;
    final ref = report.referenceData;
    if (ref != null && ref.isNotEmpty) {
      if (report.referenceTable == 'sheets') {
        refCard = AdminCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ข้อมูลชีต',
                  style: TextStyle(
                    fontFamily: AppFonts.sukhumvit,
                    color: AdminColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailRow(label: 'ชื่อ', value: (ref['title'] ?? '-').toString()),
                const SizedBox(height: 8),
                _DetailRow(label: 'ราคา', value: (ref['price'] ?? '-').toString()),
                const SizedBox(height: 8),
                _DetailRow(label: 'ผู้สร้าง', value: (ref['author_name'] ?? ref['author_id'] ?? '-').toString()),
                const SizedBox(height: 8),
                _DetailRow(label: 'สถานะ', value: _refStatusLabel(ref['status_flag']?.toString())),
              ],
            ),
          ),
        );
      } else if (report.referenceTable == 'posts') {
        refCard = AdminCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ข้อมูลโพสต์',
                  style: TextStyle(
                    fontFamily: AppFonts.sukhumvit,
                    color: AdminColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                if ((ref['content'] ?? '').toString().isNotEmpty) ...[
                  _DetailRow(label: 'เนื้อหา', value: (ref['content'] ?? '-').toString()),
                  const SizedBox(height: 8),
                ],
                _DetailRow(label: 'ผู้เขียน', value: (ref['author_name'] ?? ref['author_id'] ?? '-').toString()),
                const SizedBox(height: 8),
                _DetailRow(label: 'สถานะ', value: _refStatusLabel(ref['status_flag']?.toString())),
              ],
            ),
          ),
        );
      } else if (report.referenceTable == 'users') {
        refCard = AdminCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ข้อมูลผู้ใช้',
                  style: TextStyle(
                    fontFamily: AppFonts.sukhumvit,
                    color: AdminColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailRow(label: 'ชื่อผู้ใช้', value: (ref['username'] ?? '-').toString()),
                const SizedBox(height: 8),
                _DetailRow(label: 'อีเมล', value: (ref['email'] ?? '-').toString()),
                const SizedBox(height: 8),
                _DetailRow(label: 'สถานะ', value: _refStatusLabel(ref['status_flag']?.toString())),
              ],
            ),
          ),
        );
      }
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: AdminColors.background,
          appBar: AppBar(
            backgroundColor: AdminColors.background,
            surfaceTintColor: AdminColors.background,
            elevation: 0,
            centerTitle: true,
            title: Text(
              '${report.targetLabel} #${report.referenceId}',
              style: const TextStyle(
                fontFamily: AppFonts.sukhumvit,
                color: AdminColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: AdminColors.text,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  AdminCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${report.targetLabel} #${report.referenceId}',
                                      style: const TextStyle(
                                        fontFamily: AppFonts.sukhumvit,
                                        color: AdminColors.text,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AdminStatusPill(
                                      label: _reportStatusLabel(report.status),
                                      color: _reportStatusColor(report.status),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(label: 'ประเภท', value: report.type.displayName),
                          const SizedBox(height: 12),
                          _DetailRow(label: 'ตารางอ้างอิง', value: report.targetLabel),
                          const SizedBox(height: 12),
                          _DetailRow(label: 'ID อ้างอิง', value: report.referenceId),
                          const SizedBox(height: 12),
                          _DetailRow(label: 'ผู้รายงาน', value: reporter),
                          const SizedBox(height: 12),
                          _DetailRow(label: 'วันที่', value: _formatDateTime(report.createdAt)),
                          if (report.content.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            const Text(
                              'เนื้อหารายงาน',
                              style: TextStyle(
                                fontFamily: AppFonts.sukhumvit,
                                color: AdminColors.text,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AdminColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                report.content,
                                style: const TextStyle(
                                  fontFamily: AppFonts.sukhumvit,
                                  color: AdminColors.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (refCard != null) ...[
                    const SizedBox(height: 16),
                    refCard,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _refStatusLabel(String? status) {
    if (status == null) return '-';
    switch (status.toUpperCase()) {
      case 'ACTIVE': return 'ปกติ';
      case 'INACTIVE': return 'ซ่อน';
      case 'SUSPENDED': return 'ระงับ';
      case 'TERMINATED': return 'ปิดถาวร';
      case 'PENDING': return 'รอตรวจ';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _reportStatusColor(report.status);
    final actions = _reportActionsForTable(report.referenceTable);

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Material(
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
                        '${report.targetLabel} #${report.referenceId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.content.isEmpty ? '-' : report.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AdminStatusPill(
                  label: _reportStatusLabel(report.status),
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                AdminInfoText(icon: Icons.flag_outlined, text: report.type.displayName),
                AdminInfoText(
                  icon: Icons.person_outline,
                  text: report.reporterName.isEmpty
                      ? report.reporterId
                      : report.reporterName,
                ),
                AdminInfoText(
                  icon: Icons.schedule_outlined,
                  text: _formatDateTime(report.createdAt),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PopupMenuButton<ReportStatus>(
                    tooltip: 'เปลี่ยนสถานะรายงาน',
                    onSelected: onStatusSelected,
                    itemBuilder: (context) => [
                      for (final status in ReportStatus.values)
                        PopupMenuItem(
                          value: status,
                          child: _ReportStatusMenuItem(status: status),
                        ),
                    ],
                    child: IgnorePointer(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_note_outlined),
                        label: const Text('สถานะ'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PopupMenuButton<String>(
                    tooltip: 'ดำเนินการกับเนื้อหา',
                    onSelected: onActionSelected,
                    itemBuilder: (context) => [
                      for (final action in actions)
                        PopupMenuItem(
                          value: action,
                          child: Text(_reportActionLabel(action)),
                        ),
                    ],
                    child: IgnorePointer(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        label: const Text('จัดการ'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.sukhumvit,
              color: AdminColors.muted,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: AppFonts.sukhumvit,
              color: AdminColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportStatusMenuItem extends StatelessWidget {
  const _ReportStatusMenuItem({required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _reportStatusColor(status);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(_reportStatusLabel(status))),
      ],
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

String _reportStatusLabel(ReportStatus status) {
  switch (status) {
    case ReportStatus.PENDING:
      return 'รอตรวจ';
    case ReportStatus.RESOLVED:
      return 'จัดการแล้ว';
    case ReportStatus.REJECTED:
      return 'ปฏิเสธ';
  }
}

Color _reportStatusColor(ReportStatus status) {
  switch (status) {
    case ReportStatus.PENDING:
      return const Color(0xFFB26A00);
    case ReportStatus.RESOLVED:
      return const Color(0xFF1B7F3A);
    case ReportStatus.REJECTED:
      return const Color(0xFFC62828);
  }
}

List<String> _reportActionsForTable(String referenceTable) {
  if (referenceTable == 'users') {
    return const ['ACTIVE', 'SUSPEND_TEMPORARY', 'SUSPEND_PERMANENT'];
  }
  return const ['HIDE', 'RESTORE'];
}

String _reportActionLabel(String action) {
  switch (action) {
    case 'ACTIVE':
      return 'ใช้งาน';
    case 'HIDE':
      return 'ซ่อน';
    case 'RESTORE':
      return 'แสดง';
    case 'SUSPEND_TEMPORARY':
      return 'ระงับบัญชีชั่วคราว';
    case 'SUSPEND_PERMANENT':
      return 'ระงับบัญชีถาวร';
    default:
      return action;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? (color ?? AdminColors.primary) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: selected
              ? Border.all(
                  color: (color ?? AdminColors.primary).withValues(alpha: 0.3),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.sukhumvit,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AdminColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
