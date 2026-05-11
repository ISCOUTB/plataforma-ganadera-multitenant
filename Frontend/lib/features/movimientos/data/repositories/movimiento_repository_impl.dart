import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/movimiento.dart';
import '../../domain/repositories/movimiento_repository.dart';
import '../datasources/movimiento_remote_datasource.dart';

class MovimientoRepositoryImpl implements MovimientoRepository {
  final MovimientoRemoteDataSource _remote;
  MovimientoRepositoryImpl({required MovimientoRemoteDataSource remote})
      : _remote = remote;

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
  Future<Either<AppFailure, PaginatedResponse<Movimiento>>> list({
    int page = 1,
    int limit = 20,
  }) =>
      _guard(() async {
        final dto = await _remote.list(page: page, limit: limit);
        return PaginatedResponse<Movimiento>(
          data: dto.data.map((e) => e.toEntity()).toList(),
          total: dto.total,
          page: dto.page,
          lastPage: dto.lastPage,
        );
      });

  @override
  Future<Either<AppFailure, List<Movimiento>>> getByAnimal(int animalId) =>
      _guard(() async {
        final list = await _remote.getByAnimal(animalId);
        return list.map((e) => e.toEntity()).toList();
      });

  @override
  Future<Either<AppFailure, Movimiento>> create(CreateMovimientoInput input) =>
      _guard(() async => (await _remote.create(input)).toEntity());
}
