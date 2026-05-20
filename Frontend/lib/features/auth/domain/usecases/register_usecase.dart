import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<Either<AppFailure, User>> call({
    required String email,
    required String password,
    required String nombre,
    required String tenantId,
    String? telefono,
  }) =>
      _repository.register(
        email: email,
        password: password,
        nombre: nombre,
        tenantId: tenantId,
        telefono: telefono,
      );
}
