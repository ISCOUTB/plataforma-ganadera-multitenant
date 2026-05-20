import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/usuario_tenant.dart';

abstract class UsuariosRepository {
  Future<Either<AppFailure, List<UsuarioTenant>>> list();

  Future<Either<AppFailure, UsuarioTenant>> create({
    required String email,
    required String password,
    required String nombre,
    String? telefono,
    String? rol,
  });

  Future<Either<AppFailure, UsuarioTenant>> update(
    int id, {
    String? nombre,
    String? telefono,
    String? rol,
  });

  Future<Either<AppFailure, Unit>> remove(int id);
}
