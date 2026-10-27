import 'package:busiserve_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('email', () {
    test('accepts normal addresses', () {
      expect(Validators.email('team@busiserve.in'), isNull);
      expect(Validators.email('  a.b+c@sub.example.co  '), isNull);
    });
    test('rejects empty and malformed', () {
      expect(Validators.email(''), 'Email is required.');
      expect(Validators.email('no-at-sign'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email('a b@c.com'), isNotNull);
    });
  });

  group('phone', () {
    test('optional by default', () => expect(Validators.phone(''), isNull));
    test('required when asked', () => expect(Validators.phone('', isRequired: true), isNotNull));
    test('accepts Indian mobiles in common formats', () {
      expect(Validators.phone('9794424169'), isNull);
      expect(Validators.phone('09794424169'), isNull);
      expect(Validators.phone('+91 97944 24169'), isNull);
    });
    test('accepts international numbers', () => expect(Validators.phone('+44 20 7946 0958'), isNull));
    test('rejects invalid', () {
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.phone('+91 12345 67890'), isNotNull);
      expect(Validators.phone('97944abc69'), isNotNull);
    });
  });

  group('name', () {
    test('accepts letters including non-Latin', () {
      expect(Validators.name('Chandan Kumar'), isNull);
      expect(Validators.name("D'Souza-Rao"), isNull);
      expect(Validators.name('चंदन'), isNull);
    });
    test('rejects short, long, symbols', () {
      expect(Validators.name('A'), isNotNull);
      expect(Validators.name('x' * 81), isNotNull);
      expect(Validators.name('<script>'), isNotNull);
    });
  });

  group('message and lengths', () {
    test('message min length', () {
      expect(Validators.message('too short'), isNotNull);
      expect(Validators.message('This is long enough.'), isNull);
    });
    test('maxLength', () {
      expect(Validators.maxLength('abc', 2), isNotNull);
      expect(Validators.maxLength(null, 2), isNull);
    });
  });

  group('password', () {
    test('rules', () {
      expect(Validators.password('short1'), isNotNull);
      expect(Validators.password('longenough'), isNotNull);
      expect(Validators.password('12345678'), isNotNull);
      expect(Validators.password('secure123'), isNull);
    });
    test('confirm', () {
      expect(Validators.confirmPassword('a', 'b'), 'Passwords do not match.');
      expect(Validators.confirmPassword('same1234', 'same1234'), isNull);
    });
  });

  test('compose returns first error', () {
    final v = Validators.compose([
      (s) => Validators.required(s, field: 'Field'),
      (s) => Validators.maxLength(s, 3),
    ]);
    expect(v(''), 'Field is required.');
    expect(v('abcd'), isNotNull);
    expect(v('abc'), isNull);
  });
}
