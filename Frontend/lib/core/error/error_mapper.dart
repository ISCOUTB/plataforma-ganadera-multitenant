import 'package:dio/dio.dart';
import 'failures.dart';

/// Convierte un [DioException] (incluyendo el body estandarizado del backend
/// `{ statusCode, message, path, timestamp }`) en una [AppFailure] tipada.
class ErrorMapper {
  ErrorMapper._();

  static AppFailure fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.cancel:
        return const UnknownFailure('Operación cancelada');
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Certificado inválido');
      case DioExceptionType.unknown:
        if (error.error != null && error.response == null) {
          return const NetworkFailure();
        }
        break;
      case DioExceptionType.badResponse:
        break;
    }

    final response = error.response;
    if (response == null) return const UnknownFailure();

    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    final message = _extractMessage(data);
    final fieldErrors = _extractFieldErrors(data);

    return switch (statusCode) {
      400 => ValidationFailure(message, fieldErrors: fieldErrors),
      401 => UnauthorizedFailure(message),
      403 => ForbiddenFailure(message),
      404 => NotFoundFailure(message),
      409 => ConflictFailure(message),
      >= 500 => ServerFailure(message),
      _ => UnknownFailure(message),
    };
  }

  static String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final raw = data['message'];
      if (raw is String) return raw;
      if (raw is List && raw.isNotEmpty) return raw.first.toString();
    }
    return 'Error desconocido';
  }

  static List<String> _extractFieldErrors(dynamic data) {
    if (data is Map<String, dynamic>) {
      final raw = data['message'];
      if (raw is List) return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
