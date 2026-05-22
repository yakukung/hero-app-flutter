// ignore_for_file: constant_identifier_names

enum StatusFlag {
  PENDING,
  ACTIVE,
  INACTIVE,
  SUSPENDED,
  TERMINATED;

  static StatusFlag fromString(String status) {
    final normalizedStatus = status.trim().toUpperCase();
    return StatusFlag.values.firstWhere(
      (e) => e.name == normalizedStatus,
      orElse: () => StatusFlag.ACTIVE,
    );
  }
}

enum AuthProvider {
  EMAIL_PASSWORD,
  GOOGLE;

  static AuthProvider fromString(String provider) {
    return AuthProvider.values.firstWhere(
      (e) => e.name == provider,
      orElse: () => AuthProvider.EMAIL_PASSWORD,
    );
  }
}

enum BillingInterval {
  DAY,
  WEEK,
  MONTH,
  YEAR;

  static BillingInterval fromString(String interval) {
    return BillingInterval.values.firstWhere(
      (e) => e.name == interval,
      orElse: () => BillingInterval.MONTH,
    );
  }
}

enum PaymentStatus {
  PENDING,
  SUCCESSFUL,
  FAILED,
  REFUNDED;

  static PaymentStatus fromString(String status) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => PaymentStatus.PENDING,
    );
  }
}

enum ReportType {
  SPAM,
  INAPPROPRIATE,
  HARASSMENT,
  VIOLENCE,
  INFRINGEMENT,
  ADULT,
  FAKE_PROFILE,
  OTHER;

  String get displayName {
    switch (this) {
      case ReportType.SPAM:
        return 'สแปม';
      case ReportType.INAPPROPRIATE:
        return 'เนื้อหาไม่เหมาะสม หรือไม่ถูกต้อง';
      case ReportType.HARASSMENT:
        return 'การกลั่นแกล้ง การคุกคาม หรือการแสดงความเกลียดชัง';
      case ReportType.VIOLENCE:
        return 'เนื้อหาเกี่ยวกับความรุนแรง หรือการทำร้ายตัวเอง';
      case ReportType.INFRINGEMENT:
        return 'การละเมิดทรัพย์สินทางปัญญา';
      case ReportType.ADULT:
        return 'เนื้อหาสำหรับผู้ใหญ่';
      case ReportType.FAKE_PROFILE:
        return 'โปรไฟล์ปลอม';
      case ReportType.OTHER:
        return 'อื่นๆ';
    }
  }

  static ReportType fromString(String type) {
    return ReportType.values.firstWhere(
      (e) => e.name == type || e.displayName == type,
      orElse: () => ReportType.OTHER,
    );
  }

  static List<ReportType> forTable(String referenceTable) {
    // Users table has different valid types (no SPAM/INAPPROPRIATE, has FAKE_PROFILE)
    if (referenceTable == 'users') {
      return [FAKE_PROFILE, HARASSMENT, VIOLENCE, INFRINGEMENT, ADULT, OTHER];
    }
    // Posts and sheets share the same types
    return [SPAM, INAPPROPRIATE, HARASSMENT, VIOLENCE, INFRINGEMENT, ADULT, OTHER];
  }
}

enum ReportStatus {
  PENDING,
  REVIEWING,
  RESOLVED,
  REJECTED;

  static ReportStatus fromString(String status) {
    return ReportStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ReportStatus.PENDING,
    );
  }
}
