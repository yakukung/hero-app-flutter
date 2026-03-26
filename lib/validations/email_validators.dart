import 'package:flutter_application_1/validations/validation_error.dart';
import 'package:flutter_application_1/validations/validation_messages.dart';

final RegExp _basicEmailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

bool isValidEmail(String email) {
  return _basicEmailRegExp.hasMatch(email);
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return ValidationMessages.emailRequired;
  }
  if (!isValidEmail(value.trim())) {
    return ValidationMessages.invalidEmailMessage;
  }
  return null;
}

ValidationError? validateChangeEmail({
  required String newEmail,
  required String currentEmail,
  required String password,
}) {
  if (newEmail.isEmpty || password.isEmpty) {
    return const ValidationError(
      title: ValidationMessages.incompleteInfoTitle,
      message: ValidationMessages.incompleteInfoMessage,
    );
  }

  if (newEmail == currentEmail) {
    return const ValidationError(
      title: ValidationMessages.duplicateEmailTitle,
      message: ValidationMessages.duplicateEmailMessage,
    );
  }

  if (!isValidEmail(newEmail)) {
    return const ValidationError(
      title: ValidationMessages.invalidFormatTitle,
      message: ValidationMessages.invalidEmailMessage,
    );
  }

  return null;
}
