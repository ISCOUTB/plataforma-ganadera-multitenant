import 'package:equatable/equatable.dart';

/// Tipo base para errores de aplicación.
///
/// Las capas presentation jamás trabajan con `DioException` directamente:
/// el `ErrorInterceptor` traduce todo a una subclase de [AppFailure].
sealed class AppFailure extends Equatable {
  final String message;
  final int? statusCode;

  const AppFailure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([String message = 'Sin conexión a Internet'])
      : super(message);
}

class TimeoutFailure extends AppFailure {
  const TimeoutFailure([String message = 'La solicitud tardó demasiado'])
      : super(message);
}

class ValidationFailure extends AppFailure {
  final List<String> fieldErrors;
  const ValidationFailure(String message, {this.fieldErrors = const []})
      : super(message, statusCode: 400);

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure([String message = 'Sesión expirada'])
      : super(message, statusCode: 401);
}

class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure([String message = 'No tienes permiso'])
      : super(message, statusCode: 403);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure([String message = 'Recurso no encontrado'])
      : super(message, statusCode: 404);
}

class ConflictFailure extends AppFailure {
  const ConflictFailure([String message = 'Conflicto'])
      : super(message, statusCode: 409);
}

class ServerFailure extends AppFailure {
  const ServerFailure([String message = 'Error del servidor'])
      : super(message, statusCode: 500);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([String message = 'Ocurrió un error inesperado'])
      : super(message);
}
