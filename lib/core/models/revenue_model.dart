class RevenueItemModel {
  const RevenueItemModel({
    required this.id,
    required this.sheetTitle,
    required this.amount,
    required this.buyerName,
    required this.createdAt,
  });

  final String id;
  final String sheetTitle;
  final double amount;
  final String buyerName;
  final DateTime createdAt;

  factory RevenueItemModel.fromJson(Map<String, dynamic> json) {
    return RevenueItemModel(
      id: (json['id'] ?? '').toString(),
      sheetTitle: (json['sheet_title'] ?? json['title'] ?? 'ชีต').toString(),
      amount: double.tryParse((json['amount'] ?? 0).toString()) ?? 0,
      buyerName: (json['buyer_name'] ?? json['username'] ?? 'ไม่ระบุ')
          .toString(),
      createdAt:
          DateTime.tryParse(
            (json['created_at'] ?? json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
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
  final List<RevenueItemModel> daily;
  final List<RevenueItemModel> monthly;

  factory RevenueSummaryModel.empty() {
    return const RevenueSummaryModel(total: 0, daily: [], monthly: []);
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
      daily: _mapItems(data['daily'] ?? data['daily_items']),
      monthly: _mapItems(data['monthly'] ?? data['monthly_items']),
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
