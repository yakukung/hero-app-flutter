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
  late PaymentStatus _selectedStatus = widget.payment.status;
  bool _isSaving = false;

  Future<void> _saveStatus() async {
    if (_selectedStatus == widget.payment.status || _isSaving) return;

    setState(() => _isSaving = true);
    final updated = await widget.onStatusChanged(_selectedStatus);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (updated) {
      Navigator.of(context).pop();
    }
  }

  Color _statusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.PENDING:
        return const Color(0xFFB26A00);
      case PaymentStatus.SUCCESSFUL:
        return const Color(0xFF1B7F3A);
      case PaymentStatus.FAILED:
        return const Color(0xFFC62828);
      case PaymentStatus.REFUNDED:
        return const Color(0xFF4B5563);
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
    final canSave = _selectedStatus != payment.status && !_isSaving;
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: statusColor,
                          size: 24,
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
                      AdminStatusPill(
                        label: payment.statusLabel,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withValues(alpha: 0.08),
                          statusColor.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.15),
                      ),
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
                        border: Border.all(color: AdminColors.border),
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
                                errorBuilder: (_, __, ___) => const Center(
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
                  const SizedBox(height: 20),
                  const Text(
                    'เปลี่ยนสถานะ',
                    style: TextStyle(
                      fontFamily: AppFonts.sukhumvit,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...PaymentStatus.values.map((status) {
                    final isSelected = status == _selectedStatus;
                    final sColor = _statusColor(status);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? sColor.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? sColor.withValues(alpha: 0.3)
                                : AdminColors.border,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _isSaving
                              ? null
                              : () => setState(() => _selectedStatus = status),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? sColor
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? sColor
                                          : AdminColors.border,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _paymentStatusLabel(status),
                                    style: TextStyle(
                                      fontFamily: AppFonts.sukhumvit,
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? sColor
                                          : AdminColors.text,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AdminColors.border)),
                color: Colors.white,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: canSave ? _saveStatus : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AdminColors.success,
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text(
                    'บันทึก',
                    style: TextStyle(fontFamily: AppFonts.sukhumvit),
                  ),
                ),
              ),
            ),
          ),
        ],
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
