class ServiceResult<T> {
  const ServiceResult({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  final bool success;
  final int statusCode;
  final String message;
  final T? data;

  bool get isBackendUnavailable =>
      statusCode == 0 || statusCode == 404 || statusCode == 501;
}
