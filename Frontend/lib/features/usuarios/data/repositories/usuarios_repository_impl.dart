import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/usuario_tenant.dart';
import '../../domain/repositories/usuarios_repository.dart';
import '../datasources/usuarios_remote_datasource.dart';

class UsuariosRepositoryImpl implements UsuariosRepository {
  final UsuariosRemoteDataSource _remote;
  UsuariosRepositoryImpl({required UsuariosRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<Either<AppFailure, List<UsuarioTenant>>> list() =>
      _guard(() => _remote.list());

  @override
  Future<Either<AppFailure, UsuarioTenant>> create({
    required String email,
    required String password,
    required String nombre,
    String? telefono,
    String? rol,
  }) =>
      _guard(() => _remote.create(
            email: email,
            password: password,
            nombre: nombre,
            telefono: telefono,
            rol: rol,
          ));

  @override
  Future<Either<AppFailure, UsuarioTenant>> update(
    int id, {
    String? nombre,
    String? telefono,
    String? rol,
  }) =>
      _guard(() => _remote.update(
            id,
            nombre: nombre,
            telefono: telefono,
            rol: rol,
          ));

  @override
  Future<Either<AppFailure, Unit>> remove(int id) => _guard(() async {
        await _remote.remove(id);
        return unit;
      });

  Future<Either<AppFailure, T>> _guard<T>(Future<T> Function() op) async {
    try {
      return Right(await op());
    } on DioException catch (e) {
      final err = e.error;
      if (err is AppFailure) return Left(err);
      return const Left(UnknownFailure());
    } catch (_) {
      return const Left(
        UnknownFailure('Error procesando la respuesta del servidor'),
      );
    }
  }
}
