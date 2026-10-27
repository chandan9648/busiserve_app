import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_exception.dart';

/// Maps Firebase error codes to user-safe [AppException]s.
class FirebaseErrorMapper {
  FirebaseErrorMapper._();

  static AppException mapAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const ValidationException('Enter a valid email address.');
      case 'user-disabled':
        return AuthenticationException(
          'This account has been disabled. Contact support.',
          code: e.code,
        );
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return const AuthenticationException(
          'Email or password is incorrect.',
          code: 'invalid-credential',
        );
      case 'email-already-in-use':
        return AuthenticationException(
          'An account already exists with this email. Sign in instead.',
          code: e.code,
        );
      case 'weak-password':
        return const ValidationException(
          'Choose a stronger password: at least 8 characters with letters and numbers.',
        );
      case 'too-many-requests':
        return const RateLimitException();
      case 'requires-recent-login':
        return AuthenticationException(
          'For your security, sign in again and retry.',
          code: e.code,
        );
      case 'network-request-failed':
        return const NetworkException();
      case 'operation-not-allowed':
        return const ConfigurationException();
      default:
        return AuthenticationException(
          'We could not sign you in. Try again.',
          code: e.code,
        );
    }
  }

  static AppException mapFunctions(FirebaseFunctionsException e) {
    // Functions put safe, user-facing text in `message` for these codes only.
    final serverMessage = e.message?.trim();
    switch (e.code) {
      case 'invalid-argument':
        return ValidationException(
          (serverMessage?.isNotEmpty ?? false)
              ? serverMessage!
              : 'Some details are not valid. Check the form and try again.',
          fieldErrors: _fieldErrors(e.details),
        );
      case 'unauthenticated':
        return AuthenticationException(
          'Sign in to continue.',
          code: e.code,
        );
      case 'permission-denied':
        return const PermissionException();
      case 'not-found':
        return const NotFoundException();
      case 'resource-exhausted':
        return const RateLimitException();
      case 'deadline-exceeded':
        return const RequestTimeoutException();
      case 'unavailable':
        return const NetworkException();
      case 'failed-precondition':
        return const ConfigurationException();
      default:
        return ServerException(
          'Something went wrong on our side. Try again shortly.',
          e.code,
        );
    }
  }

  static AppException map(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const PermissionException();
      case 'not-found':
        return const NotFoundException();
      case 'unavailable':
        return const NetworkException();
      case 'deadline-exceeded':
        return const RequestTimeoutException();
      case 'resource-exhausted':
        return const RateLimitException();
      case 'unauthenticated':
        return AuthenticationException('Sign in to continue.', code: e.code);
      case 'no-app':
        return const ConfigurationException();
      // Storage
      case 'object-not-found':
        return const NotFoundException('This file is no longer available.');
      case 'unauthorized':
        return const PermissionException();
      case 'quota-exceeded':
        return const ServerException('Upload limit reached. Try again later.');
      default:
        return ServerException(
          'Something went wrong on our side. Try again shortly.',
          e.code,
        );
    }
  }

  static Map<String, String> _fieldErrors(Object? details) {
    if (details is Map) {
      final fields = details['fields'];
      if (fields is Map) {
        return {
          for (final entry in fields.entries)
            if (entry.key is String && entry.value is String)
              entry.key as String: entry.value as String,
        };
      }
    }
    return const {};
  }
}
