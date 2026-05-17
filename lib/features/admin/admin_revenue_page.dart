import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/services/admin_service.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_models.dart';
import 'package:hero_app_flutter/features/admin/admin_widgets.dart';

class AdminRevenuePage extends StatefulWidget {
  const AdminRevenuePage({super.key});

  @override
  State<AdminRevenuePage> createState() => _AdminRevenuePageState();
}

class _AdminRevenuePageState extends State<AdminRevenuePage> {
  final _sessionStore = SessionStore();
  late Future<AdminRevenueSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<void> _refresh() async {
    final next = _fetch();
    setState(() {
      _future = next;
    });
    await next;
  }

  Future<AdminRevenueSummary> _fetch() async {
    final response = await AdminService.fetchRevenue(token: _sessionStore.token);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(getErrorMessage(response, fallback: 'โหลดข้อมูลรายได้ไม่สำเร็จ'));
    }

    final root = getApiData(response.body);
    if (root is Map<String, dynamic>) {
      return AdminRevenueSummary.fromJson(root);
    }
    return AdminRevenueSummary.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        surfaceTintColor: AdminColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'รายได้',
          style: TextStyle(
            fontFamily: AppFonts.sukhumvit,
            color: AdminColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<AdminRevenueSummary>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return AdminEmptyStatePage(
                title: 'รายได้',
                icon: Icons.analytics_outlined,
                message: snapshot.error.toString().replaceFirst('Exception: ', ''),
                onRefresh: _refresh,
              );
            }

            final data = snapshot.data ?? AdminRevenueSummary.empty();
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  const AdminPageHeader(
                    title: 'รายได้',
                    subtitle: 'ภาพรวมการเงิน',
                    icon: Icons.analytics_outlined,
                  ),
                  const SizedBox(height: 16),
                  AdminCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'สรุป',
                          style: TextStyle(
                            fontFamily: AppFonts.sukhumvit,
                            color: AdminColors.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _KeyValueRow(label: 'ยอดรวม', value: _money(data.grossRevenue)),
                        const SizedBox(height: 6),
                        _KeyValueRow(
                          label: 'ส่วนแบ่ง Creator',
                          value: _money(data.creatorShare),
                        ),
                        const SizedBox(height: 6),
                        _KeyValueRow(
                          label: 'ส่วนแบ่ง Platform',
                          value: _money(data.platformShare),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AdminSectionHeader(
                    title: 'Top ชีต',
                    subtitle: '${data.topSheets.length} รายการ',
                  ),
                  const SizedBox(height: 10),
                  if (data.topSheets.isEmpty)
                    const AdminInlineEmptyState(text: 'ยังไม่มีข้อมูล Top ชีต')
                  else
                    ...data.topSheets.take(10).map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AdminCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.sheetTitle,
                                    style: const TextStyle(
                                      fontFamily: AppFonts.sukhumvit,
                                      color: AdminColors.text,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'โดย ${item.creatorName} • ${item.purchases} ครั้ง',
                                    style: const TextStyle(
                                      fontFamily: AppFonts.sukhumvit,
                                      color: AdminColors.muted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _money(item.gross),
                                    style: const TextStyle(
                                      fontFamily: AppFonts.sukhumvit,
                                      color: AdminColors.success,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 6),
                  AdminSectionHeader(
                    title: 'รายเดือน',
                    subtitle: '${data.monthly.length} เดือน',
                  ),
                  const SizedBox(height: 10),
                  if (data.monthly.isEmpty)
                    const AdminInlineEmptyState(text: 'ยังไม่มีข้อมูลรายเดือน')
                  else
                    ...data.monthly.take(12).map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AdminCard(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      m.month,
                                      style: const TextStyle(
                                        fontFamily: AppFonts.sukhumvit,
                                        color: AdminColors.text,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _money(m.gross),
                                    style: const TextStyle(
                                      fontFamily: AppFonts.sukhumvit,
                                      color: AdminColors.text,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _money(double value) => '฿${value.toStringAsFixed(2)}';
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.sukhumvit,
              color: AdminColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppFonts.sukhumvit,
            color: AdminColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
