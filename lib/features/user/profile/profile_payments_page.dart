import 'package:flutter/material.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
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
}

class ProfilePaymentsPage extends StatelessWidget {
  const ProfilePaymentsPage({super.key, this.payments});

  final List<ProfilePaymentHistoryItem>? payments;

  List<ProfilePaymentHistoryItem> get _payments =>
      payments ?? _mockPaymentHistory;

  @override
  Widget build(BuildContext context) {
    final paymentItems = _payments;

    return Scaffold(
      key: const Key('profile_payments_page'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('รายการชำระเงินทั้งหมดของคุณ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: paymentItems.isEmpty
          ? const Center(
              child: Text(
                'ยังไม่มีรายการชำระเงิน',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: paymentItems.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'ทั้งหมด ${paymentItems.length} รายการ',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                final payment = paymentItems[index - 1];
                return _PaymentHistoryCard(payment: payment);
              },
            ),
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

String _formatDateTime(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

final List<ProfilePaymentHistoryItem> _mockPaymentHistory = [
  ProfilePaymentHistoryItem(
    id: 'mock-payment-001',
    packageTitle: 'รายเดือน',
    price: '฿79.00/เดือน',
    amount: '฿79.00',
    status: PaymentStatus.PENDING,
    createdAt: DateTime(2026, 5, 5, 16, 48),
    reference: 'REF-PM-001',
  ),
  ProfilePaymentHistoryItem(
    id: 'mock-payment-002',
    packageTitle: 'ราย 3 เดือน',
    price: '฿229.00/3เดือน',
    amount: '฿229.00',
    status: PaymentStatus.SUCCESSFUL,
    createdAt: DateTime(2026, 4, 28, 10, 15),
    reference: 'REF-PM-002',
  ),
  ProfilePaymentHistoryItem(
    id: 'mock-payment-003',
    packageTitle: 'รายปี',
    price: '฿879.00/ปี',
    amount: '฿879.00',
    status: PaymentStatus.FAILED,
    createdAt: DateTime(2026, 4, 20, 13, 30),
    reference: 'REF-PM-003',
  ),
  ProfilePaymentHistoryItem(
    id: 'mock-payment-004',
    packageTitle: 'รายเดือน',
    price: '฿79.00/เดือน',
    amount: '฿79.00',
    status: PaymentStatus.REFUNDED,
    createdAt: DateTime(2026, 3, 30, 9, 5),
    reference: 'REF-PM-004',
  ),
];
