import 'package:hero_app_flutter/core/session/app_session_coordinator.dart';

enum AuthFlowStatus {
  success,
  needsVerification,
  validationError,
  failure,
  cancelled,
}

class AuthFlowResult {
  const AuthFlowResult._({
    required this.status,
    this.title = '',
    this.message = '',
    this.destination,
  });

  final AuthFlowStatus status;
  final String title;
  final String message;
  final SessionDestination? destination;

  bool get isSuccess => status == AuthFlowStatus.success;

  bool get shouldShowDialog =>
      title.trim().isNotEmpty || message.trim().isNotEmpty;

  factory AuthFlowResult.success(SessionDestination destination) {
    return AuthFlowResult._(
      status: AuthFlowStatus.success,
      destination: destination,
    );
  }

  factory AuthFlowResult.needsVerification({
    required String title,
    required String message,
  }) {
    return AuthFlowResult._(
      status: AuthFlowStatus.needsVerification,
      title: title,
      message: message,
    );
  }

  factory AuthFlowResult.validation({
    required String title,
    required String message,
  }) {
    return AuthFlowResult._(
      status: AuthFlowStatus.validationError,
      title: title,
      message: message,
    );
  }

  factory AuthFlowResult.failure({
    required String title,
    required String message,
  }) {
    return AuthFlowResult._(
      status: AuthFlowStatus.failure,
      title: title,
      message: message,
    );
  }

  factory AuthFlowResult.cancelled() {
    return const AuthFlowResult._(status: AuthFlowStatus.cancelled);
  }
}
