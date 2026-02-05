import 'enums.dart';

class UserReportModel {
  final String id;
  final String referenceId;
  final String referenceTable;
  final ReportType reportType;
  final String reporterId;
  final String content;
  final ReportStatus statusFlag;
  final DateTime createdAt;

  UserReportModel({
    required this.id,
    required this.referenceId,
    required this.referenceTable,
    required this.reportType,
    required this.reporterId,
    required this.content,
    required this.statusFlag,
    required this.createdAt,
  });

  factory UserReportModel.fromJson(Map<String, dynamic> json) {
    return UserReportModel(
      id: json['id'],
      referenceId: json['reference_id'],
      referenceTable: json['reference_table'],
      reportType: ReportType.fromString(json['report_type']),
      reporterId: json['reporter_id'],
      content: json['content'],
      statusFlag: ReportStatus.fromString(json['status_flag']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
