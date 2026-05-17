import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_payments_page.dart';
import 'package:hero_app_flutter/features/admin/admin_reports_page.dart';
import 'package:hero_app_flutter/features/admin/admin_revenue_page.dart';
import 'package:hero_app_flutter/features/admin/admin_sheets_page.dart';
import 'package:hero_app_flutter/features/admin/admin_subscriptions_page.dart';

// Dashboard page that shows menu grid
class AdminReportsDashboardPage extends StatelessWidget {
  const AdminReportsDashboardPage({super.key});

  static final _sections = [
    const _AdminManagementItem(
      title: 'แจ้งปัญหา',
      subtitle: 'รายงานจากผู้ใช้',
      icon: Icons.report_problem_outlined,
      page: AdminReportsPage(),
    ),
    const _AdminManagementItem(
      title: 'จัดการชีต',
      subtitle: 'สถานะและการแสดงผล',
      icon: Icons.description_outlined,
      page: AdminSheetsPage(),
    ),
    _AdminManagementItem(
      title: 'การชำระเงิน',
      subtitle: 'ตรวจรายการจ่ายเงิน',
      icon: Icons.payments_outlined,
      page: AdminPaymentsPage(),
    ),
    _AdminManagementItem(
      title: 'พรีเมียม',
      subtitle: 'แพ็กเกจสมาชิก',
      icon: Icons.workspace_premium_outlined,
      page: AdminSubscriptionsPage(),
    ),
    _AdminManagementItem(
      title: 'รายได้',
      subtitle: 'ภาพรวมการเงิน',
      icon: Icons.analytics_outlined,
      page: AdminRevenuePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: AdminPageHeader(
                title: 'จัดการระบบ',
                subtitle: 'เลือกหมวดงานที่ต้องการดูแล',
                icon: Icons.admin_panel_settings_outlined,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 140),
            sliver: SliverGrid.builder(
              itemCount: _sections.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.32,
              ),
              itemBuilder: (context, index) {
                final item = _sections[index];
                return _AdminManagementTile(
                  item: item,
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(builder: (context) => item.page),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminManagementItem {
  const _AdminManagementItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
}

class _AdminManagementTile extends StatelessWidget {
  const _AdminManagementTile({required this.item, required this.onTap});

  final _AdminManagementItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconBg = AdminColors.primary.withValues(alpha: 0.1);
    return AdminCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(item.icon, color: AdminColors.primary),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AdminColors.muted,
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppFonts.sukhumvit,
              color: AdminColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppFonts.sukhumvit,
              color: AdminColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
