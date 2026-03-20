import 'package:flutter_application_1/validations/validation_messages.dart';

String? validateUsernameOrEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return ValidationMessages.usernameOrEmailRequired;
  }
  return null;
}

String? validatePassword(String? value, {int minLength = 6}) {
  if (value == null || value.trim().isEmpty) {
    return ValidationMessages.passwordRequired;
  }
  if (value.trim().length < minLength) {
    return ValidationMessages.passwordMinLength(minLength);
  }
  return null;
}

String? validateRequiredPassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return ValidationMessages.passwordRequired;
  }
  return null;
}
