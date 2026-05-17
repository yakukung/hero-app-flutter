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

  Future<List<AdminPaymentItem>> _fetch() async {
    final response = await AdminService.fetchPayments(token: _sessionStore.token);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(getErrorMessage(response, fallback: 'โหลดรายการชำระเงินไม่สำเร็จ'));
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
          content: Text(getErrorMessage(response, fallback: 'อัปเดตสถานะไม่สำเร็จ')),
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
    return Scaffold(
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
      ),
      body: SafeArea(
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
                message: snapshot.error.toString().replaceFirst('Exception: ', ''),
                onRefresh: _refresh,
              );
            }

            final items = snapshot.data ?? const <AdminPaymentItem>[];
            if (items.isEmpty) {
              return AdminEmptyStatePage(
                title: 'การชำระเงิน',
                icon: Icons.payments_outlined,
                message: 'ยังไม่มีรายการชำระเงิน',
                onRefresh: _refresh,
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _paymentStatusColor(payment.status)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Icon(
                              Icons.payments_outlined,
                              color: _paymentStatusColor(payment.status),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      payment.amountLabel,
                                      style: const TextStyle(
                                        fontFamily: AppFonts.sukhumvit,
                                        color: AdminColors.text,
                                        fontSize: 15,
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
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  payment.dateLabel,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.sukhumvit,
                                    color: AdminColors.muted,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
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
          },
        ),
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
