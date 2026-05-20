import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SecureStorageService storage,
  })  : _remote = remote,
        _storage = storage;

  @override
  Future<Either<AppFailure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remote.login(email: email, password: password);
      await _storage.saveTokens(
        access: dto.accessToken,
        refresh: dto.refreshToken,
      );
      return Right(dto.user.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<AppFailure, User>> register({
    required String email,
    required String password,
    required String nombre,
    required String tenantId,
    String? telefono,
  }) async {
    try {
      final user = await _remote.register(
        email: email,
        password: password,
        nombre: nombre,
        tenantId: tenantId,
        telefono: telefono,
      );
      // Tras registro, hacer login para obtener tokens.
      final loginDto = await _remote.login(email: email, password: password);
      await _storage.saveTokens(
        access: loginDto.accessToken,
        refresh: loginDto.refreshToken,
      );
      return Right(user.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<AppFailure, User>> getMe() async {
    try {
      final dto = await _remote.getMe();
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<AppFailure, Unit>> logout() async {
    try {
      await _remote.logout();
    } on DioException {
      // Ignoramos el error de red — siempre limpiamos local.
    } finally {
      await _storage.clear();
    }
    return const Right(unit);
  }

  AppFailure _mapDioError(DioException e) {
    final err = e.error;
    if (err is AppFailure) return err;
    return const UnknownFailure();
  }
}
