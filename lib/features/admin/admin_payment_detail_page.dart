import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_models.dart';

class AdminPaymentDetailPage extends StatefulWidget {
  const AdminPaymentDetailPage({
    super.key,
    required this.payment,
    required this.onStatusChanged,
  });

  final AdminPaymentItem payment;
  final Future<bool> Function(PaymentStatus status) onStatusChanged;

  @override
  State<AdminPaymentDetailPage> createState() => _AdminPaymentDetailPageState();
}

class _AdminPaymentDetailPageState extends State<AdminPaymentDetailPage> {
  bool _isSaving = false;

  Color _statusColor(PaymentStatus status) {
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

  String _paymentStatusLabel(PaymentStatus status) {
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

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final statusColor = _statusColor(payment.status);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        surfaceTintColor: AdminColors.background,
        elevation: 0,
        title: Text(
          payment.title,
          style: const TextStyle(
            fontFamily: AppFonts.sukhumvit,
            color: AdminColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เปลี่ยนสถานะ',
              style: TextStyle(
                fontFamily: AppFonts.sukhumvit,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AdminColors.muted,
              ),
            ),
            const SizedBox(height: 6),
            DropdownMenu<PaymentStatus>(
              initialSelection: payment.status,
              expandedInsets: EdgeInsets.zero,
              textStyle: const TextStyle(
                fontFamily: AppFonts.sukhumvit,
                color: AdminColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AdminColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AdminColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: statusColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              trailingIcon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.keyboard_arrow_down_rounded),
              leadingIcon: Icon(Icons.circle, color: statusColor, size: 10),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                elevation: WidgetStateProperty.all(3),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              dropdownMenuEntries: PaymentStatus.values.map((status) {
                final sColor = _statusColor(status);
                return DropdownMenuEntry<PaymentStatus>(
                  value: status,
                  label: _paymentStatusLabel(status),
                  leadingIcon: Icon(Icons.circle, color: sColor, size: 10),
                  style: ButtonStyle(
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(
                        fontFamily: AppFonts.sukhumvit,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onSelected: _isSaving
                  ? null
                  : (value) async {
                      if (value == null || value == payment.status) return;
                      setState(() => _isSaving = true);
                      final updated = await widget.onStatusChanged(value);
                      if (!mounted) return;
                      if (updated) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() => _isSaving = false);
                      }
                    },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: statusColor,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (payment.email.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          payment.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppFonts.sukhumvit,
                            color: AdminColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AdminStatusPill(label: payment.statusLabel, color: statusColor),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withValues(alpha: 0.18),
                    statusColor.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    payment.amountLabel,
                    style: const TextStyle(
                      fontFamily: AppFonts.sukhumvit,
                      color: AdminColors.text,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    payment.typeLabel,
                    style: const TextStyle(
                      fontFamily: AppFonts.sukhumvit,
                      color: AdminColors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.tag,
                    label: 'ID รายการ',
                    value: payment.id,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'UID ผู้ใช้',
                    value: payment.userId,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'วันที่',
                    value: payment.dateLabel,
                  ),
                  if (payment.paymentMethod != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.payment_outlined,
                      label: 'ช่องทางการชำระเงิน',
                      value: payment.paymentMethod == 'PROMPTPAY'
                          ? 'พร้อมเพย์'
                          : payment.paymentMethod == 'WALLET'
                              ? 'Wallet'
                              : payment.paymentMethod!,
                    ),
                  ],
                ],
              ),
            ),
            if (payment.slipImageUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'สลิปโอนเงิน',
                      style: TextStyle(
                        fontFamily: AppFonts.sukhumvit,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 260,
                        width: double.infinity,
                        color: AdminColors.surfaceAlt,
                        child: Image.network(
                          payment.fullSlipImageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AdminColors.muted,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AdminColors.muted),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.sukhumvit,
            color: AdminColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        SelectableText(
          value,
          style: const TextStyle(
            fontFamily: AppFonts.sukhumvit,
            color: AdminColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
