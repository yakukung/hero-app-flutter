import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/controllers/config_controller.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_widgets.dart';

class AdminSubManagementPage extends StatefulWidget {
  const AdminSubManagementPage({super.key});

  @override
  State<AdminSubManagementPage> createState() => _AdminSubManagementPageState();
}

class _AdminSubManagementPageState extends State<AdminSubManagementPage> {
  late final ConfigController configController;
  final SessionStore _sessionStore = SessionStore();
  final ApiClient _api = ApiClient();

  late Future<void> _initFuture;
  List<_PlanEntry> _plans = [];
  final Map<int, TextEditingController> _discountControllers = {};

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ConfigController>()) {
      Get.put(ConfigController());
    }
    configController = Get.find<ConfigController>();
    _initFuture = _init();
  }

  @override
  void dispose() {
    for (final c in _discountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _init() async {
    await configController.fetchConfigs();
    _buildPlanList();
  }

  double get _pricePerMonth {
    final raw = configController.getConfigString('subscription_plans') ?? '';
    if (raw.isEmpty) return 299.0;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return (map['pricePerMonth'] ?? 299).toDouble();
    } catch (_) {
      return 299.0;
    }
  }

  void _buildPlanList() {
    final raw = configController.getConfigString('subscription_plans') ?? '';
    if (raw.isEmpty) return;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final plans = <_PlanEntry>[];
      data.forEach((key, value) {
        if (value is Map) {
          final plan = Map<String, dynamic>.from(value);
          final duration = plan['duration'];
          if (duration != null && duration != 0) {
            final index = int.tryParse(key) ?? 0;
            final price = (duration as num).toInt() * _pricePerMonth;
            plans.add(_PlanEntry(
              index: index,
              name: plan['name']?.toString() ?? '',
              description: plan['description']?.toString() ?? '',
              duration: duration is int ? duration : duration.toInt(),
              price: price,
              discountPercent: 0,
            ));
          }
        }
      });
      plans.sort((a, b) => a.duration.compareTo(b.duration));

      setState(() {
        _plans = plans;
        for (final plan in plans) {
          _discountControllers.putIfAbsent(
            plan.index,
            () => TextEditingController(),
          );
        }
      });
    } catch (_) {}
  }

  Future<void> _saveDiscount(int planIndex) async {
    final text = _discountControllers[planIndex]?.text ?? '';
    final percent = double.tryParse(text);
    if (percent == null || percent < 0 || percent > 100) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกส่วนลด 0-100%')),
      );
      return;
    }

    final response = await _api.postJson(
      path: '/admin/subscription-discounts',
      token: _sessionStore.token,
      body: {
        'plan_index': planIndex,
        'discount_percent': percent,
      },
    );

    if (!mounted) return;
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกส่วนลดสำเร็จ')),
      );
      setState(() {
        _plans = _plans.map((p) {
          if (p.index == planIndex) {
            return p.copyWith(discountPercent: percent);
          }
          return p;
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            getErrorMessage(response, fallback: 'บันทึกส่วนลดไม่สำเร็จ'),
          ),
        ),
      );
    }
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
          'จัดการส่วนลด',
          style: TextStyle(
            fontFamily: AppFonts.sukhumvit,
            color: AdminColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_plans.isEmpty) {
            return const Center(child: Text('ไม่พบข้อมูลแผนการสมัคร'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              AdminSectionHeader(
                title: 'ตั้งค่าส่วนลดตามระยะเวลา',
                subtitle: '${_plans.length} แผน',
              ),
              const SizedBox(height: 12),
              ..._plans.map((plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AdminCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan.name,
                                      style: const TextStyle(
                                        fontFamily: AppFonts.sukhumvit,
                                        color: AdminColors.text,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${plan.duration} เดือน',
                                      style: const TextStyle(
                                        fontFamily: AppFonts.sukhumvit,
                                        color: AdminColors.muted,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '฿${plan.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontFamily: AppFonts.sukhumvit,
                                  color: AdminColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          if (plan.discountPercent > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              'ส่วนลด ${plan.discountPercent.toStringAsFixed(0)}% '
                              '→ ฿${(plan.price * (1 - plan.discountPercent / 100)).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: AppFonts.sukhumvit,
                                color: AdminColors.success,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  controller:
                                      _discountControllers[plan.index],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'ส่วนลด %',
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontFamily: AppFonts.sukhumvit,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              FilledButton(
                                onPressed: () => _saveDiscount(plan.index),
                                child: const Text('บันทึก'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _PlanEntry {
  final int index;
  final String name;
  final String description;
  final int duration;
  final double price;
  final double discountPercent;

  const _PlanEntry({
    required this.index,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    this.discountPercent = 0,
  });

  _PlanEntry copyWith({double? discountPercent}) {
    return _PlanEntry(
      index: index,
      name: name,
      description: description,
      duration: duration,
      price: price,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }
}
