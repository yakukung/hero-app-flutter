enum StatusFlag {
  PENDING,
  ACTIVE,
  INACTIVE,
  SUSPENDED,
  TERMINATED;

  static StatusFlag fromString(String status) {
    return StatusFlag.values.firstWhere(
      (e) => e.name == status,
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
  ABUSE,
  BUG,
  OTHER;

  static ReportType fromString(String type) {
    return ReportType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ReportType.OTHER,
    );
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
