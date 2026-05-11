import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/potrero.dart';
import '../../domain/repositories/potrero_repository.dart';
import '../datasources/potrero_remote_datasource.dart';

class PotreroRepositoryImpl implements PotreroRepository {
  final PotreroRemoteDataSource _remote;
  PotreroRepositoryImpl({required PotreroRemoteDataSource remote})
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
  Future<Either<AppFailure, PaginatedResponse<Potrero>>> list({
    int page = 1,
    int limit = 20,
    String? fincaId,
  }) =>
      _guard(() async {
        final dto = await _remote.list(page: page, limit: limit, fincaId: fincaId);
        return PaginatedResponse<Potrero>(
          data: dto.data.map((e) => e.toEntity()).toList(),
          total: dto.total,
          page: dto.page,
          lastPage: dto.lastPage,
        );
      });

  @override
  Future<Either<AppFailure, Potrero>> getById(String id) =>
      _guard(() async => (await _remote.getById(id)).toEntity());

  @override
  Future<Either<AppFailure, PotreroOcupacion>> getOcupacion(String id) =>
      _guard(() async => (await _remote.getOcupacion(id)).toEntity());

  @override
  Future<Either<AppFailure, Potrero>> create(CreatePotreroInput input) =>
      _guard(() async => (await _remote.create(input)).toEntity());

  @override
  Future<Either<AppFailure, Potrero>> update(String id, UpdatePotreroInput input) =>
      _guard(() async => (await _remote.update(id, input)).toEntity());

  @override
  Future<Either<AppFailure, Unit>> delete(String id) => _guard(() async {
        await _remote.delete(id);
        return unit;
      });
}
