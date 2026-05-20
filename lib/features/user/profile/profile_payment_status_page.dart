import 'package:flutter/material.dart';

import 'package:hero_app_flutter/core/models/enums.dart';

class ProfilePaymentStatusPage extends StatelessWidget {
  const ProfilePaymentStatusPage({
    super.key,
    required this.status,
    required this.packageTitle,
    required this.price,
    required this.amount,
    this.statusMessages,
    this.summaryLabel = 'แพ็กเกจ',
    this.paymentMethod,
  });

  final PaymentStatus status;
  final String packageTitle;
  final String price;
  final String amount;
  final Map<PaymentStatus, String>? statusMessages;
  final String summaryLabel;
  final String? paymentMethod;

  String? get _displayPaymentMethod {
    if (paymentMethod == null) return null;
    final method = paymentMethod!.toUpperCase();
    if (method == 'WALLET') {
      return 'Wallet';
    }
    if (method == 'PROMPTPAY') {
      return 'พร้อมเพย์';
    }
    return paymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = PaymentStatusViewData.fromStatus(status);
    final currentMessage = statusMessages?[status] ?? currentStatus.message;
    final displayMethod = _displayPaymentMethod;

    return Scaffold(
      key: const Key('profile_payment_status_page'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const Key('payment_status_page_close_button'),
          tooltip: 'ปิด',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.black),
        ),
        title: const Text(
          'สถานะการชำระเงิน',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: currentStatus.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: currentStatus.color.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: currentStatus.color.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      currentStatus.icon,
                      color: currentStatus.color,
                      size: 54,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    status.name,
                    key: Key('payment_current_status_${status.name}'),
                    style: TextStyle(
                      fontSize: 28,
                      color: currentStatus.color,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentMessage,
                    style: const TextStyle(
                      color: Color(0xFF5F5F5F),
                      fontSize: 15,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (displayMethod != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ชำระด้วย $displayMethod',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            _PaymentPackageCard(
              label: summaryLabel,
              packageTitle: packageTitle,
              price: price,
              amount: amount,
            ),
            const SizedBox(height: 24),
            const Text(
              'สถานะทั้งหมด',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...PaymentStatus.values.map(
              (paymentStatus) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PaymentStatusItem(
                  status: paymentStatus,
                  isActive: paymentStatus == status,
                  message: statusMessages?[paymentStatus],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentPackageCard extends StatelessWidget {
  const _PaymentPackageCard({
    required this.label,
    required this.packageTitle,
    required this.price,
    required this.amount,
  });

  final String label;
  final String packageTitle;
  final String price;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  packageTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFF2A5DB9),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusItem extends StatelessWidget {
  const _PaymentStatusItem({
    required this.status,
    required this.isActive,
    this.message,
  });

  final PaymentStatus status;
  final bool isActive;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final viewData = PaymentStatusViewData.fromStatus(status);

    return Container(
      key: Key('payment_status_item_${status.name}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? viewData.color.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? viewData.color.withValues(alpha: 0.35)
              : const Color(0xFFE9E9E9),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: viewData.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(viewData.icon, color: viewData.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.name,
                  style: TextStyle(
                    color: viewData.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message ?? viewData.message,
                  style: const TextStyle(
                    color: Color(0xFF6B6B6B),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            const Icon(Icons.check_circle, color: Color(0xFF2A5DB9)),
        ],
      ),
    );
  }
}

const Map<PaymentStatus, String> topUpPaymentStatusMessages = {
  PaymentStatus.PENDING: 'ระบบได้รับข้อมูลแล้ว กรุณารอการตรวจสอบสลิป',
  PaymentStatus.SUCCESSFUL: 'เติมเงินสำเร็จ ยอดเงินพร้อมใช้งาน',
  PaymentStatus.FAILED: 'เติมเงินไม่สำเร็จ กรุณาตรวจสอบข้อมูลอีกครั้ง',
  PaymentStatus.REFUNDED: 'รายการเติมเงินนี้ได้รับการคืนเงินแล้ว',
};

class PaymentStatusViewData {
  const PaymentStatusViewData({
    required this.color,
    required this.icon,
    required this.message,
  });

  final Color color;
  final IconData icon;
  final String message;

  factory PaymentStatusViewData.fromStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.PENDING:
        return const PaymentStatusViewData(
          color: Color(0xFFE6A700),
          icon: Icons.schedule,
          message: 'ระบบได้รับข้อมูลแล้ว กรุณารอการตรวจสอบสลิป',
        );
      case PaymentStatus.SUCCESSFUL:
        return const PaymentStatusViewData(
          color: Color(0xFF2AB950),
          icon: Icons.check_circle_outline,
          message: 'ชำระเงินสำเร็จ แพ็กเกจของคุณพร้อมใช้งาน',
        );
      case PaymentStatus.FAILED:
        return const PaymentStatusViewData(
          color: Color(0xFFF92A47),
          icon: Icons.error_outline,
          message: 'ชำระเงินไม่สำเร็จ กรุณาตรวจสอบข้อมูลอีกครั้ง',
        );
      case PaymentStatus.REFUNDED:
        return const PaymentStatusViewData(
          color: Color(0xFF2A5DB9),
          icon: Icons.replay_circle_filled_outlined,
          message: 'รายการนี้ได้รับการคืนเงินแล้ว',
        );
    }
  }
}
