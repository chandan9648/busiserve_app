import 'dart:async';

import 'package:busiserve_app/core/errors/app_exception.dart';
import 'package:busiserve_app/core/errors/dio_error_mapper.dart';
import 'package:busiserve_app/core/errors/error_handler.dart';
import 'package:busiserve_app/core/errors/failure.dart';
import 'package:busiserve_app/core/errors/firebase_error_mapper.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseErrorMapper.mapAuth', () {
    test('wrong credentials share one message (no account enumeration)', () {
      for (final code in ['user-not-found', 'wrong-password', 'invalid-credential']) {
        final e = FirebaseErrorMapper.mapAuth(FirebaseAuthException(code: code));
        expect(e, isA<AuthenticationException>());
        expect(e.message, 'Email or password is incorrect.');
      }
    });
    test('network and rate limit', () {
      expect(FirebaseErrorMapper.mapAuth(FirebaseAuthException(code: 'network-request-failed')), isA<NetworkException>());
      expect(FirebaseErrorMapper.mapAuth(FirebaseAuthException(code: 'too-many-requests')), isA<RateLimitException>());
    });
    test('never leaks the raw server message', () {
      final e = FirebaseErrorMapper.mapAuth(
        FirebaseAuthException(code: 'internal-error', message: 'stack trace at line 42'),
      );
      expect(e.message.contains('stack'), isFalse);
    });
  });

  group('FirebaseErrorMapper.mapFunctions', () {
    test('invalid-argument carries field errors', () {
      final e = FirebaseErrorMapper.mapFunctions(
        FirebaseFunctionsException(
          code: 'invalid-argument',
          message: 'Some details are not valid.',
          details: {
            'fields': {'email': 'Enter a valid email address.'},
          },
        ),
      );
      expect(e, isA<ValidationException>());
      expect((e as ValidationException).fieldErrors['email'], 'Enter a valid email address.');
    });
    test('internal errors become generic server errors', () {
      final e = FirebaseErrorMapper.mapFunctions(
        FirebaseFunctionsException(code: 'internal', message: 'TypeError: x is undefined'),
      );
      expect(e, isA<ServerException>());
      expect(e.message.contains('TypeError'), isFalse);
    });
    test('resource-exhausted is rate limit', () {
      expect(
        FirebaseErrorMapper.mapFunctions(FirebaseFunctionsException(code: 'resource-exhausted', message: '')),
        isA<RateLimitException>(),
      );
    });
  });

  test('Firestore permission-denied', () {
    final e = FirebaseErrorMapper.map(FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'));
    expect(e, isA<PermissionException>());
  });

  group('DioErrorMapper', () {
    final req = RequestOptions(path: '/x');
    test('timeouts and connection errors', () {
      expect(DioErrorMapper.map(DioException.connectionTimeout(timeout: Duration.zero, requestOptions: req)),
          isA<RequestTimeoutException>(),);
      expect(DioErrorMapper.map(DioException.connectionError(requestOptions: req, reason: 'x')), isA<NetworkException>());
    });
    test('status codes', () {
      expect(DioErrorMapper.fromStatusForTest(401), isA<AuthenticationException>());
      expect(DioErrorMapper.fromStatusForTest(403), isA<PermissionException>());
      expect(DioErrorMapper.fromStatusForTest(404), isA<NotFoundException>());
      expect(DioErrorMapper.fromStatusForTest(429), isA<RateLimitException>());
      expect(DioErrorMapper.fromStatusForTest(503), isA<ServerException>());
    });
    test('422 extracts only well-formed field errors', () {
      final e = DioErrorMapper.fromStatusForTest(422, {
        'errors': {'email': 'Taken', 'bad': 3},
        'debug': 'SELECT * FROM users',
      }) as ValidationException;
      expect(e.fieldErrors, {'email': 'Taken'});
    });
  });

  group('ErrorHandler.map', () {
    test('passes AppException through', () {
      const e = NotFoundException();
      expect(ErrorHandler.map(e), same(e));
    });
    test('parsing and timeout', () {
      expect(ErrorHandler.map(const FormatException('bad')), isA<DataParsingException>());
      expect(ErrorHandler.map(TimeoutException('t')), isA<RequestTimeoutException>());
    });
    test('unknown objects become UnknownException', () {
      expect(ErrorHandler.map(Object()), isA<UnknownException>());
    });
    test('guard rethrows as AppException', () async {
      await expectLater(
        guard<void>(() async => throw const FormatException('x')),
        throwsA(isA<DataParsingException>()),
      );
    });
  });

  test('Failure.retryable only for transient errors', () {
    expect(Failure.fromException(const NetworkException()).retryable, isTrue);
    expect(Failure.fromException(const ServerException()).retryable, isTrue);
    expect(Failure.fromException(const PermissionException()).retryable, isFalse);
    expect(Failure.fromException(const ValidationException('x')).retryable, isFalse);
  });
}
