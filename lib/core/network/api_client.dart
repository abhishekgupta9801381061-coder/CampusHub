import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import '../utils/security_utils.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({
    Dio? dio,
    String baseUrl = 'https://api.campushub.internal/v1',
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.info('Network Request: [${options.method}] ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info('Network Response: [${response.statusCode}] ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          AppLogger.error('Network Error: [${error.response?.statusCode}] ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  void _handleDioException(DioException e) {
    if (e.response?.statusCode == 401) {
      throw const AuthException('Session expired. Please log in again.');
    } else if (e.response?.statusCode == 429) {
      final msg = e.response?.data?['message'] ?? 'Rate limit exceeded. Please try again later.';
      throw RateLimitException(msg.toString());
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw const ServerException('Network connection failure. Please check your connectivity.');
    }
  }
}
