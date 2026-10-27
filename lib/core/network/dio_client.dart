import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_env.dart';
import '../constants/app_limits.dart';
import '../errors/app_exception.dart';
import '../errors/error_handler.dart';
import '../services/secure_storage_service.dart';
import '../utils/app_logger.dart';

/// REST client for a future backend (for example the Busiserve CRM).
///
/// Registered only when `API_BASE_URL` is set. No feature uses it yet,
/// because no API contract has been provided; do not add endpoints until one is.
class DioClient {
  DioClient({required SecureStorageService secureStorage, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppEnv.apiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: AppLimits.requestTimeout,
                sendTimeout: AppLimits.requestTimeout,
                responseType: ResponseType.json,
                headers: {'Accept': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(_AuthInterceptor(secureStorage));
    if (kDebugMode) _dio.interceptors.add(_SafeLogInterceptor());
  }

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    required T Function(Map<String, dynamic> json) parse,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) =>
      guard(() async {
        final res = await _dio.get<Object?>(path, queryParameters: query, cancelToken: cancelToken);
        return parse(_asMap(res.data));
      }, context: 'GET $path',);

  /// [idempotencyKey] is sent as `Idempotency-Key` so the server can reject
  /// duplicates. Never retry a POST automatically.
  Future<T> post<T>(
    String path, {
    required Object body,
    required T Function(Map<String, dynamic> json) parse,
    String? idempotencyKey,
    CancelToken? cancelToken,
  }) =>
      guard(() async {
        final res = await _dio.post<Object?>(
          path,
          data: body,
          cancelToken: cancelToken,
          options: Options(
            headers: {if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey},
          ),
        );
        return parse(_asMap(res.data));
      }, context: 'POST $path',);

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.map((k, v) => MapEntry(k.toString(), v));
    throw const DataParsingException(cause: 'Response body is not a JSON object');
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage);
  final SecureStorageService _storage;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.readApiToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}

/// Logs method, path and status only. Never headers or bodies.
class _SafeLogInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    AppLogger.debug('${response.requestOptions.method} ${response.requestOptions.path} -> ${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.debug('${err.requestOptions.method} ${err.requestOptions.path} -> ${err.response?.statusCode ?? err.type.name}');
    handler.next(err);
  }
}
