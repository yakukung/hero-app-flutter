import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/payment_history_model.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
import 'package:hero_app_flutter/core/services/payment_service.dart';
import 'package:hero_app_flutter/features/user/profile/profile_payment_status_page.dart';
import 'package:hero_app_flutter/shared/widgets/custom_dialog.dart';

typedef PickSlipImage = Future<XFile?> Function();
typedef PaymentConfirmed = Future<void> Function(PaymentStatus status);
typedef SubmitSlipPayment =
    Future<ServiceResult<PaymentStatus>> Function(XFile slipImage);
typedef FetchSubscriptionPlans =
    Future<ServiceResult<List<SubscriptionPlanModel>>> Function();

class ProfileSubscription extends StatefulWidget {
  const ProfileSubscription({
    super.key,
    this.pickSlipImage,
    this.submitPayment,
    this.fetchPlans,
    this.plans,
  });

  final PickSlipImage? pickSlipImage;
  final SubmitSlipPayment? submitPayment;
  final FetchSubscriptionPlans? fetchPlans;
  final List<SubscriptionPlanModel>? plans;

  @override
  State<ProfileSubscription> createState() => _ProfileSubscriptionState();
}

class _ProfileSubscriptionState extends State<ProfileSubscription> {
  static const List<SubscriptionPlanModel> _fallbackPlans = [
    SubscriptionPlanModel(
      id: '',
      title: 'รายเดือน',
      price: 79,
      intervalLabel: 'MONTH',
      intervalCount: 1,
    ),
    SubscriptionPlanModel(
      id: '',
      title: 'ราย 3 เดือน',
      price: 229,
      intervalLabel: 'MONTH',
      intervalCount: 3,
      description: 'ประหยัดลง 8 บาท เมื่อเทียบกับรายเดือน',
    ),
    SubscriptionPlanModel(
      id: '',
      title: 'รายปี',
      price: 879,
      intervalLabel: 'YEAR',
      intervalCount: 1,
      description:
          'ประหยัดลง 69 บาท เมื่อเทียบกับรายเดือน\nประหยัดลง 37 บาท เมื่อเทียบกับราย3เดือน',
    ),
  ];

  late List<SubscriptionPlanModel> _plans;
  bool _isLoadingPlans = false;

  @override
  void initState() {
    super.initState();
    _plans = widget.plans ?? _fallbackPlans;
    if (widget.plans == null && widget.fetchPlans != null) {
      _loadPlans();
    }
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoadingPlans = true);
    final result = await widget.fetchPlans!.call();
    if (!mounted) {
      return;
    }
    final plans = result.data ?? const <SubscriptionPlanModel>[];
    setState(() {
      _isLoadingPlans = false;
      if (result.success && plans.isNotEmpty) {
        _plans = plans;
      }
    });
  }

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
          const SizedBox(height: 12),
          Container(
            key: const Key('subscription_drag_handle'),
            width: 52,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'แพ็กเกจสมาชิกพรีเมียม',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  if (_isLoadingPlans)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: LinearProgressIndicator(minHeight: 3),
                    ),
                  for (final plan in _plans) ...[
                    _PackageCard(
                      title: plan.title,
                      price: _formatPlanPrice(plan),
                      amount: plan.amountLabel,
                      subtitles: _planSubtitles(plan),
                      buttonText: 'สมัคร ${plan.amountLabel}',
                      onPay: () => _showPaymentMethod(context, plan: plan),
                    ),
                    const SizedBox(height: 16),
                  ],
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
    required SubscriptionPlanModel plan,
  }) {
    final subscriptionContext = context;
    final price = _formatPlanPrice(plan);
    final amount = plan.amountLabel;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ProfilePaymentSheet(
          packageTitle: plan.title,
          price: price,
          amount: amount,
          pickSlipImage: widget.pickSlipImage,
          submitPayment:
              widget.submitPayment ??
              (slipImage) => PaymentService.subscribe(
                packageTitle: plan.title,
                planId: plan.id,
                amount: plan.price,
                slipImage: File(slipImage.path),
              ),
          onPaymentConfirmed: (status) => _completePaymentFlow(
            subscriptionContext,
            status: status,
            packageTitle: plan.title,
            price: price,
            amount: amount,
          ),
        );
      },
    );
  }

  void _showPaymentMethod(
    BuildContext context, {
    required SubscriptionPlanModel plan,
  }) {
    final appController = Get.find<AppController>();
    if (appController.subscriptionStatus.value?.isPremium == true) {
      showCustomDialog(
        title: 'คุณเป็นสมาชิกพรีเมียมอยู่แล้ว',
        message: 'คุณสามารถใช้งานพรีเมียมต่อไปได้จนกว่าสมาชิกจะหมดอายุ',
      );
      return;
    }

    if (plan.id.isEmpty) {
      showCustomDialog(
        title: 'ไม่สามารถสมัครได้',
        message: 'ไม่พบข้อมูลแผนการสมัคร กรุณาลองใหม่อีกครั้ง',
        isDanger: true,
      );
      return;
    }

    showCustomDialog(
      title: 'เลือกวิธีชำระเงิน',
      message: '${plan.title} ${plan.amountLabel}',
      customActions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A5DB9),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Get.back();
                _payWithWallet(context, plan: plan);
              },
              icon: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
              ),
              label: const Text(
                'ชำระด้วย Wallet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2A5DB9),
                side: const BorderSide(color: Color(0xFF2A5DB9)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Get.back();
                _openPaymentSheet(context, plan: plan);
              },
              icon: const Icon(Icons.qr_code_2_outlined),
              label: const Text(
                'ชำระด้วยพร้อมเพย์',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _payWithWallet(
    BuildContext context, {
    required SubscriptionPlanModel plan,
  }) async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
    if (navigator.canPop()) navigator.pop();

    final result = await PaymentService.subscribePremium(planId: plan.id);
    if (!context.mounted) return;

    if (result.success) {
      await Get.find<AppController>().refreshSubscriptionStatus();
      await Get.find<AppController>().fetchUserData();
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (_) => ProfilePaymentStatusPage(
            status: PaymentStatus.SUCCESSFUL,
            packageTitle: plan.title,
            price: _formatPlanPrice(plan),
            amount: plan.amountLabel,
            paymentMethod: 'Wallet',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  Future<void> _completePaymentFlow(
    BuildContext context, {
    required PaymentStatus status,
    required String packageTitle,
    required String price,
    required String amount,
  }) async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
    if (navigator.canPop()) {
      navigator.pop();
    }

    await navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => ProfilePaymentStatusPage(
          status: status,
          packageTitle: packageTitle,
          price: price,
          amount: amount,
          paymentMethod: 'พร้อมเพย์',
        ),
      ),
    );
  }
}

String _formatPlanPrice(SubscriptionPlanModel plan) {
  final String interval = plan.intervalLabel.toUpperCase();
  String suffix;
  switch (interval) {
    case 'DAY':
      suffix = plan.intervalCount > 1 ? '/${plan.intervalCount} วัน' : '/วัน';
      break;
    case 'WEEK':
      suffix =
          plan.intervalCount > 1 ? '/${plan.intervalCount} สัปดาห์' : '/สัปดาห์';
      break;
    case 'YEAR':
      suffix = plan.intervalCount > 1 ? '/${plan.intervalCount} ปี' : '/ปี';
      break;
    default:
      suffix = plan.intervalCount > 1 ? '/${plan.intervalCount}เดือน' : '/เดือน';
      break;
  }
  return '${plan.amountLabel}$suffix';
}

List<String>? _planSubtitles(SubscriptionPlanModel plan) {
  final description = plan.description;
  if (description == null || description.trim().isEmpty) {
    return null;
  }
  return description
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
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
    this.submitPayment,
    this.onPaymentConfirmed,
  });

  final String packageTitle;
  final String price;
  final String amount;
  final PickSlipImage? pickSlipImage;
  final SubmitSlipPayment? submitPayment;
  final PaymentConfirmed? onPaymentConfirmed;

  @override
  State<ProfilePaymentSheet> createState() => _ProfilePaymentSheetState();
}

class _ProfilePaymentSheetState extends State<ProfilePaymentSheet> {
  final ImagePicker _picker = ImagePicker();
  XFile? _slipImage;
  String? _slipErrorMessage;
  bool _isSubmitting = false;

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
    final slipImage = _slipImage;
    if (slipImage == null || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _slipErrorMessage = null;
    });

    var status = PaymentStatus.PENDING;
    final submitPayment = widget.submitPayment;
    if (submitPayment != null) {
      final result = await submitPayment(slipImage);
      if (!mounted) {
        return;
      }
      if (!result.success) {
        setState(() {
          _isSubmitting = false;
          _slipErrorMessage = result.message;
        });
        return;
      }
      status = result.data ?? PaymentStatus.PENDING;
    }

    final onPaymentConfirmed = widget.onPaymentConfirmed;
    if (onPaymentConfirmed != null) {
      await onPaymentConfirmed(status);
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProfilePaymentStatusPage(
          status: status,
          packageTitle: widget.packageTitle,
          price: widget.price,
          amount: widget.amount,
          paymentMethod: 'พร้อมเพย์',
        ),
      ),
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
                  onPressed: _slipImage == null || _isSubmitting
                      ? null
                      : _confirmPayment,
                  child: Text(
                    _isSubmitting ? 'กำลังส่งสลิป...' : 'ยืนยันชำระเงิน',
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
