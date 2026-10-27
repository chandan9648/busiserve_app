import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Central logger. Redacts emails, phone numbers and token-like strings before
/// anything is printed or sent to Crashlytics. Never pass passwords here.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    level: kReleaseMode ? Level.warning : Level.debug,
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 6, lineLength: 100),
  );

  /// Set by bootstrap once Firebase is ready and the user has consented.
  static bool crashlyticsEnabled = false;

  static final RegExp _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');
  static final RegExp _phone = RegExp(r'\+?\d[\d\s-]{8,}\d');
  static final RegExp _token = RegExp(r'(bearer\s+)?[A-Za-z0-9_\-]{32,}', caseSensitive: false);

  static String redact(String input) => input
      .replaceAll(_email, '<email>')
      .replaceAll(_token, '<token>')
      .replaceAll(_phone, '<phone>');

  static void debug(String message) => _logger.d(redact(message));

  static void info(String message) => _logger.i(redact(message));

  static void warning(String message) => _logger.w(redact(message));

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    final safe = redact(message);
    _logger.e(safe, error: error == null ? null : redact(error.toString()), stackTrace: stackTrace);
    if (crashlyticsEnabled && error != null) {
      FirebaseCrashlytics.instance
          .recordError(redact(error.toString()), stackTrace, reason: safe)
          .ignore();
    }
  }
}
