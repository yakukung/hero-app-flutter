import 'package:hero_app_flutter/validations/validation_messages.dart';

String? validateUsernameOrEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return ValidationMessages.usernameOrEmailRequired;
  }
  return null;
}

String? validateUsername(String? value) {
  if (value == null || value.trim().isEmpty) {
    return ValidationMessages.usernameRequired;
  }

  final username = value.trim();
  if (username.length < 3 || username.length > 20) {
    return ValidationMessages.usernameLengthRange(3, 20);
  }

  final usernameRegExp = RegExp(r'^[a-zA-Z0-9_]+$');
  if (!usernameRegExp.hasMatch(username)) {
    return ValidationMessages.usernameInvalidChars;
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

String? validateStrongPassword(String? value, {int minLength = 8}) {
  if (value == null || value.trim().isEmpty) {
    return ValidationMessages.passwordRequired;
  }

  final password = value.trim();
  if (password.length < minLength) {
    return ValidationMessages.passwordMinLength(minLength);
  }

  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return ValidationMessages.passwordRequireUppercase;
  }

  if (!RegExp(r'[0-9]').hasMatch(password)) {
    return ValidationMessages.passwordRequireDigit;
  }

  return null;
}

String? validateRequiredPassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return ValidationMessages.passwordRequired;
  }
  return null;
}
