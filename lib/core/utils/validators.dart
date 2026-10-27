import 'package:flutter/widgets.dart';

import '../constants/app_limits.dart';

/// Reusable form validators. Client-side checks are for UX only; the backend
/// validates everything again.
class Validators {
  Validators._();

  static final RegExp _email = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
  );
  static final RegExp _name = RegExp(r"^[\p{L}][\p{L} .'\-]*$", unicode: true);
  static final RegExp _phoneAllowed = RegExp(r'^\+?[0-9 \-()]+$');
  static final RegExp _letter = RegExp(r'[A-Za-z]');
  static final RegExp _digit = RegExp(r'\d');

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required.';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required.';
    if (v.length > 254 || !_email.hasMatch(v)) return 'Enter a valid email address.';
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Name is required.';
    if (v.length < AppLimits.nameMin) return 'Name is too short.';
    if (v.length > AppLimits.nameMax) {
      return 'Name must be ${AppLimits.nameMax} characters or fewer.';
    }
    if (!_name.hasMatch(v)) return 'Use letters, spaces, dots, apostrophes or hyphens.';
    return null;
  }

  /// Accepts Indian 10-digit mobiles (optionally +91 / 0 prefixed) and other
  /// international numbers in E.164 range (8–15 digits).
  static String? phone(String? value, {bool isRequired = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return isRequired ? 'Phone number is required.' : null;
    if (!_phoneAllowed.hasMatch(v)) return 'Use digits only, with an optional +.';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (v.startsWith('+')) {
      if (digits.length < 8 || digits.length > 15) return 'Enter a valid phone number.';
      if (digits.startsWith('91') && !RegExp(r'^91[6-9]\d{9}$').hasMatch(digits)) {
        return 'Enter a valid Indian mobile number.';
      }
      return null;
    }
    final local = digits.startsWith('0') ? digits.substring(1) : digits;
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(local)) {
      return 'Enter a 10-digit mobile number, or add the country code with +.';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String field = 'This field'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$field is required.';
    if (v.length < min) return '$field must be at least $min characters.';
    return null;
  }

  static String? maxLength(String? value, int max, {String field = 'This field'}) {
    if ((value?.trim().length ?? 0) > max) {
      return '$field must be $max characters or fewer.';
    }
    return null;
  }

  static String? message(String? value) =>
      minLength(value, AppLimits.messageMin, field: 'Message') ??
      maxLength(value, AppLimits.messageMax, field: 'Message');

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required.';
    if (v.length < AppLimits.passwordMin) {
      return 'Use at least ${AppLimits.passwordMin} characters.';
    }
    if (!_letter.hasMatch(v) || !_digit.hasMatch(v)) {
      return 'Include at least one letter and one number.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirm your password.';
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  /// Runs validators in order and returns the first error.
  static FormFieldValidator<String> compose(List<FormFieldValidator<String>> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
