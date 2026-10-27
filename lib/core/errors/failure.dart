import 'app_exception.dart';

/// What a controller keeps in its error state: a safe message plus whether a
/// retry button makes sense.
class Failure {
  const Failure(this.message, {this.code, this.retryable = false});

  factory Failure.fromException(AppException e) => Failure(
        e.message,
        code: e.code,
        retryable: switch (e) {
          NetworkException() ||
          RequestTimeoutException() ||
          ServerException() ||
          UnknownException() =>
            true,
          _ => false,
        },
      );

  final String message;
  final String? code;
  final bool retryable;

  @override
  String toString() => 'Failure($code)';
}
