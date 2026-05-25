import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/core/models/revenue_model.dart';
import 'package:hero_app_flutter/core/services/revenue_service.dart';
import 'package:hero_app_flutter/features/user/sheet/preview_sheet_page.dart';

class SheetEarningsPage extends StatefulWidget {
  const SheetEarningsPage({super.key});

  @override
  State<SheetEarningsPage> createState() => _SheetEarningsPageState();
}

class _SheetEarningsPageState extends State<SheetEarningsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoading = true;
  String _errorMessage = '';
  RevenueSummaryModel _summary = RevenueSummaryModel.empty();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadEarnings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                      : IndexedStack(
                          index: _tabController.index,
                          children: [
                            _buildDailyTab(),
                            _buildMonthlyTab(),
                          ],
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
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(999),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: const Color(0xFF1A1A1A),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          dividerColor: Colors.transparent,
          splashBorderRadius: BorderRadius.circular(999),
          tabs: const [
            Tab(key: Key('sheet_earnings_tab_daily'), text: 'รายวัน'),
            Tab(key: Key('sheet_earnings_tab_monthly'), text: 'รายเดือน'),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTab() {
    final daily = _summary.daily;
    if (daily.items.isEmpty) {
      return _buildEmptyState('ยังไม่มีรายได้ในวันนี้');
    }

    return RefreshIndicator(
      onRefresh: _loadEarnings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          _buildDailySummaryCard(daily),
          const SizedBox(height: 20),
          _buildSectionHeader('รายการวันนี้'),
          const SizedBox(height: 8),
          ...daily.items.map((item) => _EarningCard(
            item: item,
            onTap: () => _openSheet(item.sheetId),
          )),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard(DailyEarningsSummary daily) {
    final itemsWord = daily.count <= 1 ? 'รายการ' : 'รายการ';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF2AB950).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.today_rounded,
              color: Color(0xFF2AB950),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'วันนี้',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatAmount(daily.total),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${daily.count} $itemsWord',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab() {
    final monthly = _summary.monthly;
    if (monthly.groups.isEmpty) {
      return _buildEmptyState('ยังไม่มีรายได้ในเดือนนี้');
    }

    return RefreshIndicator(
      onRefresh: _loadEarnings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          _buildMonthlySummaryCard(monthly),
          const SizedBox(height: 20),
          if (monthly.trend.length >= 2) ...[
            _buildSectionHeader('แนวโน้มรายวัน'),
            const SizedBox(height: 12),
            _buildTrendChart(monthly.trend),
            const SizedBox(height: 20),
            _buildSectionHeader('รายการตามวันที่'),
            const SizedBox(height: 8),
          ] else ...[
            _buildSectionHeader('รายการตามวันที่'),
            const SizedBox(height: 8),
          ],
          ...monthly.groups.expand((group) => _buildDateGroup(group)),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard(MonthlyEarningsSummary monthly) {
    final itemsWord = monthly.count <= 1 ? 'รายการ' : 'รายการ';
    final now = DateTime.now();
    final monthNames = [
      '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthNames[now.month],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatAmount(monthly.total),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${monthly.count} $itemsWord',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<EarningsTrend> trend) {
    if (trend.isEmpty) return const SizedBox.shrink();

    final maxTotal = trend.fold<double>(
      0,
      (max, t) => t.total > max ? t.total : max,
    );
    if (maxTotal == 0) return const SizedBox.shrink();

    return Container(
      height: 120,
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = (constraints.maxWidth - (trend.length - 1) * 4) /
              trend.length;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: trend.map((entry) {
              final fraction = entry.total / maxTotal;
              final barHeight = math.min(fraction * 70, 70.0);
              return Padding(
                padding: EdgeInsets.only(
                  right: entry != trend.last ? 4 : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatCompact(entry.total),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: math.min(math.max(barWidth, 8.0), 40.0),
                      height: barHeight,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A5DB9), Color(0xFF2AB9A7)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.date.substring(8),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.black38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  List<Widget> _buildDateGroup(MonthlyGroup group) {
    final dateParts = group.date.split('-');
    final day = dateParts.length > 2 ? int.tryParse(dateParts[2]) ?? 1 : 1;
    final month = dateParts.length > 1 ? int.tryParse(dateParts[1]) ?? 1 : 1;
    final year = dateParts.isNotEmpty ? int.tryParse(dateParts[0]) ?? 0 : 0;

    final thaiMonths = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    final headerText = '$day ${thaiMonths[month]} ${year + 543}';

    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          children: [
            Text(
              headerText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            Text(
              '${group.count} รายการ  ${_formatAmount(group.total)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      ...group.items.map((item) => _EarningCard(
        item: item,
        onTap: () => _openSheet(item.sheetId),
      )),
    ];
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount % 1 == 0) return '${amount.toInt()} บาท';
    return '${amount.toStringAsFixed(2)} บาท';
  }

  String _formatCompact(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    if (amount % 1 == 0) return amount.toInt().toString();
    return amount.toStringAsFixed(0);
  }

  void _openSheet(String sheetId) {
    if (sheetId.isEmpty) return;
    Get.to(() => PreviewSheetPage(sheetId: sheetId));
  }
}

class _EarningCard extends StatelessWidget {
  const _EarningCard({required this.item, this.onTap});

  final RevenueItemModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount % 1 == 0) return '${amount.toInt()} บาท';
    return '${amount.toStringAsFixed(2)} บาท';
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
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
