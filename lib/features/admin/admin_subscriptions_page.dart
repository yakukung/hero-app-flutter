import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/services/admin_service.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_models.dart';
import 'package:hero_app_flutter/features/admin/admin_widgets.dart';

class AdminSubscriptionsPage extends StatefulWidget {
  const AdminSubscriptionsPage({super.key});

  @override
  State<AdminSubscriptionsPage> createState() => _AdminSubscriptionsPageState();
}

class _AdminSubscriptionsPageState extends State<AdminSubscriptionsPage> {
  final _sessionStore = SessionStore();
  late Future<List<AdminSubscriptionItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<void> _refresh() async {
    final next = _fetch();
    setState(() {
      _future = next;
    });
    await next;
  }

  Future<List<AdminSubscriptionItem>> _fetch() async {
    final response =
        await AdminService.fetchSubscriptions(token: _sessionStore.token);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        getErrorMessage(response, fallback: 'โหลดรายการสมาชิกไม่สำเร็จ'),
      );
    }

    final root = getApiData(response.body);
    final List<dynamic> list;
    if (root is Map<String, dynamic> && root['subscriptions'] is List) {
      list = root['subscriptions'] as List;
    } else if (root is List) {
      list = root;
    } else {
      list = getApiList(response.body, const ['subscriptions', 'items', 'data']);
    }

    return list
        .whereType<Map>()
        .map((e) => AdminSubscriptionItem.fromJson(Map.from(e)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        surfaceTintColor: AdminColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'พรีเมียม',
          style: TextStyle(
            fontFamily: AppFonts.sukhumvit,
            color: AdminColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<AdminSubscriptionItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return AdminEmptyStatePage(
                title: 'พรีเมียม',
                icon: Icons.workspace_premium_outlined,
                message: snapshot.error.toString().replaceFirst('Exception: ', ''),
                onRefresh: _refresh,
              );
            }

            final items = snapshot.data ?? const <AdminSubscriptionItem>[];
            if (items.isEmpty) {
              return AdminEmptyStatePage(
                title: 'พรีเมียม',
                icon: Icons.workspace_premium_outlined,
                message: 'ยังไม่มีข้อมูลสมาชิก',
                onRefresh: _refresh,
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final subscription = items[index];
                  return AdminCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subscription.username,
                                style: const TextStyle(
                                  fontFamily: AppFonts.sukhumvit,
                                  color: AdminColors.text,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            AdminStatusPill(
                              label: _statusLabel(subscription.statusFlag),
                              color: _statusColor(subscription.statusFlag),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subscription.planName,
                          style: const TextStyle(
                            fontFamily: AppFonts.sukhumvit,
                            color: AdminColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'หมดอายุ: ${_formatDate(subscription.expiresAt)}',
                          style: const TextStyle(
                            fontFamily: AppFonts.sukhumvit,
                            color: AdminColors.muted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${_two(local.day)}/${_two(local.month)}/${local.year}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  String _statusLabel(StatusFlag status) {
    switch (status) {
      case StatusFlag.PENDING:
        return 'รอตรวจ';
      case StatusFlag.ACTIVE:
        return 'ใช้งาน';
      case StatusFlag.INACTIVE:
        return 'ซ่อน';
      case StatusFlag.SUSPENDED:
        return 'ระงับ';
      case StatusFlag.TERMINATED:
        return 'ยุติ';
    }
  }

  Color _statusColor(StatusFlag status) {
    switch (status) {
      case StatusFlag.PENDING:
        return AdminColors.warning;
      case StatusFlag.ACTIVE:
        return AdminColors.success;
      case StatusFlag.INACTIVE:
        return AdminColors.muted;
      case StatusFlag.SUSPENDED:
        return AdminColors.danger;
      case StatusFlag.TERMINATED:
        return AdminColors.danger;
    }
  }
}
