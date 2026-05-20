import 'package:dio/dio.dart';

import '../../error/error_mapper.dart';

/// Traduce todo `DioException` en una nueva con `error: AppFailure`,
/// para que las capas superiores nunca toquen `DioException` directamente.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = ErrorMapper.fromDio(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: failure,
        stackTrace: err.stackTrace,
        message: failure.message,
      ),
    );
  }
}
