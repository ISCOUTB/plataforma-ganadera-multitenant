import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/tenant_summary.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remote;
  AdminRepositoryImpl({required AdminRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<Either<AppFailure, List<TenantSummary>>> listTenants() =>
      _guard(() => _remote.listTenants());

  @override
  Future<Either<AppFailure, List<AdminUser>>> listAllUsers() =>
      _guard(() => _remote.listAllUsers());

  @override
  Future<Either<AppFailure, AdminUser>> createUser({
    required String email,
    required String password,
    required String nombre,
    required String tenantId,
    String? rol,
    String? telefono,
  }) =>
      _guard(() => _remote.createUser(
            email: email,
            password: password,
            nombre: nombre,
            tenantId: tenantId,
            rol: rol,
            telefono: telefono,
          ));

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
