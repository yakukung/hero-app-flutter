import 'package:hero_app_flutter/core/config/api_connect.dart';
import 'package:hero_app_flutter/core/models/enums.dart';

class AdminPaymentItem {
  const AdminPaymentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.userId,
    required this.username,
    required this.email,
    required this.slipImageUrl,
    required this.rawJson,
    this.paymentMethod,
  });

  final String id;
  final String title;
  final String type;
  final double amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final String userId;
  final String username;
  final String email;
  final String slipImageUrl;
  final Map<String, dynamic> rawJson;
  final String? paymentMethod;

  factory AdminPaymentItem.fromJson(Map<dynamic, dynamic> json) {
    return AdminPaymentItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'รายการชำระเงิน').toString(),
      type: (json['type'] ?? '').toString(),
      amount: double.tryParse((json['amount'] ?? 0).toString()) ?? 0,
      status: PaymentStatus.fromString(
        (json['payment_status'] ?? 'PENDING').toString(),
      ),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
              DateTime.now(),
      userId: (json['user_id'] ?? '').toString(),
      username: (json['username'] ?? 'ไม่ระบุผู้ใช้').toString(),
      email: (json['email'] ?? '').toString(),
      slipImageUrl: (json['slip_image_url'] ?? '').toString(),
      rawJson: json.map((key, value) => MapEntry(key.toString(), value)),
      paymentMethod: json['payment_method']?.toString(),
    );
  }

  factory AdminPaymentItem.fromSubscriptionJson(Map<dynamic, dynamic> json) {
    final payload = Map<dynamic, dynamic>.from(json);
    payload['type'] = 'SUBSCRIPTION';
    payload['title'] = payload['plan_name'] ?? 'พรีเมียม';
    return AdminPaymentItem.fromJson(payload);
  }

  String get amountLabel => '฿${amount.toStringAsFixed(2)}';

  String get dateLabel {
    final local = createdAt.toLocal();
    return '${_two(local.day)}/${_two(local.month)}/${local.year} '
        '${_two(local.hour)}:${_two(local.minute)}';
  }

  String get fullSlipImageUrl {
    if (slipImageUrl.isEmpty) return '';
    if (slipImageUrl.startsWith('http')) return slipImageUrl;
    if (slipImageUrl.startsWith('/')) return '$apiEndpoint$slipImageUrl';
    return '$apiEndpoint/$slipImageUrl';
  }

  String get statusLabel {
    switch (status) {
      case PaymentStatus.PENDING:
        return 'รอตรวจ';
      case PaymentStatus.SUCCESSFUL:
        return 'สำเร็จ';
      case PaymentStatus.FAILED:
        return 'ไม่ผ่าน';
      case PaymentStatus.REFUNDED:
        return 'คืนเงิน';
    }
  }

  String get typeLabel {
    switch (type) {
      case 'WALLET_TOPUP':
        return 'เติมเงิน';
      case 'SUBSCRIPTION':
        return 'พรีเมียม';
      case 'SHEET_PURCHASE':
        return 'ซื้อชีต';
      default:
        return 'ชำระเงิน';
    }
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}

class AdminReportItem {
  const AdminReportItem({
    required this.id,
    required this.referenceTable,
    required this.referenceId,
    required this.type,
    required this.reporterId,
    required this.reporterName,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.rawJson,
  });

  final String id;
  final String referenceTable;
  final String referenceId;
  final ReportType type;
  final String reporterId;
  final String reporterName;
  final String content;
  final ReportStatus status;
  final DateTime createdAt;
  final Map<String, dynamic> rawJson;

  factory AdminReportItem.fromJson(Map<dynamic, dynamic> json) {
    return AdminReportItem(
      id: (json['id'] ?? '').toString(),
      referenceTable: (json['reference_table'] ?? '').toString().toLowerCase(),
      referenceId: (json['reference_id'] ?? '').toString(),
      type: ReportType.fromString((json['report_type'] ?? 'OTHER').toString()),
      reporterId: (json['reporter_id'] ?? '').toString(),
      reporterName: (json['reporter_name'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      status: ReportStatus.fromString(
        (json['status_flag'] ?? 'PENDING').toString(),
      ),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
              DateTime.now(),
      rawJson: json.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  String get targetLabel {
    switch (referenceTable) {
      case 'posts':
        return 'โพสต์';
      case 'sheets':
        return 'ชีต';
      case 'users':
        return 'ผู้ใช้';
      default:
        return referenceTable.isEmpty ? 'เนื้อหา' : referenceTable;
    }
  }
}

class AdminSubscriptionItem {
  const AdminSubscriptionItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.planId,
    required this.planName,
    required this.startAt,
    required this.expiresAt,
    required this.autoRenew,
    required this.statusFlag,
  });

  final String id;
  final String userId;
  final String username;
  final String planId;
  final String planName;
  final DateTime startAt;
  final DateTime expiresAt;
  final bool autoRenew;
  final StatusFlag statusFlag;

  factory AdminSubscriptionItem.fromJson(Map<dynamic, dynamic> json) {
    return AdminSubscriptionItem(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      username: (json['username'] ?? json['user_id'] ?? 'ไม่ระบุผู้ใช้')
          .toString(),
      planId: (json['plan_id'] ?? '').toString(),
      planName: (json['plan_name'] ?? 'พรีเมียม').toString(),
      startAt:
          DateTime.tryParse((json['start_at'] ?? '').toString()) ??
              DateTime.now(),
      expiresAt:
          DateTime.tryParse((json['expires_at'] ?? '').toString()) ??
              DateTime.now(),
      autoRenew: json['auto_renew'] == true || json['auto_renew'] == 1,
      statusFlag: StatusFlag.fromString(
        (json['status_flag'] ?? 'ACTIVE').toString(),
      ),
    );
  }
}

class AdminSubscriptionsData {
  const AdminSubscriptionsData({
    required this.payments,
    required this.subscriptions,
  });

  final List<AdminPaymentItem> payments;
  final List<AdminSubscriptionItem> subscriptions;
}

class AdminRevenueSummary {
  const AdminRevenueSummary({
    required this.grossRevenue,
    required this.creatorShare,
    required this.platformShare,
    required this.topSheets,
    required this.monthly,
  });

  final double grossRevenue;
  final double creatorShare;
  final double platformShare;
  final List<AdminTopSheetRevenue> topSheets;
  final List<AdminMonthlyRevenue> monthly;

  factory AdminRevenueSummary.empty() {
    return const AdminRevenueSummary(
      grossRevenue: 0,
      creatorShare: 0,
      platformShare: 0,
      topSheets: [],
      monthly: [],
    );
  }

  factory AdminRevenueSummary.fromJson(Map<dynamic, dynamic> json) {
    return AdminRevenueSummary(
      grossRevenue: _toDouble(json['gross_revenue']),
      creatorShare: _toDouble(json['creator_share']),
      platformShare: _toDouble(json['platform_share']),
      topSheets:
          (json['top_sheets'] is List ? json['top_sheets'] as List : const [])
              .whereType<Map>()
              .map((item) => AdminTopSheetRevenue.fromJson(Map.from(item)))
              .toList(),
      monthly: (json['monthly'] is List ? json['monthly'] as List : const [])
          .whereType<Map>()
          .map((item) => AdminMonthlyRevenue.fromJson(Map.from(item)))
          .toList(),
    );
  }

  static double _toDouble(Object? value) {
    return double.tryParse((value ?? 0).toString()) ?? 0;
  }
}

class AdminTopSheetRevenue {
  const AdminTopSheetRevenue({
    required this.sheetId,
    required this.sheetTitle,
    required this.creatorId,
    required this.creatorName,
    required this.gross,
    required this.purchases,
  });

  final String sheetId;
  final String sheetTitle;
  final String creatorId;
  final String creatorName;
  final double gross;
  final int purchases;

  factory AdminTopSheetRevenue.fromJson(Map<dynamic, dynamic> json) {
    return AdminTopSheetRevenue(
      sheetId: (json['sheet_id'] ?? '').toString(),
      sheetTitle: (json['sheet_title'] ?? 'ชีต').toString(),
      creatorId: (json['creator_id'] ?? '').toString(),
      creatorName: (json['creator_name'] ?? '').toString(),
      gross: _toDouble(json['gross']),
      purchases: int.tryParse((json['purchases'] ?? 0).toString()) ?? 0,
    );
  }

  static double _toDouble(Object? value) {
    return double.tryParse((value ?? 0).toString()) ?? 0;
  }
}

class AdminMonthlyRevenue {
  const AdminMonthlyRevenue({
    required this.month,
    required this.gross,
    required this.creatorShare,
    required this.platformShare,
  });

  final String month;
  final double gross;
  final double creatorShare;
  final double platformShare;

  factory AdminMonthlyRevenue.fromJson(Map<dynamic, dynamic> json) {
    return AdminMonthlyRevenue(
      month: (json['month'] ?? '').toString(),
      gross: _toDouble(json['gross']),
      creatorShare: _toDouble(json['creator_share']),
      platformShare: _toDouble(json['platform_share']),
    );
  }

  static double _toDouble(Object? value) {
    return double.tryParse((value ?? 0).toString()) ?? 0;
  }
}
