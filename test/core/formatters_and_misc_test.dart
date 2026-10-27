import 'package:busiserve_app/core/services/push_notification_service.dart';
import 'package:busiserve_app/core/utils/app_logger.dart';
import 'package:busiserve_app/core/utils/formatters.dart';
import 'package:busiserve_app/core/utils/idempotency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('INR uses Indian grouping', () {
    expect(Formatters.currency(1234567.5), '₹12,34,567.50');
    expect(Formatters.currency(999), '₹999');
    expect(Formatters.currency(100000), '₹1,00,000');
  });

  test('other currencies use thousands grouping', () {
    expect(Formatters.currency(1234567, currency: 'USD'), 'USD 1,234,567');
  });

  test('relative time', () {
    final now = DateTime(2026, 10, 27, 12);
    expect(Formatters.relative(now.subtract(const Duration(seconds: 10)), now: now), 'Just now');
    expect(Formatters.relative(now.subtract(const Duration(minutes: 5)), now: now), '5 min ago');
    expect(Formatters.relative(now.subtract(const Duration(days: 2)), now: now), '2 d ago');
  });

  test('idempotency keys are v4 and unique', () {
    final a = IdempotencyKey.generate();
    final b = IdempotencyKey.generate();
    expect(IdempotencyKey.pattern.hasMatch(a), isTrue);
    expect(a, isNot(b));
  });

  test('logger redacts personal data', () {
    final out = AppLogger.redact('user asha@example.com called +91 97944 24169 token abcdefghijklmnopqrstuvwxyz0123456789');
    expect(out.contains('asha@example.com'), isFalse);
    expect(out.contains('97944'), isFalse);
    expect(out.contains('abcdefghijklmnopqrstuvwxyz'), isFalse);
  });

  test('notification routes are allow-listed', () {
    expect(PushNotificationService.isAllowedRoute('/projects/abc'), isTrue);
    expect(PushNotificationService.isAllowedRoute('/tickets/t1'), isTrue);
    expect(PushNotificationService.isAllowedRoute('/notifications'), isTrue);
    expect(PushNotificationService.isAllowedRoute('/delete-account'), isFalse);
    expect(PushNotificationService.isAllowedRoute('/tickets/'), isFalse);
    expect(PushNotificationService.isAllowedRoute('https://evil.example'), isFalse);
    expect(PushNotificationService.isAllowedRoute('/projects/../delete-account'), isFalse);
  });
}
