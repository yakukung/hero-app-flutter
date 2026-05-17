import 'package:flutter/material.dart';

import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/core/models/revenue_model.dart';
import 'package:hero_app_flutter/core/services/revenue_service.dart';

class SheetEarningsPage extends StatefulWidget {
  const SheetEarningsPage({super.key});

  @override
  State<SheetEarningsPage> createState() => _SheetEarningsPageState();
}

class _SheetEarningsPageState extends State<SheetEarningsPage> {
  int _selectedTab = 0;
  bool _isLoading = true;
  String _errorMessage = '';
  RevenueSummaryModel _summary = RevenueSummaryModel.empty();

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final result = await RevenueService.fetchCreatorEarnings();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _summary = result.data ?? RevenueSummaryModel.empty();
      _errorMessage = result.success ? '' : result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('sheet_earnings_page'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('รายได้ของชีต'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 8),
                _buildTotalEarningsCard(),
                const SizedBox(height: 20),
                _buildTabSelector(),
                const SizedBox(height: 16),
                Expanded(
                  child: _errorMessage.isNotEmpty
                      ? _EarningsStateMessage(
                          message: _errorMessage,
                          onRetry: _loadEarnings,
                        )
                      : _selectedTab == 0
                      ? _buildEarningsList(
                          _summary.daily,
                          emptyMessage: 'ยังไม่มีรายได้ในวันนี้',
                        )
                      : _buildEarningsList(
                          _summary.monthly,
                          emptyMessage: 'ยังไม่มีรายได้ในเดือนนี้',
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTotalEarningsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A5DB9), Color(0xFF2AB9A7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A5DB9).withValues(alpha: 0.22),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'รายได้ทั้งหมด',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatAmount(_summary.total),
              key: const Key('sheet_earnings_total'),
              style: const TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3F8),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                key: const Key('sheet_earnings_tab_daily'),
                label: 'รายวัน',
                isSelected: _selectedTab == 0,
                onTap: () => setState(() => _selectedTab = 0),
              ),
            ),
            Expanded(
              child: _TabButton(
                key: const Key('sheet_earnings_tab_monthly'),
                label: 'รายเดือน',
                isSelected: _selectedTab == 1,
                onTap: () => setState(() => _selectedTab = 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsList(
    List<RevenueItemModel> items, {
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _EarningCard(item: items[index]);
      },
    );
  }

  String _formatAmount(double amount) {
    if (amount % 1 == 0) return '${amount.toInt()} บาท';
    return '${amount.toStringAsFixed(2)} บาท';
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isSelected ? AppColors.primary : const Color(0xFF8A8A8A),
            ),
          ),
        ),
      ),
    );
  }
}

class _EarningCard extends StatelessWidget {
  const _EarningCard({required this.item});

  final RevenueItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2AB950).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on_outlined,
              color: Color(0xFF2AB950),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.sheetTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ผู้ซื้อ: ${item.buyerName}',
                  style: const TextStyle(
                    color: Color(0xFF6B6B6B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(item.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF8A8A8A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${_formatAmount(item.amount)}',
            style: const TextStyle(
              color: Color(0xFF2AB950),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount % 1 == 0) return '${amount.toInt()} บาท';
    return '${amount.toStringAsFixed(2)} บาท';
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

class _EarningsStateMessage extends StatelessWidget {
  const _EarningsStateMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
            OutlinedButton(onPressed: onRetry, child: const Text('ลองใหม่')),
          ],
        ),
      ),
    );
  }
}
