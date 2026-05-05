import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hero_app_flutter/core/models/enums.dart';

typedef PickSlipImage = Future<XFile?> Function();

class ProfileSubscriptionSheet extends StatelessWidget {
  const ProfileSubscriptionSheet({super.key, this.pickSlipImage});

  final PickSlipImage? pickSlipImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'แพ็กเกจสมาชิกพรีเมียม',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _PackageCard(
                    title: 'รายเดือน',
                    price: '฿79.00/เดือน',
                    amount: '฿79.00',
                    buttonText: 'ชำระเงินในราคา ฿79.00',
                    onPay: () => _openPaymentSheet(
                      context,
                      packageTitle: 'รายเดือน',
                      price: '฿79.00/เดือน',
                      amount: '฿79.00',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PackageCard(
                    title: 'ราย 3 เดือน',
                    price: '฿229.00/3เดือน',
                    amount: '฿229.00',
                    subtitles: const ['ประหยัดลง 8 บาท เมื่อเทียบกับรายเดือน'],
                    buttonText: 'ชำระเงินในราคา ฿229.00',
                    onPay: () => _openPaymentSheet(
                      context,
                      packageTitle: 'ราย 3 เดือน',
                      price: '฿229.00/3เดือน',
                      amount: '฿229.00',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PackageCard(
                    title: 'รายปี',
                    price: '฿879.00/ปี',
                    amount: '฿879.00',
                    subtitles: const [
                      'ประหยัดลง 69 บาท เมื่อเทียบกับรายเดือน',
                      'ประหยัดลง 37 บาท เมื่อเทียบกับราย3เดือน',
                    ],
                    buttonText: 'ชำระเงินในราคา ฿879.00',
                    onPay: () => _openPaymentSheet(
                      context,
                      packageTitle: 'รายปี',
                      price: '฿879.00/ปี',
                      amount: '฿879.00',
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPaymentSheet(
    BuildContext context, {
    required String packageTitle,
    required String price,
    required String amount,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProfilePaymentSheet(
          packageTitle: packageTitle,
          price: price,
          amount: amount,
          pickSlipImage: pickSlipImage,
        );
      },
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.title,
    required this.price,
    required this.amount,
    this.subtitles,
    required this.buttonText,
    required this.onPay,
  });

  final String title;
  final String price;
  final String amount;
  final List<String>? subtitles;
  final String buttonText;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (subtitles != null && subtitles!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...subtitles!.map(
              (text) => Text(
                text,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              key: Key('subscription_pay_$amount'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A5DB9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: onPay,
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePaymentSheet extends StatefulWidget {
  const ProfilePaymentSheet({
    super.key,
    required this.packageTitle,
    required this.price,
    required this.amount,
    this.pickSlipImage,
  });

  final String packageTitle;
  final String price;
  final String amount;
  final PickSlipImage? pickSlipImage;

  @override
  State<ProfilePaymentSheet> createState() => _ProfilePaymentSheetState();
}

class _ProfilePaymentSheetState extends State<ProfilePaymentSheet> {
  final ImagePicker _picker = ImagePicker();
  XFile? _slipImage;
  String? _slipErrorMessage;

  Future<void> _pickSlip() async {
    XFile? image;

    try {
      image =
          await (widget.pickSlipImage?.call() ??
              _picker.pickImage(
                source: ImageSource.gallery,
                requestFullMetadata: false,
              ));
    } on PlatformException {
      _showSlipPickError('ไม่สามารถโหลดรูปนี้ได้ กรุณาเลือกรูปอื่น');
      return;
    } catch (_) {
      _showSlipPickError('ไม่สามารถเลือกรูปนี้ได้ กรุณาเลือกรูปอื่น');
      return;
    }

    if (image == null || !mounted) return;

    setState(() {
      _slipImage = image;
      _slipErrorMessage = null;
    });
  }

  void _showSlipPickError(String message) {
    if (!mounted) return;
    setState(() {
      _slipErrorMessage = message;
    });
  }

  void _removeSlip() {
    setState(() {
      _slipImage = null;
      _slipErrorMessage = null;
    });
  }

  Future<void> _confirmPayment() async {
    if (_slipImage == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const ProfilePaymentStatusDialog(status: PaymentStatus.PENDING);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ชำระเงิน',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _PaymentSummary(
                packageTitle: widget.packageTitle,
                price: widget.price,
                amount: widget.amount,
              ),
              const SizedBox(height: 24),
              const _MockQrCode(),
              const SizedBox(height: 24),
              _SlipAttachmentBox(
                slipImage: _slipImage,
                errorMessage: _slipErrorMessage,
                onPickSlip: _pickSlip,
                onRemoveSlip: _removeSlip,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const Key('payment_confirm_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A5DB9),
                    disabledBackgroundColor: const Color(0xFFB7C8EA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _slipImage == null ? null : _confirmPayment,
                  child: const Text(
                    'ยืนยันชำระเงิน',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({
    required this.packageTitle,
    required this.price,
    required this.amount,
  });

  final String packageTitle;
  final String price;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                  packageTitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF2A5DB9),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MockQrCode extends StatelessWidget {
  const _MockQrCode();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'สแกน QR เพื่อชำระเงิน',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        Container(
          width: 220,
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: CustomPaint(painter: _MockQrPainter()),
        ),
      ],
    );
  }
}

class _MockQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final cell = size.width / 9;
    const filledCells = <int>{
      0,
      1,
      2,
      6,
      7,
      8,
      9,
      11,
      15,
      17,
      18,
      19,
      20,
      24,
      25,
      26,
      30,
      32,
      34,
      36,
      39,
      41,
      43,
      45,
      46,
      48,
      50,
      52,
      54,
      55,
      56,
      60,
      62,
      63,
      65,
      67,
      69,
      71,
      72,
      73,
      74,
      78,
      79,
      80,
    };

    for (final index in filledCells) {
      final x = (index % 9) * cell;
      final y = (index ~/ 9) * cell;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cell * 0.88, cell * 0.88),
          Radius.circular(cell * 0.14),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SlipAttachmentBox extends StatelessWidget {
  const _SlipAttachmentBox({
    required this.slipImage,
    required this.errorMessage,
    required this.onPickSlip,
    required this.onRemoveSlip,
  });

  final XFile? slipImage;
  final String? errorMessage;
  final VoidCallback onPickSlip;
  final VoidCallback onRemoveSlip;

  @override
  Widget build(BuildContext context) {
    final selectedSlip = slipImage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'แนบภาพสลิป',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        if (selectedSlip == null)
          InkWell(
            key: const Key('payment_slip_picker'),
            onTap: onPickSlip,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              height: 136,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE3E3E3)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: Color(0xFF6B6B6B),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'แตะเพื่อแนบภาพสลิป',
                    style: TextStyle(
                      color: Color(0xFF6B6B6B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(selectedSlip.path),
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 88,
                        height: 88,
                        color: const Color(0xFFE3E3E3),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFF6B6B6B),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedSlip.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'เปลี่ยนสลิป',
                  onPressed: onPickSlip,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'ลบสลิป',
                  onPressed: onRemoveSlip,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            key: const Key('payment_slip_error_message'),
            style: const TextStyle(
              color: Color(0xFFF92A47),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class ProfilePaymentStatusDialog extends StatelessWidget {
  const ProfilePaymentStatusDialog({super.key, required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final viewData = _PaymentStatusViewData.fromStatus(status);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 44, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: viewData.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(viewData.icon, color: viewData.color, size: 52),
                ),
                const SizedBox(height: 18),
                const Text(
                  'สถานะการชำระเงิน',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  status.name,
                  key: Key('payment_status_${status.name}'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: viewData.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  viewData.message,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B6B6B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              key: const Key('payment_status_close_button'),
              tooltip: 'ปิด',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusViewData {
  const _PaymentStatusViewData({
    required this.color,
    required this.icon,
    required this.message,
  });

  final Color color;
  final IconData icon;
  final String message;

  factory _PaymentStatusViewData.fromStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.PENDING:
        return const _PaymentStatusViewData(
          color: Color(0xFFE6A700),
          icon: Icons.schedule,
          message: 'ระบบได้รับข้อมูลแล้ว กรุณารอการตรวจสอบสลิป',
        );
      case PaymentStatus.SUCCESSFUL:
        return const _PaymentStatusViewData(
          color: Color(0xFF2AB950),
          icon: Icons.check_circle_outline,
          message: 'ชำระเงินสำเร็จ แพ็กเกจของคุณพร้อมใช้งาน',
        );
      case PaymentStatus.FAILED:
        return const _PaymentStatusViewData(
          color: Color(0xFFF92A47),
          icon: Icons.error_outline,
          message: 'ชำระเงินไม่สำเร็จ กรุณาตรวจสอบข้อมูลอีกครั้ง',
        );
      case PaymentStatus.REFUNDED:
        return const _PaymentStatusViewData(
          color: Color(0xFF2A5DB9),
          icon: Icons.replay_circle_filled_outlined,
          message: 'รายการนี้ได้รับการคืนเงินแล้ว',
        );
    }
  }
}
