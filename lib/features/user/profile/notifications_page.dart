import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:hero_app_flutter/core/controllers/app_controller.dart';
import 'package:hero_app_flutter/core/controllers/navigation_controller.dart';
import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/models/notification_model.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/core/services/notification_service.dart';
import 'package:hero_app_flutter/core/services/payment_service.dart';
import 'package:hero_app_flutter/features/user/profile/widgets/profile_subscription.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<AppNotificationModel> _notifications = const [];
  final AppController _appController = Get.find<AppController>();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    NotificationPreferences.markAsSeen();
    super.dispose();
  }

  bool get _hasPremiumExpiryBanner {
    final status = _appController.subscriptionStatus.value;
    if (status == null || !status.isPremium) return false;
    final expiresAt = status.expiresAt;
    if (expiresAt == null) return false;
    final daysRemaining = expiresAt.difference(DateTime.now()).inDays;
    return daysRemaining <= 7;
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final lastSeen = NotificationPreferences.lastSeenAt;
    if (lastSeen == null) {
      NotificationPreferences.markAsSeen();
    }

    final sheetsCtrl = Get.find<SheetsController>();
    if (sheetsCtrl.sheets.isEmpty) {
      await sheetsCtrl.fetchSheets();
    } else {
      await sheetsCtrl.fetchSheets(forceRefresh: true);
    }

    final results = await Future.wait([
      NotificationService.fetchNotifications(),
      Future(() => sheetsCtrl.sheets),
    ]);

    final result = results[0] as ServiceResult<List<AppNotificationModel>>;
    final sheets = results[1] as List<SheetModel>;

    if (!mounted) return;

    if (lastSeen != null) {
      debugPrint('=== SHEET NOTIFICATION DEBUG ===');
      debugPrint('lastSeenAt: $lastSeen');
      debugPrint('total sheets: ${sheets.length}');
      for (final s in sheets) {
        final isNew = s.createdAt.isAfter(lastSeen);
        final isUpdated = s.updatedAt != null &&
            s.updatedAt!.isAfter(lastSeen) &&
            s.updatedAt!.difference(s.createdAt).inSeconds > 5;
        if (isNew || isUpdated) {
          debugPrint('  MATCH: ${s.id} "${s.title}" created=${s.createdAt} new=$isNew updated=$isUpdated');
        }
      }
    }

    final sheetNotis = lastSeen != null
        ? NotificationService.buildSheetNotifications(
            lastSeenAt: lastSeen,
            sheets: sheets,
          )
        : <AppNotificationModel>[];

    final merged = <AppNotificationModel>[
      ...?result.data,
      ...sheetNotis,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _isLoading = false;
      _notifications = merged;
      _errorMessage = result.success ? '' : result.message;
    });

    try {
      Get.find<NavigationController>().refreshUnreadCount();
    } catch (_) {}
  }

  void _showSubscriptionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProfileSubscription(
        fetchPlans: () => PaymentService.fetchPlans(),
      ),
    );
  }

  Widget _buildPremiumExpiryBanner() {
    final status = _appController.subscriptionStatus.value!;
    final expiresAt = status.expiresAt!;
    final now = DateTime.now();
    final diff = expiresAt.difference(now);
    final daysRemaining = diff.inDays;
    final isExpired = daysRemaining < 0;

    Color bgColor;
    Color iconColor;
    IconData icon;
    String title;
    String message;
    String subtitle;

    if (isExpired) {
      bgColor = const Color(0xFFFDE8E8);
      iconColor = const Color(0xFFC62828);
      icon = Icons.error_outline;
      title = 'พรีเมียมหมดอายุแล้ว';
      message = 'สิทธิ์การใช้งานพรีเมียมของคุณหมดอายุแล้ว';
      subtitle = 'หมดอายุแล้ว';
    } else if (daysRemaining < 1) {
      bgColor = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFB26A00);
      icon = Icons.timer_off_outlined;
      title = 'พรีเมียมจะหมดอายุวันนี้';
      message = 'สิทธิ์การใช้งานพรีเมียมของคุณจะหมดอายุในวันนี้';
      subtitle = 'หมดอายุวันนี้';
    } else if (daysRemaining <= 3) {
      bgColor = const Color(0xFFFFF8E1);
      iconColor = const Color(0xFFB26A00);
      icon = Icons.timer_outlined;
      title = 'พรีเมียมใกล้หมดอายุ';
      message = 'สิทธิ์พรีเมียมของคุณจะหมดอายุในอีก $daysRemaining วัน';
      subtitle = 'เหลืออีก $daysRemaining วัน';
    } else {
      bgColor = const Color(0xFFE8F0FE);
      iconColor = const Color(0xFF1A73E8);
      icon = Icons.info_outline;
      title = 'พรีเมียมใกล้หมดอายุ';
      message = 'สิทธิ์พรีเมียมของคุณจะหมดอายุในอีก $daysRemaining วัน';
      subtitle = 'เหลืออีก $daysRemaining วัน';
    }

    if (status.autoRenew && !isExpired) {
      message += ' (ต่ออายุอัตโนมัติ)';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _showSubscriptionSheet,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'พรีเมียม',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: iconColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: iconColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _markAsRead(int index) {
    final notificationIndex = _hasPremiumExpiryBanner ? index - 1 : index;
    if (notificationIndex < 0) return;
    final item = _notifications[notificationIndex];
    if (item.isRead) return;

    if (!item.id.startsWith('sheet_')) {
      NotificationService.markAsRead(item.id);
    }

    setState(() {
      _notifications[notificationIndex] = AppNotificationModel(
        id: item.id,
        title: item.title,
        message: item.message,
        createdAt: item.createdAt,
        isRead: true,
      );
    });

    try {
      Get.find<NavigationController>().refreshUnreadCount();
    } catch (_) {}
  }

  String _timeAgo(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'เมื่อสักครู่';
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว';
    if (diff.inDays < 7) return '${diff.inDays} วันที่แล้ว';
    return '${local.day}/${local.month}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('การแจ้งเตือน'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 160),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    final int itemCount = _notifications.length + (_hasPremiumExpiryBanner ? 1 : 0);

    if (itemCount == 0) {
      return ListView(
        children: const [
          SizedBox(height: 160),
          Center(
            child: Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'ยังไม่มีการแจ้งเตือน',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (_hasPremiumExpiryBanner && index == 0) {
          return _buildPremiumExpiryBanner();
        }
        final notificationIndex = _hasPremiumExpiryBanner ? index - 1 : index;
        final item = _notifications[notificationIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: item.isRead ? Colors.white : const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _markAsRead(index),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.isRead
                            ? Colors.grey.shade100
                            : const Color(0xFFD2E3FC),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isRead
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        color: item.isRead ? Colors.grey : const Color(0xFF1A73E8),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                              fontSize: 15,
                              color: item.isRead ? Colors.black54 : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                          children: [
                            Text(
                              _timeAgo(item.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: item.isRead ? Colors.grey : const Color(0xFF1A73E8),
                                fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w600,
                              ),
                            ),
                            if (item.referenceTable != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.referenceLabel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                            if (item.statusFlag != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: item.statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        ],
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A73E8),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
