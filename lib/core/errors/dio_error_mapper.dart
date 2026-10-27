import 'package:dio/dio.dart';

import 'app_exception.dart';

class DioErrorMapper {
  DioErrorMapper._();

  static AppException map(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const RequestTimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.cancel:
        return const UnknownException();
      case DioExceptionType.badCertificate:
        return const NetworkException(
          'A secure connection could not be established.',
        );
      case DioExceptionType.badResponse:
        return _fromStatus(e.response?.statusCode, e.response?.data);
      case DioExceptionType.unknown:
        if (e.error is FormatException) {
          return DataParsingException(cause: e.error);
        }
        return const NetworkException();
    }
  }

  static AppException _fromStatus(int? status, Object? data) {
    switch (status) {
      case 400:
      case 422:
        return ValidationException(
          'Some details are not valid. Check the form and try again.',
          fieldErrors: _fieldErrors(data),
        );
      case 401:
        return const AuthenticationException(
          'Your session has expired. Sign in again.',
          code: 'unauthenticated',
        );
      case 403:
        return const PermissionException();
      case 404:
        return const NotFoundException();
      case 409:
        return const ValidationException(
          'This was already submitted.',
          code: 'conflict',
        );
      case 429:
        return const RateLimitException();
      default:
        if (status != null && status >= 500) return const ServerException();
        return const UnknownException();
    }
  }

  /// Accepts `{ "errors": { "field": "message" } }`; ignores anything else so
  /// raw server bodies never reach the UI.
  static Map<String, String> _fieldErrors(Object? data) {
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      return {
        for (final entry in errors.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: entry.value as String,
      };
    }
    return const {};
  }

  /// Exposed for tests.
  static AppException fromStatusForTest(int? status, [Object? data]) =>
      _fromStatus(status, data);
}
