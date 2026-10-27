import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Non-sensitive preferences only. Tokens and credentials go to
/// [SecureStorageService].
class PrefsService extends GetxService {
  PrefsService([GetStorage? box]) : _box = box ?? GetStorage();
  final GetStorage _box;

  static const _onboardingDone = 'onboarding_done';
  static const _themeMode = 'theme_mode';
  static const _crashConsent = 'crash_reporting_consent';
  static const _pushEnabled = 'push_enabled';

  bool get onboardingDone => _box.read<bool>(_onboardingDone) ?? false;
  Future<void> setOnboardingDone() => _box.write(_onboardingDone, true);

  ThemeMode get themeMode => switch (_box.read<String>(_themeMode)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
  Future<void> setThemeMode(ThemeMode mode) => _box.write(_themeMode, mode.name);

  /// Null means the user has not been asked yet. Crash reporting stays off
  /// until this is explicitly true.
  bool? get crashReportingConsent => _box.read<bool>(_crashConsent);
  Future<void> setCrashReportingConsent(bool value) => _box.write(_crashConsent, value);

  bool get pushEnabled => _box.read<bool>(_pushEnabled) ?? true;
  Future<void> setPushEnabled(bool value) => _box.write(_pushEnabled, value);
}
