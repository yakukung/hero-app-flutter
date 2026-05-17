import 'package:flutter/material.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/payment_history_model.dart';
import 'package:hero_app_flutter/core/services/payment_service.dart';
import 'package:hero_app_flutter/features/user/profile/profile_payment_status_page.dart';

class ProfilePaymentHistoryItem {
  const ProfilePaymentHistoryItem({
    required this.id,
    required this.packageTitle,
    required this.price,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.reference,
  });

  final String id;
  final String packageTitle;
  final String price;
  final String amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final String reference;

  factory ProfilePaymentHistoryItem.fromServiceModel(PaymentHistoryItem item) {
    return ProfilePaymentHistoryItem(
      id: item.id,
      packageTitle: item.title,
      price: item.priceLabel ?? item.amountLabel,
      amount: item.amountLabel,
      status: item.status,
      createdAt: item.createdAt,
      reference: item.reference,
    );
  }
}

class ProfilePaymentsPage extends StatefulWidget {
  const ProfilePaymentsPage({super.key, this.payments});

  final List<ProfilePaymentHistoryItem>? payments;

  @override
  State<ProfilePaymentsPage> createState() => _ProfilePaymentsPageState();
}

class _ProfilePaymentsPageState extends State<ProfilePaymentsPage> {
  List<ProfilePaymentHistoryItem> _payments = const [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.payments != null) {
      _payments = widget.payments!;
      _isLoading = false;
    } else {
      _loadPayments();
    }
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final result = await PaymentService.fetchPaymentHistory();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _payments = (result.data ?? const [])
          .map(ProfilePaymentHistoryItem.fromServiceModel)
          .toList();
      _errorMessage = result.success ? '' : result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('profile_payments_page'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('รายการชำระเงินทั้งหมดของคุณ'),
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
      return _HistoryStateMessage(
        message: _errorMessage,
        actionLabel: 'ลองใหม่',
        onAction: _loadPayments,
      );
    }

    if (_payments.isEmpty) {
      return const Center(
        child: Text(
          'ยังไม่มีรายการชำระเงิน',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: _payments.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'ทั้งหมด ${_payments.length} รายการ',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return _PaymentHistoryCard(payment: _payments[index - 1]);
      },
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  const _PaymentHistoryCard({required this.payment});

  final ProfilePaymentHistoryItem payment;

  @override
  Widget build(BuildContext context) {
    final statusData = PaymentStatusViewData.fromStatus(payment.status);

    return GestureDetector(
      key: Key('profile_payment_item_${payment.id}'),
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ProfilePaymentStatusPage(
              status: payment.status,
              packageTitle: payment.packageTitle,
              price: payment.price,
              amount: payment.amount,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusData.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(statusData.icon, color: statusData.color, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.packageTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment.reference,
                    style: const TextStyle(
                      color: Color(0xFF6B6B6B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(payment.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF8A8A8A),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _StatusChip(status: payment.status),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  payment.amount,
                  style: const TextStyle(
                    color: Color(0xFF2A5DB9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Icon(Icons.chevron_right, color: Color(0xFF8A8A8A)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final statusData = PaymentStatusViewData.fromStatus(status);

    return Container(
      key: Key('profile_payment_status_chip_${status.name}'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusData.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.name,
        style: TextStyle(
          color: statusData.color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HistoryStateMessage extends StatelessWidget {
  const _HistoryStateMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}
