import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/app_logger.dart';
import 'app_exception.dart';
import 'dio_error_mapper.dart';
import 'firebase_error_mapper.dart';

/// Single entry point that turns any thrown object into an [AppException].
class ErrorHandler {
  ErrorHandler._();

  static AppException map(Object error) {
    if (error is AppException) return error;
    if (error is DioException) return DioErrorMapper.map(error);
    // Order matters: the specific Firebase types extend FirebaseException.
    if (error is FirebaseAuthException) return FirebaseErrorMapper.mapAuth(error);
    if (error is FirebaseFunctionsException) {
      return FirebaseErrorMapper.mapFunctions(error);
    }
    if (error is FirebaseException) return FirebaseErrorMapper.map(error);
    if (error is TimeoutException) return const RequestTimeoutException();
    if (error is FormatException || error is TypeError) {
      return DataParsingException(cause: error);
    }
    if (error is UnsupportedError || error is StateError) {
      // Typically Firebase not initialised for this flavor.
      final text = error.toString();
      if (text.contains('Firebase') || text.contains('[core/no-app]')) {
        return const ConfigurationException();
      }
    }
    return UnknownException(cause: error);
  }

  /// Maps and logs. Use from repositories via [guard].
  static AppException handle(Object error, StackTrace stackTrace, {String? context}) {
    final mapped = map(error);
    final isExpected = mapped is ValidationException ||
        mapped is AuthenticationException ||
        mapped is NetworkException ||
        mapped is RequestTimeoutException ||
        mapped is RateLimitException;
    if (isExpected) {
      AppLogger.info('${context ?? 'request'} failed: ${mapped.runtimeType}(${mapped.code})');
    } else {
      AppLogger.error(
        '${context ?? 'request'} failed: ${mapped.runtimeType}(${mapped.code})',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return mapped;
  }
}

/// Runs [action] and rethrows any failure as an [AppException].
Future<T> guard<T>(Future<T> Function() action, {String? context}) async {
  try {
    return await action();
  } catch (e, st) {
    throw ErrorHandler.handle(e, st, context: context);
  }
}

/// Maps errors emitted by a stream into [AppException]s.
Stream<T> guardStream<T>(Stream<T> source, {String? context}) {
  return source.handleError((Object e, StackTrace st) {
    throw ErrorHandler.handle(e, st, context: context);
  });
}
