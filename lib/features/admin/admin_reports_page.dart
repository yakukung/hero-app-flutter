import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _reportsFuture = _fetchReports();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: FutureBuilder<List<AdminReportItem>>(
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

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            itemCount: reports.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return AdminSectionHeader(
                  title: 'รายงานแจ้งปัญหา',
                  subtitle: '${reports.length} รายการ',
                );
              }

              final report = reports[index - 1];
              return _AdminReportCard(
                report: report,
                onStatusSelected: (status) => _updateStatus(report, status),
                onActionSelected: (action) => _runAction(report, action),
              );
            },
          ),
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _reportStatusColor(report.status);
    final actions = _reportActionsForTable(report.referenceTable);

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
                AdminInfoText(icon: Icons.flag_outlined, text: report.type.name),
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
        Expanded(child: Text('${status.name} - ${_reportStatusLabel(status)}')),
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
    case ReportStatus.REVIEWING:
      return 'กำลังตรวจ';
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
    case ReportStatus.REVIEWING:
      return const Color(0xFF2563EB);
    case ReportStatus.RESOLVED:
      return const Color(0xFF1B7F3A);
    case ReportStatus.REJECTED:
      return const Color(0xFFC62828);
  }
}

List<String> _reportActionsForTable(String referenceTable) {
  if (referenceTable == 'users') {
    return const ['SUSPEND_USER', 'RESTORE'];
  }
  return const ['HIDE', 'RESTORE', 'DELETE'];
}

String _reportActionLabel(String action) {
  switch (action) {
    case 'HIDE':
      return 'ซ่อนเนื้อหา';
    case 'RESTORE':
      return 'กู้คืน/เปิดใช้งาน';
    case 'DELETE':
      return 'ลบ/ปิดเนื้อหา';
    case 'SUSPEND_USER':
      return 'ระงับผู้ใช้';
    default:
      return action;
  }
}
