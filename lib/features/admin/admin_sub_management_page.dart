import 'package:flutter/material.dart';
import 'package:hero_app_flutter/constants/app_fonts.dart';
import 'package:hero_app_flutter/core/network/api_client.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:hero_app_flutter/features/admin/admin_design.dart';

class AdminSubManagementPage extends StatefulWidget {
  const AdminSubManagementPage({super.key});

  @override
  State<AdminSubManagementPage> createState() => _AdminSubManagementPageState();
}

class _AdminSubManagementPageState extends State<AdminSubManagementPage> {
  final SessionStore _sessionStore = SessionStore();
  final ApiClient _api = ApiClient();

  late Future<void> _initFuture;
  List<_PlanEntry> _plans = [];
  final Set<int> _saving = {};
  final Set<int> _expanded = {};

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  @override
  void dispose() {
    for (final plan in _plans) {
      plan.nameCtrl.dispose();
      plan.descCtrl.dispose();
      plan.priceCtrl.dispose();
      plan.durCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _init() async {
    final res = await _api.get(
      path: '/subscriptions/plans',
      token: _sessionStore.token,
    );
    if (res.statusCode != 200) return;
    final root = getApiData(res.body);
    final list = root is Map ? (root['plans'] as List?) : null;
    if (list == null || list.isEmpty) return;

    setState(() {
      _plans = list
          .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
              .map((e) => _PlanEntry(
                    id: e['id']?.toString() ?? '',
                    name: e['name']?.toString() ?? '',
                    description: e['description']?.toString() ?? '',
                    duration: (e['billing_interval_count'] as num?)?.toInt() ?? 0,
                    price: (e['price'] as num?)?.toDouble() ?? 0,
                    billingInterval: e['billing_interval']?.toString() ?? 'MONTH',
                  ))
          .toList();
    });
  }

  Future<void> _save(int i) async {
    final p = _plans[i];
    final name = p.nameCtrl.text.trim();
    final priceTxt = p.priceCtrl.text.trim();
    final durTxt = p.durCtrl.text.trim();

    if (name.isEmpty) return _snack('กรุณากรอกชื่อ');
    final price = double.tryParse(priceTxt);
    if (price == null || price <= 0) return _snack('กรุณากรอกราคาให้ถูกต้อง');
    final dur = int.tryParse(durTxt);
    if (dur == null || dur <= 0) return _snack('กรุณากรอกจำนวน${_intervalLabel(p.billingInterval)}ให้ถูกต้อง');

    if (p.billingInterval == 'MONTH' && dur > 12) {
      return _snack('ระยะเวลาเป็นเดือนต้องไม่เกิน 12 เดือน');
    }
    if (p.billingInterval == 'YEAR' && dur > 100) {
      return _snack('ระยะเวลาเป็นปีต้องไม่เกิน 100 ปี');
    }

    setState(() => _saving.add(i));
    final res = await _api.patchJson(
      path: '/admin/plans/${p.id}',
      token: _sessionStore.token,
      body: {
        'name': name,
        'description': p.descCtrl.text.trim(),
        'price': price,
        'billing_interval_count': dur,
      },
    );
    if (!mounted) return;
    setState(() => _saving.remove(i));

    if (res.statusCode == 200) {
      setState(() {
        _plans[i] = p.copyWith(name: name, description: p.descCtrl.text.trim(), price: price, duration: dur);
      });
      _snack('บันทึกสำเร็จ');
    } else {
      _snack(getErrorMessage(res, fallback: 'บันทึกไม่สำเร็จ'));
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: AppFonts.sukhumvit)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _accent(int i) {
    const colors = [Color(0xFF7C3AED), Color(0xFF2563EB), Color(0xFF059669), Color(0xFFD97706)];
    return colors[i % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        surfaceTintColor: AdminColors.background,
        elevation: 0,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.subscriptions_rounded, color: AdminColors.primary, size: 24),
            SizedBox(width: 10),
            Text(
              'แพ็กเกจพรีเมี่ยม',
              style: TextStyle(
                fontFamily: AppFonts.sukhumvit,
                color: AdminColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.subscriptions_outlined, size: 56, color: AdminColors.muted.withValues(alpha: 0.35)),
                  const SizedBox(height: 16),
                  const Text('ไม่มีแพ็กเกจ',
                      style: TextStyle(fontFamily: AppFonts.sukhumvit, color: AdminColors.muted, fontSize: 17)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() => _initFuture = _init()),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: _plans.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16),
                    child: Text('${_plans.length} รายการ',
                        style: const TextStyle(fontFamily: AppFonts.sukhumvit, color: AdminColors.muted, fontSize: 14)),
                  );
                }
                final idx = i - 1;
                return _PlanCard(
                  plan: _plans[idx],
                  accent: _accent(idx),
                  expanded: _expanded.contains(idx),
                  saving: _saving.contains(idx),
                  onToggle: () => setState(() {
                    if (_expanded.contains(idx)) {
                      _expanded.remove(idx);
                    } else {
                      _expanded.add(idx);
                    }
                  }),
                  onSave: () => _save(idx),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final _PlanEntry plan;
  final Color accent;
  final bool expanded;
  final bool saving;
  final VoidCallback onToggle;
  final VoidCallback onSave;

  const _PlanCard({
    required this.plan,
    required this.accent,
    required this.expanded,
    required this.saving,
    required this.onToggle,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: expanded ? 4 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.nameCtrl.text.isNotEmpty ? plan.nameCtrl.text : 'ไม่มีชื่อ',
                              style: const TextStyle(
                                fontFamily: AppFonts.sukhumvit,
                                color: AdminColors.text,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _Pill(label: '${plan.durCtrl.text} ${_intervalLabel(plan.billingInterval)}', color: accent),
                                const SizedBox(width: 8),
                                _Pill(label: '฿${plan.priceCtrl.text}', color: AdminColors.primary),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.expand_more_rounded, color: AdminColors.muted, size: 24),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildBody(),
                  crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),
          _FieldBox(
            controller: plan.nameCtrl,
            label: 'ชื่อแพ็กเกจ',
            hint: 'z.B. แผนรายเดือน',
          ),
          const SizedBox(height: 12),
          _FieldBox(
            controller: plan.descCtrl,
            label: 'คำอธิบาย',
            hint: 'รายละเอียดของแพ็กเกจ',
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FieldBox(
                  controller: plan.priceCtrl,
                  label: 'ราคา',
                  hint: '299',
                  prefix: '฿ ',
                  numeric: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FieldBox(
                  controller: plan.durCtrl,
                  label: 'ระยะเวลา',
                  hint: '1',
                  suffix: ' ${_intervalLabel(plan.billingInterval)}',
                  numeric: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_rounded, size: 20),
              label: Text(
                saving ? 'กำลังบันทึก…' : 'บันทึก',
                style: const TextStyle(fontFamily: AppFonts.sukhumvit, fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? prefix;
  final String? suffix;
  final int? maxLines;
  final bool numeric;

  const _FieldBox({
    required this.controller,
    required this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.numeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        suffixText: suffix,
        prefixStyle: const TextStyle(
          fontFamily: AppFonts.sukhumvit,
          color: AdminColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        suffixStyle: const TextStyle(
          fontFamily: AppFonts.sukhumvit,
          color: AdminColors.muted,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AdminColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: const TextStyle(fontFamily: AppFonts.sukhumvit, color: AdminColors.muted, fontSize: 13),
        hintStyle: const TextStyle(fontFamily: AppFonts.sukhumvit, color: AdminColors.muted, fontSize: 14),
      ),
      style: const TextStyle(fontFamily: AppFonts.sukhumvit, fontWeight: FontWeight.w700, fontSize: 15, color: AdminColors.text),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.sukhumvit,
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

String _intervalLabel(String? interval) {
  switch (interval) {
    case 'DAY':
      return 'วัน';
    case 'WEEK':
      return 'สัปดาห์';
    case 'MONTH':
      return 'เดือน';
    case 'YEAR':
      return 'ปี';
    default:
      return 'เดือน';
  }
}

class _PlanEntry {
  final String id;
  final String name;
  final String description;
  final int duration;
  final double price;
  final String billingInterval;
  late final TextEditingController nameCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController durCtrl;

  _PlanEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.billingInterval,
  }) {
    nameCtrl = TextEditingController(text: name);
    descCtrl = TextEditingController(text: description);
    priceCtrl = TextEditingController(text: price.toStringAsFixed(0));
    durCtrl = TextEditingController(text: duration.toString());
  }

  _PlanEntry copyWith({String? name, String? description, int? duration, double? price, String? billingInterval}) {
    return _PlanEntry(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      billingInterval: billingInterval ?? this.billingInterval,
    );
  }
}
