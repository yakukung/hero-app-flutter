class RevenueItemModel {
  const RevenueItemModel({
    required this.id,
    required this.sheetId,
    required this.sheetTitle,
    required this.amount,
    required this.buyerName,
    required this.createdAt,
    this.grossAmount,
  });

  final String id;
  final String sheetId;
  final String sheetTitle;
  final double amount;
  final String buyerName;
  final DateTime createdAt;
  final double? grossAmount;

  factory RevenueItemModel.fromJson(Map<String, dynamic> json) {
    return RevenueItemModel(
      id: (json['id'] ?? '').toString(),
      sheetId: (json['sheet_id'] ?? '').toString(),
      sheetTitle: (json['sheet_title'] ?? json['title'] ?? 'ชีต').toString(),
      amount: double.tryParse((json['amount'] ?? 0).toString()) ?? 0,
      buyerName: (json['buyer_name'] ?? json['username'] ?? 'ไม่ระบุ')
          .toString(),
      createdAt:
          DateTime.tryParse(
            (json['created_at'] ?? json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      grossAmount: double.tryParse(
        (json['gross_amount'] ?? '').toString(),
      ),
    );
  }
}

class DailyEarningsSummary {
  const DailyEarningsSummary({
    required this.count,
    required this.total,
    required this.items,
  });

  final int count;
  final double total;
  final List<RevenueItemModel> items;

  factory DailyEarningsSummary.empty() {
    return const DailyEarningsSummary(count: 0, total: 0, items: []);
  }

  factory DailyEarningsSummary.fromJson(Map<String, dynamic> json) {
    return DailyEarningsSummary(
      count: int.tryParse((json['count'] ?? 0).toString()) ?? 0,
      total: double.tryParse((json['total'] ?? 0).toString()) ?? 0,
      items: RevenueSummaryModel._mapItems(json['items']),
    );
  }
}

class MonthlyGroup {
  const MonthlyGroup({
    required this.date,
    required this.total,
    required this.count,
    required this.items,
  });

  final String date;
  final double total;
  final int count;
  final List<RevenueItemModel> items;

  factory MonthlyGroup.fromJson(Map<String, dynamic> json) {
    return MonthlyGroup(
      date: (json['date'] ?? '').toString(),
      total: double.tryParse((json['total'] ?? 0).toString()) ?? 0,
      count: int.tryParse((json['count'] ?? 0).toString()) ?? 0,
      items: RevenueSummaryModel._mapItems(json['items']),
    );
  }
}

class EarningsTrend {
  const EarningsTrend({required this.date, required this.total});

  final String date;
  final double total;

  factory EarningsTrend.fromJson(Map<String, dynamic> json) {
    return EarningsTrend(
      date: (json['date'] ?? '').toString(),
      total: double.tryParse((json['total'] ?? 0).toString()) ?? 0,
    );
  }
}

class MonthlyEarningsSummary {
  const MonthlyEarningsSummary({
    required this.count,
    required this.total,
    required this.groups,
    required this.trend,
  });

  final int count;
  final double total;
  final List<MonthlyGroup> groups;
  final List<EarningsTrend> trend;

  factory MonthlyEarningsSummary.empty() {
    return const MonthlyEarningsSummary(
      count: 0,
      total: 0,
      groups: [],
      trend: [],
    );
  }

  factory MonthlyEarningsSummary.fromJson(Map<String, dynamic> json) {
    return MonthlyEarningsSummary(
      count: int.tryParse((json['count'] ?? 0).toString()) ?? 0,
      total: double.tryParse((json['total'] ?? 0).toString()) ?? 0,
      groups: (json['groups'] as List?)
              ?.map(
                (e) => MonthlyGroup.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          [],
      trend: (json['trend'] as List?)
              ?.map(
                (e) => EarningsTrend.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          [],
    );
  }
}

class RevenueSummaryModel {
  const RevenueSummaryModel({
    required this.total,
    required this.daily,
    required this.monthly,
  });

  final double total;
  final DailyEarningsSummary daily;
  final MonthlyEarningsSummary monthly;

  factory RevenueSummaryModel.empty() {
    return RevenueSummaryModel(
      total: 0,
      daily: DailyEarningsSummary.empty(),
      monthly: MonthlyEarningsSummary.empty(),
    );
  }

  factory RevenueSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return RevenueSummaryModel(
      total:
          double.tryParse(
            (data['total'] ?? data['total_revenue'] ?? 0).toString(),
          ) ??
          0,
      daily: data['daily'] is Map
          ? DailyEarningsSummary.fromJson(
              Map<String, dynamic>.from(data['daily']),
            )
          : DailyEarningsSummary.empty(),
      monthly: data['monthly'] is Map
          ? MonthlyEarningsSummary.fromJson(
              Map<String, dynamic>.from(data['monthly']),
            )
          : MonthlyEarningsSummary.empty(),
    );
  }

  static List<RevenueItemModel> _mapItems(dynamic source) {
    if (source is! List) return const [];
    return source
        .whereType<Map>()
        .map(
          (item) => RevenueItemModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}

