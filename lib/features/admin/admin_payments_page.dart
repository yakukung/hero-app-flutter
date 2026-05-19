import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/services/admin_service.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_models.dart';
import 'package:hero_app_flutter/features/admin/admin_payment_detail_page.dart';
import 'package:hero_app_flutter/features/admin/admin_widgets.dart';

class AdminPaymentsPage extends StatefulWidget {
  const AdminPaymentsPage({super.key});

  @override
  State<AdminPaymentsPage> createState() => _AdminPaymentsPageState();
}

class _AdminPaymentsPageState extends State<AdminPaymentsPage> {
  final _sessionStore = SessionStore();
  final Set<String> _updatingIds = <String>{};
  late Future<List<AdminPaymentItem>> _future;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  PaymentStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final next = _fetch();
    setState(() { _future = next; });
    await next;
  }

  Future<List<AdminPaymentItem>> _fetch() async {
    final response =
        await AdminService.fetchPayments(token: _sessionStore.token);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        getErrorMessage(response, fallback: 'โหลดรายการชำระเงินไม่สำเร็จ'),
      );
    }

    final list = getApiList(response.body, const ['payments', 'items', 'data']);
    return list
        .whereType<Map>()
        .map((e) => AdminPaymentItem.fromJson(Map.from(e)))
        .toList();
  }

  Future<bool> _updatePaymentStatus(
    AdminPaymentItem payment,
    PaymentStatus status,
  ) async {
    if (_updatingIds.contains(payment.id)) return false;
    setState(() => _updatingIds.add(payment.id));
    try {
      final response = await AdminService.updatePaymentStatus(
        paymentId: payment.id,
        paymentType: payment.type,
        paymentStatus: status.name,
        token: _sessionStore.token,
      );

      if (!mounted) return false;
      final messenger = ScaffoldMessenger.of(context);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        messenger.showSnackBar(
          SnackBar(content: Text('อัปเดตสถานะเป็น ${status.name} แล้ว')),
        );
        await _refresh();
        return true;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            getErrorMessage(response, fallback: 'อัปเดตสถานะไม่สำเร็จ'),
          ),
        ),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _updatingIds.remove(payment.id));
      }
    }
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
          centerTitle: true,
          title: const Text(
            'การชำระเงิน',
            style: TextStyle(
              fontFamily: AppFonts.sukhumvit,
              color: AdminColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
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
                  labelColor: AdminColors.text,
                  unselectedLabelColor: AdminColors.muted,
                  labelStyle: const TextStyle(
                    fontFamily: AppFonts.sukhumvit,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: AppFonts.sukhumvit,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: Colors.transparent,
                  splashBorderRadius: BorderRadius.circular(999),
                  tabs: const [
                    Tab(text: 'ชีต'),
                    Tab(text: 'เติมเงิน'),
                    Tab(text: 'สมาชิก'),
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
                child: FutureBuilder<List<AdminPaymentItem>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return AdminEmptyStatePage(
                        title: 'การชำระเงิน',
                        icon: Icons.payments_outlined,
                        message: snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        onRefresh: _refresh,
                      );
                    }

                    final allItems =
                        snapshot.data ?? const <AdminPaymentItem>[];
                    if (allItems.isEmpty) {
                      return AdminEmptyStatePage(
                        title: 'การชำระเงิน',
                        icon: Icons.payments_outlined,
                        message: 'ยังไม่มีรายการชำระเงิน',
                        onRefresh: _refresh,
                      );
                    }

                    final filtered = _applyFilters(allItems);

                    return TabBarView(
                      children: [
                        _buildPaymentTab(
                          filtered
                              .where((e) => e.type == 'SHEET_PURCHASE')
                              .toList(),
                        ),
                        _buildPaymentTab(
                          filtered
                              .where((e) => e.type == 'WALLET_TOPUP')
                              .toList(),
                        ),
                        _buildPaymentTab(
                          filtered
                              .where((e) => e.type == 'SUBSCRIPTION')
                              .toList(),
                        ),
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

  List<AdminPaymentItem> _applyFilters(List<AdminPaymentItem> items) {
    var result = items;
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((e) => e.username.toLowerCase().contains(q)).toList();
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
                hintText: 'ค้นหาชื่อผู้ใช้',
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
              itemCount: PaymentStatus.values.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _FilterChip(
                    label: 'ทั้งหมด',
                    selected: _statusFilter == null,
                    onTap: () => setState(() => _statusFilter = null),
                  );
                }
                final status = PaymentStatus.values[index - 1];
                return _FilterChip(
                  label: _statusLabel(status),
                  color: _paymentStatusColor(status),
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

  Widget _buildPaymentTab(List<AdminPaymentItem> items) {
    if (items.isEmpty) {
      return AdminEmptyStatePage(
        title: '',
        icon: Icons.payments_outlined,
        message: 'ยังไม่มีรายการ',
        onRefresh: _refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final payment = items[index];
          final isUpdating = _updatingIds.contains(payment.id);
          return AdminCard(
            onTap: isUpdating
                ? null
                : () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => AdminPaymentDetailPage(
                          payment: payment,
                          onStatusChanged: (status) =>
                              _updatePaymentStatus(payment, status),
                        ),
                      ),
                    );
                  },
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _paymentStatusColor(payment.status)
                          .withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payments_outlined,
                      color: _paymentStatusColor(payment.status),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppFonts.sukhumvit,
                            color: AdminColors.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              payment.amountLabel,
                              style: const TextStyle(
                                fontFamily: AppFonts.sukhumvit,
                                color: AdminColors.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AdminColors.muted,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              payment.typeLabel,
                              style: const TextStyle(
                                fontFamily: AppFonts.sukhumvit,
                                color: AdminColors.muted,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payment.dateLabel,
                          style: const TextStyle(
                            fontFamily: AppFonts.sukhumvit,
                            color: AdminColors.muted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminStatusPill(
                    label: payment.statusLabel,
                    color: _paymentStatusColor(payment.status),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _paymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.PENDING:
        return AdminColors.warning;
      case PaymentStatus.SUCCESSFUL:
        return AdminColors.success;
      case PaymentStatus.FAILED:
        return AdminColors.danger;
      case PaymentStatus.REFUNDED:
        return AdminColors.muted;
    }
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

String _statusLabel(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.PENDING:
      return 'รอตรวจ';
    case PaymentStatus.SUCCESSFUL:
      return 'สำเร็จ';
    case PaymentStatus.FAILED:
      return 'ไม่ผ่าน';
    case PaymentStatus.REFUNDED:
      return 'คืนเงิน';
  }
}
