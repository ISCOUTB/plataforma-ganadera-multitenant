import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// Cliente HTTP central. Se construye con un [AuthInterceptor] ya armado
/// (que internamente usa un Dio "limpio" para el refresh).
class DioClient {
  final Dio dio;

  DioClient({
    required AuthInterceptor authInterceptor,
  }) : dio = _buildDio() {
    dio.interceptors.add(authInterceptor);
    dio.interceptors.add(ErrorInterceptor());
    if (Env.isDebug) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
        ),
      );
    }
  }

  static Dio _buildDio() => Dio(
        BaseOptions(
          baseUrl: Env.apiBaseUrl,
          connectTimeout: Env.connectTimeout,
          receiveTimeout: Env.receiveTimeout,
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );

  /// Dio sin interceptores de auth — usado SOLO para llamar `/auth/refresh`
  /// y para reintentar requests tras el refresh, evitando recursión.
  static Dio buildRefreshDio() => _buildDio();
}
