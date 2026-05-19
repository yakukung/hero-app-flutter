import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/controllers/config_controller.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';
import 'package:hero_app_flutter/features/admin/admin_widgets.dart';

class SellAccessPage extends StatefulWidget {
  const SellAccessPage({super.key});

  @override
  State<SellAccessPage> createState() => _SellAccessPageState();
}

class _SellAccessPageState extends State<SellAccessPage> {
  final ConfigController configController = Get.put(ConfigController());

  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = configController.fetchConfigs();
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
          'ระบบจำหน่ายสิทธิ์',
          style: TextStyle(
            fontFamily: AppFonts.sukhumvit,
            color: AdminColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildPlanList();
        },
      ),
    );
  }

  Widget _buildPlanList() {
    final raw = configController.getConfigString('subscription_plans') ?? '';
    if (raw.isEmpty) {
      return const Center(child: Text('ไม่พบข้อมูลแผนการสมัคร'));
    }

    Map<String, dynamic> plansMap;
    try {
      plansMap = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return const Center(child: Text('ข้อมูลแผนการสมัครไม่ถูกต้อง'));
    }

    final plans = <_PlanEntry>[];
    plansMap.forEach((key, value) {
      if (value is Map) {
        final plan = Map<String, dynamic>.from(value);
        final duration = plan['duration'];
        if (duration != null && duration != 0) {
          final price = (duration as num).toInt() * _pricePerMonth;
          plans.add(_PlanEntry(
            index: int.tryParse(key) ?? 0,
            name: plan['name']?.toString() ?? '',
            description: plan['description']?.toString() ?? '',
            duration: duration is int ? duration : duration.toInt(),
            price: price,
          ));
        }
      }
    });
    plans.sort((a, b) => a.duration.compareTo(b.duration));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        AdminSectionHeader(
          title: 'เลือกระยะเวลา',
          subtitle: '${plans.length} แผน',
        ),
        const SizedBox(height: 12),
        ...plans.map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AdminCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          if (plan.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              plan.description,
                              style: const TextStyle(
                                fontFamily: AppFonts.sukhumvit,
                                color: AdminColors.muted,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            '${plan.duration} เดือน',
                            style: const TextStyle(
                              fontFamily: AppFonts.sukhumvit,
                              color: AdminColors.muted,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
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
              ),
            )),
      ],
    );
  }
}

class _PlanEntry {
  final int index;
  final String name;
  final String description;
  final int duration;
  final double price;

  const _PlanEntry({
    required this.index,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
  });
}
