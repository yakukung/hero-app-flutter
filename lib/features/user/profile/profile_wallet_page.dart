import 'dart:io';

import 'package:flutter/material.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/services/payment_service.dart';
import 'package:hero_app_flutter/features/user/profile/profile_payment_status_page.dart';
import 'package:hero_app_flutter/features/user/profile/profile_top_ups_page.dart';
import 'package:hero_app_flutter/features/user/profile/widgets/profile_subscription.dart';

class ProfileWalletPage extends StatefulWidget {
  const ProfileWalletPage({super.key, this.currentWallet = 0});

  final double currentWallet;

  @override
  State<ProfileWalletPage> createState() => _ProfileWalletPageState();
}

class _ProfileWalletPageState extends State<ProfileWalletPage> {
  static const List<int> _amountOptions = [
    10,
    20,
    30,
    40,
    50,
    100,
    200,
    300,
    500,
  ];

  int _selectedAmount = 0;

  void _selectAmount(int amount) {
    setState(() {
      _selectedAmount = amount;
    });
  }

  void _openPaymentStatus() {
    if (_selectedAmount == 0) {
      return;
    }

    final price = _formatCurrency(_selectedAmount.toDouble());
    final amount = _formatCurrency(_selectedAmount.toDouble());

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ProfilePaymentSheet(
          packageTitle: 'เติมเงินกระเป๋า',
          price: price,
          amount: amount,
          submitPayment: (slipImage) => PaymentService.createTopUp(
            amount: _selectedAmount.toDouble(),
            slipImage: File(slipImage.path),
          ),
          onPaymentConfirmed: (status) => _completePaymentFlow(
            status: status,
            price: price,
            amount: amount,
          ),
        );
      },
    );
  }

  Future<void> _completePaymentFlow({
    required PaymentStatus status,
    required String price,
    required String amount,
  }) async {
    final navigator = Navigator.of(context);
    // Close the payment sheet
    if (navigator.canPop()) {
      navigator.pop();
    }

    await navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => ProfilePaymentStatusPage(
          status: status,
          packageTitle: 'เติมเงินกระเป๋า',
          price: price,
          amount: amount,
          statusMessages: topUpPaymentStatusMessages,
          summaryLabel: 'รายการ',
        ),
      ),
    );
  }

  void _openTopUps() {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const ProfileTopUpsPage()));
  }

  @override
  Widget build(BuildContext context) {
    final amountButtonWidth = (MediaQuery.sizeOf(context).width - 72) / 3;

    return Scaffold(
      key: const Key('profile_wallet_page'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('กระเป๋าเงิน'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 2, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 360),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 30,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2A5DB9), Color(0xFF2AB9A7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF2A5DB9,
                              ).withValues(alpha: 0.22),
                              blurRadius: 22,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'ยอดเงินปัจจุบัน',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatBaht(widget.currentWallet),
                              key: const Key('wallet_current_balance'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        key: const Key('wallet_top_up_history_button'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2A5DB9),
                          side: const BorderSide(
                            color: Color(0xFF2A5DB9),
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _openTopUps,
                        child: const Text(
                          'รายการเติมเงินทั้งหมด',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 72),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FB),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE0E5EF)),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'ยอดเติมที่เลือก',
                              style: TextStyle(
                                color: Color(0xFF5F5F5F),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            _formatBaht(_selectedAmount.toDouble()),
                            key: const Key('wallet_selected_amount'),
                            style: const TextStyle(
                              color: Color(0xFF2A5DB9),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'เลือกจำนวนเงิน',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _amountOptions.map((amount) {
                        final isSelected = amount == _selectedAmount;
                        return SizedBox(
                          width: amountButtonWidth,
                          height: 58,
                          child: _WalletAmountButton(
                            amount: amount,
                            isSelected: isSelected,
                            onPressed: () => _selectAmount(amount),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        key: const Key('wallet_pay_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A5DB9),
                          disabledBackgroundColor: const Color(0xFFB7C8EA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _selectedAmount == 0
                            ? null
                            : _openPaymentStatus,
                        child: const Text(
                          'ชำระเงิน',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatBaht(double amount) => '${amount.toStringAsFixed(0)} บาท';

String _formatCurrency(double amount) => '฿${amount.toStringAsFixed(2)}';

class _WalletAmountButton extends StatelessWidget {
  const _WalletAmountButton({
    required this.amount,
    required this.isSelected,
    required this.onPressed,
  });

  final int amount;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? const Color(0xFF2A5DB9)
        : const Color(0xFFF5F7FB);
    final foregroundColor = isSelected ? Colors.white : Colors.black;

    return FilledButton(
      key: Key('wallet_amount_button_$amount'),
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF2A5DB9)
                : const Color(0xFFE0E5EF),
            width: 1.4,
          ),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        '$amount',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }
}
