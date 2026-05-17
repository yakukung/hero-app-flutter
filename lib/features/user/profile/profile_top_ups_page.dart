import 'package:flutter/material.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/payment_history_model.dart';
import 'package:hero_app_flutter/core/services/payment_service.dart';
import 'package:hero_app_flutter/features/user/profile/profile_payment_status_page.dart';

class ProfileTopUpHistoryItem {
  const ProfileTopUpHistoryItem({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.reference,
  });

  final String id;
  final String amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final String reference;

  factory ProfileTopUpHistoryItem.fromServiceModel(TopUpHistoryItem item) {
    return ProfileTopUpHistoryItem(
      id: item.id,
      amount: item.amountLabel,
      status: item.status,
      createdAt: item.createdAt,
      reference: item.reference,
    );
  }
}

class ProfileTopUpsPage extends StatefulWidget {
  const ProfileTopUpsPage({super.key, this.topUps});

  final List<ProfileTopUpHistoryItem>? topUps;

  @override
  State<ProfileTopUpsPage> createState() => _ProfileTopUpsPageState();
}

class _ProfileTopUpsPageState extends State<ProfileTopUpsPage> {
  List<ProfileTopUpHistoryItem> _topUps = const [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.topUps != null) {
      _topUps = widget.topUps!;
      _isLoading = false;
    } else {
      _loadTopUps();
    }
  }

  Future<void> _loadTopUps() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final result = await PaymentService.fetchTopUpHistory();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _topUps = (result.data ?? const [])
          .map(ProfileTopUpHistoryItem.fromServiceModel)
          .toList();
      _errorMessage = result.success ? '' : result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('profile_top_ups_page'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('รายการเติมเงินทั้งหมดของคุณ'),
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
      return _TopUpStateMessage(
        message: _errorMessage,
        actionLabel: 'ลองใหม่',
        onAction: _loadTopUps,
      );
    }

    if (_topUps.isEmpty) {
      return const Center(
        child: Text(
          'ยังไม่มีรายการเติมเงิน',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: _topUps.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'ทั้งหมด ${_topUps.length} รายการ',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return _TopUpHistoryCard(topUp: _topUps[index - 1]);
      },
    );
  }
}

class _TopUpHistoryCard extends StatelessWidget {
  const _TopUpHistoryCard({required this.topUp});

  final ProfileTopUpHistoryItem topUp;

  @override
  Widget build(BuildContext context) {
    final statusData = PaymentStatusViewData.fromStatus(topUp.status);

    return GestureDetector(
      key: Key('profile_top_up_item_${topUp.id}'),
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ProfilePaymentStatusPage(
              status: topUp.status,
              packageTitle: 'เติมเงินกระเป๋า',
              price: topUp.amount,
              amount: topUp.amount,
              statusMessages: topUpPaymentStatusMessages,
              summaryLabel: 'รายการ',
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
                  const Text(
                    'เติมเงินกระเป๋า',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topUp.reference,
                    style: const TextStyle(
                      color: Color(0xFF6B6B6B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(topUp.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF8A8A8A),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TopUpStatusChip(status: topUp.status),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  topUp.amount,
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

class _TopUpStatusChip extends StatelessWidget {
  const _TopUpStatusChip({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final statusData = PaymentStatusViewData.fromStatus(status);

    return Container(
      key: Key('profile_top_up_status_chip_${status.name}'),
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

class _TopUpStateMessage extends StatelessWidget {
  const _TopUpStateMessage({
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
