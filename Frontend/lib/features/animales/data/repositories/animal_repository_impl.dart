import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../datasources/animal_remote_datasource.dart';

class AnimalRepositoryImpl implements AnimalRepository {
  final AnimalRemoteDataSource _remote;
  AnimalRepositoryImpl({required AnimalRemoteDataSource remote})
      : _remote = remote;

  AppFailure _toFailure(DioException e) {
    final err = e.error;
    if (err is AppFailure) return err;
    return const UnknownFailure();
  }

  /// Wrapper que cataloga DioException y CUALQUIER otra excepción
  /// (TypeError, FormatException, etc.) en un [AppFailure]. Sin esto,
  /// un cast roto en el mapper deja al bloc colgado en `loading`.
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
  Future<Either<AppFailure, PaginatedResponse<Animal>>> list({
    int page = 1,
    int limit = 20,
    AnimalFilter filter = const AnimalFilter(),
    String? fincaId,
  }) =>
      _guard(() async {
        final dto = await _remote.list(
          page: page,
          limit: limit,
          filter: filter,
          fincaId: fincaId,
        );
        return PaginatedResponse<Animal>(
          data: dto.data.map((e) => e.toEntity()).toList(),
          total: dto.total,
          page: dto.page,
          lastPage: dto.lastPage,
        );
      });

  @override
  Future<Either<AppFailure, Animal>> getById(int id) =>
      _guard(() async => (await _remote.getById(id)).toEntity());

  @override
  Future<Either<AppFailure, AnimalCostos>> getCostos(int id) =>
      _guard(() async => (await _remote.getCostos(id)).toEntity());

  @override
  Future<Either<AppFailure, Animal>> create(CreateAnimalInput input) =>
      _guard(() async => (await _remote.create(input)).toEntity());

  @override
  Future<Either<AppFailure, Animal>> update(int id, UpdateAnimalInput input) =>
      _guard(() async => (await _remote.update(id, input)).toEntity());

  @override
  Future<Either<AppFailure, Unit>> delete(int id) => _guard(() async {
        await _remote.delete(id);
        return unit;
      });

  @override
  Future<Either<AppFailure, Animal>> vender(int id, VenderAnimalInput input) =>
      _guard(() async => (await _remote.vender(id, input)).toEntity());

  @override
  Future<Either<AppFailure, List<Map<String, dynamic>>>> getTimeline(int id) =>
      _guard(() async => await _remote.getTimeline(id));
}
