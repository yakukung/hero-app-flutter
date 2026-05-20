import 'package:hero_app_flutter/core/models/enums.dart';

class PaymentHistoryItem {
  const PaymentHistoryItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.reference,
    this.priceLabel,
    this.paymentMethod,
  });

  final String id;
  final String title;
  final double amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final String reference;
  final String? priceLabel;
  final String? paymentMethod;

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    final amountValue =
        json['amount'] ?? json['price'] ?? json['total'] ?? json['value'] ?? 0;
    final titleValue =
        json['package_title'] ??
        json['plan_name'] ??
        json['title'] ??
        json['reference_table'] ??
        'รายการชำระเงิน';
    return PaymentHistoryItem(
      id: (json['id'] ?? json['payment_id'] ?? '').toString(),
      title: titleValue.toString(),
      amount: double.tryParse(amountValue.toString()) ?? 0,
      status: PaymentStatus.fromString(
        (json['payment_status'] ?? json['status'] ?? 'PENDING').toString(),
      ),
      createdAt:
          DateTime.tryParse(
            (json['created_at'] ?? json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      reference:
          (json['reference'] ?? json['reference_id'] ?? json['id'] ?? '-')
              .toString(),
      priceLabel: json['price_label']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
    );
  }

  String get amountLabel => '฿${amount.toStringAsFixed(2)}';
}

class TopUpHistoryItem {
  const TopUpHistoryItem({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.reference,
    this.paymentMethod,
  });

  final String id;
  final double amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final String reference;
  final String? paymentMethod;

  factory TopUpHistoryItem.fromJson(Map<String, dynamic> json) {
    final amountValue = json['amount'] ?? json['total'] ?? json['value'] ?? 0;
    return TopUpHistoryItem(
      id: (json['id'] ?? json['top_up_id'] ?? '').toString(),
      amount: double.tryParse(amountValue.toString()) ?? 0,
      status: PaymentStatus.fromString(
        (json['payment_status'] ?? json['status'] ?? 'PENDING').toString(),
      ),
      createdAt:
          DateTime.tryParse(
            (json['created_at'] ?? json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      reference:
          (json['reference'] ?? json['reference_id'] ?? json['id'] ?? '-')
              .toString(),
      paymentMethod: json['payment_method']?.toString(),
    );
  }

  String get amountLabel => '฿${amount.toStringAsFixed(2)}';
}

class SubscriptionPlanModel {
  const SubscriptionPlanModel({
    required this.id,
    required this.title,
    required this.price,
    required this.intervalLabel,
    this.description,
    this.intervalCount = 1,
  });

  final String id;
  final String title;
  final double price;
  final String intervalLabel;
  final String? description;
  final int intervalCount;

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: (json['id'] ?? json['plan_id'] ?? '').toString(),
      title: (json['name'] ?? json['title'] ?? 'แพ็กเกจพรีเมียม').toString(),
      price: double.tryParse((json['price'] ?? 0).toString()) ?? 0,
      intervalLabel: (json['billing_interval'] ?? json['interval'] ?? 'MONTH')
          .toString(),
      description: json['description']?.toString(),
      intervalCount:
          int.tryParse(
            (json['billing_interval_count'] ?? json['interval_count'] ?? 1)
                .toString(),
          ) ??
          1,
    );
  }

  String get amountLabel => '฿${price.toStringAsFixed(2)}';
}

class SheetPurchaseResult {
  const SheetPurchaseResult({required this.isPurchased, this.walletBalance});

  final bool isPurchased;
  final double? walletBalance;

  factory SheetPurchaseResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final wallet = data['wallet'] is Map<String, dynamic>
        ? data['wallet'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return SheetPurchaseResult(
      isPurchased:
          data['is_purchased'] == true ||
          data['is_purchased'] == 1 ||
          data['purchased'] == true ||
          data['purchased'] == 1,
      walletBalance: wallet['balance'] != null
          ? double.tryParse(wallet['balance'].toString())
          : null,
    );
  }
}

class SubscriptionStatusModel {
  const SubscriptionStatusModel({
    required this.isPremium,
    this.planId,
    this.planName,
    this.expiresAt,
    this.autoRenew = false,
  });

  final bool isPremium;
  final String? planId;
  final String? planName;
  final DateTime? expiresAt;
  final bool autoRenew;

  factory SubscriptionStatusModel.inactive() {
    return const SubscriptionStatusModel(isPremium: false);
  }

  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return SubscriptionStatusModel(
      isPremium:
          data['is_premium'] == true ||
          data['is_premium'] == 1 ||
          data['premium'] == true ||
          data['premium'] == 1,
      planId: data['plan_id']?.toString(),
      planName: data['plan_name']?.toString(),
      expiresAt: data['expires_at'] == null
          ? null
          : DateTime.tryParse(data['expires_at'].toString()),
      autoRenew:
          data['auto_renew'] == true ||
          data['auto_renew'] == 1 ||
          data['autoRenew'] == true,
    );
  }
}
