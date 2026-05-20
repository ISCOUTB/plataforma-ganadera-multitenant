import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/finca.dart';
import '../../domain/repositories/finca_repository.dart';
import '../datasources/finca_remote_datasource.dart';

class FincaRepositoryImpl implements FincaRepository {
  final FincaRemoteDataSource _remote;
  FincaRepositoryImpl({required FincaRemoteDataSource remote}) : _remote = remote;

  AppFailure _toFailure(DioException e) {
    final err = e.error;
    if (err is AppFailure) return err;
    return const UnknownFailure();
  }

  Future<Either<AppFailure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on DioException catch (e) {
      return Left(_toFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure('Error procesando la respuesta del servidor'),
      );
    }
  }

  @override
  Future<Either<AppFailure, PaginatedResponse<Finca>>> list({
    int page = 1,
    int limit = 20,
    String? nombre,
    String? ubicacion,
  }) =>
      _guard(() async {
        final dto = await _remote.list(
          page: page,
          limit: limit,
          nombre: nombre,
          ubicacion: ubicacion,
        );
        return PaginatedResponse<Finca>(
          data: dto.data.map((e) => e.toEntity()).toList(),
          total: dto.total,
          page: dto.page,
          lastPage: dto.lastPage,
        );
      });

  @override
  Future<Either<AppFailure, Finca>> getById(String id) =>
      _guard(() async => (await _remote.getById(id)).toEntity());

  @override
  Future<Either<AppFailure, Finca>> create(CreateFincaInput input) =>
      _guard(() async => (await _remote.create(input)).toEntity());

  @override
  Future<Either<AppFailure, Finca>> update(String id, UpdateFincaInput input) =>
      _guard(() async => (await _remote.update(id, input)).toEntity());

  @override
  Future<Either<AppFailure, Unit>> delete(String id) => _guard(() async {
        await _remote.delete(id);
        return unit;
      });
}
