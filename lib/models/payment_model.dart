import 'enums.dart';

class UserPaymentModel {
  final String id;
  final String userId;
  final String referenceId;
  final String referenceTable;
  final String paymentMethod;
  final double amount;
  final String currency;
  final PaymentStatus paymentStatus;
  final String? slipImageUrl;
  final DateTime createdAt;

  UserPaymentModel({
    required this.id,
    required this.userId,
    required this.referenceId,
    required this.referenceTable,
    required this.paymentMethod,
    required this.amount,
    required this.currency,
    required this.paymentStatus,
    this.slipImageUrl,
    required this.createdAt,
  });

  factory UserPaymentModel.fromJson(Map<String, dynamic> json) {
    return UserPaymentModel(
      id: json['id'],
      userId: json['user_id'],
      referenceId: json['reference_id'],
      referenceTable: json['reference_table'],
      paymentMethod: json['payment_method'],
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'] ?? 'THB',
      paymentStatus: PaymentStatus.fromString(json['payment_status']),
      slipImageUrl: json['slip_image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class PlanModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final BillingInterval billingInterval;
  final int billingIntervalCount;

  PlanModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.currency,
    required this.billingInterval,
    required this.billingIntervalCount,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      currency: json['currency'] ?? 'THB',
      billingInterval: BillingInterval.fromString(json['billing_interval']),
      billingIntervalCount: json['billing_interval_count'] ?? 1,
    );
  }
}
