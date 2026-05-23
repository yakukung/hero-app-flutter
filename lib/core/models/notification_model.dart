import 'package:flutter/material.dart';

class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.statusFlag,
    this.referenceTable,
    this.referenceId,
    this.reportType,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? statusFlag;
  final String? referenceTable;
  final String? referenceId;
  final String? reportType;

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'การแจ้งเตือน').toString(),
      message: (json['message'] ?? json['content'] ?? '').toString(),
      createdAt:
          DateTime.tryParse(
            (json['created_at'] ?? json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      isRead:
          json['is_read'] == true ||
          json['read'] == true ||
          json['is_read'] == 1,
      statusFlag: (json['status_flag'] as String?)?.toUpperCase(),
      referenceTable: json['reference_table']?.toString(),
      referenceId: json['reference_id']?.toString(),
      reportType: json['report_type']?.toString(),
    );
  }

  String get statusLabel {
    switch (statusFlag) {
      case 'PENDING':
        return 'รอตรวจ';
      case 'RESOLVED':
        return 'จัดการแล้ว';
      case 'REJECTED':
        return 'ปฏิเสธ';
      default:
        return statusFlag ?? '';
    }
  }

  Color get statusColor {
    switch (statusFlag) {
      case 'PENDING':
        return const Color(0xFFB26A00);
      case 'RESOLVED':
        return const Color(0xFF1B7F3A);
      case 'REJECTED':
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }

  String get referenceLabel {
    switch (referenceTable) {
      case 'sheets':
        return 'ชีต';
      case 'posts':
        return 'โพสต์';
      case 'users':
        return 'โปรไฟล์';
      default:
        return referenceTable ?? '';
    }
  }
}