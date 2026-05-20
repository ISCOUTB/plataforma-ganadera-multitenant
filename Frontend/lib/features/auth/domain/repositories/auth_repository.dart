import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Contrato de la capa data para autenticación.
abstract class AuthRepository {
  Future<Either<AppFailure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<AppFailure, User>> register({
    required String email,
    required String password,
    required String nombre,
    required String tenantId,
    String? telefono,
  });

  Future<Either<AppFailure, User>> getMe();

  Future<Either<AppFailure, Unit>> logout();
}
