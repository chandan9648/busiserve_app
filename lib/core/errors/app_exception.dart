/// Typed, user-safe exceptions. [message] is always safe to show on screen;
/// [code] and [cause] are for logs and branching only.
sealed class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => '$runtimeType(code: $code)';
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Check your connection and try again.',
  ]) : super(code: 'network');
}

class RequestTimeoutException extends AppException {
  const RequestTimeoutException([
    super.message = 'The request took too long. Try again.',
  ]) : super(code: 'timeout');
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.code, super.cause});
}

/// Signed in, but not allowed to do this.
class PermissionException extends AppException {
  const PermissionException([
    super.message = 'You do not have access to this.',
  ]) : super(code: 'permission-denied');
}

class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    this.fieldErrors = const {},
    super.code = 'invalid-argument',
  });

  final Map<String, String> fieldErrors;
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'This item is no longer available.'])
      : super(code: 'not-found');
}

class RateLimitException extends AppException {
  const RateLimitException([
    super.message = 'Too many attempts. Wait a few minutes and try again.',
  ]) : super(code: 'rate-limited');
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Something went wrong on our side. Try again shortly.',
    String? code,
  ]) : super(code: code ?? 'server');
}

class DataParsingException extends AppException {
  const DataParsingException({Object? cause})
      : super(
          'We received data we could not read. Update the app or try again later.',
          code: 'parse',
          cause: cause,
        );
}

class ConfigurationException extends AppException {
  const ConfigurationException([
    super.message =
        'This feature is not available yet. Contact us by phone or email instead.',
  ]) : super(code: 'not-configured');
}

class UnknownException extends AppException {
  const UnknownException({Object? cause})
      : super('Something went wrong. Try again.', code: 'unknown', cause: cause);
}
