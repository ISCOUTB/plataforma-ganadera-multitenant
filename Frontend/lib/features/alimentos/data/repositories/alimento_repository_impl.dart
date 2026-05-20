import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/alimento.dart';
import '../../domain/repositories/alimento_repository.dart';
import '../datasources/alimento_remote_datasource.dart';

class AlimentoRepositoryImpl implements AlimentoRepository {
  final AlimentoRemoteDataSource _remote;
  AlimentoRepositoryImpl({required AlimentoRemoteDataSource remote})
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
  Future<Either<AppFailure, PaginatedResponse<Alimento>>> list({
    int page = 1,
    int limit = 20,
  }) =>
      _guard(() async {
        final dto = await _remote.list(page: page, limit: limit);
        return PaginatedResponse<Alimento>(
          data: dto.data.map((e) => e.toEntity()).toList(),
          total: dto.total,
          page: dto.page,
          lastPage: dto.lastPage,
        );
      });

  @override
  Future<Either<AppFailure, Alimento>> getById(String id) =>
      _guard(() async => (await _remote.getById(id)).toEntity());

  @override
  Future<Either<AppFailure, Alimento>> create(CreateAlimentoInput input) =>
      _guard(() async => (await _remote.create(input)).toEntity());

  @override
  Future<Either<AppFailure, Alimento>> update(
    String id,
    UpdateAlimentoInput input,
  ) =>
      _guard(() async => (await _remote.update(id, input)).toEntity());

  @override
  Future<Either<AppFailure, Unit>> delete(String id) => _guard(() async {
        await _remote.delete(id);
        return unit;
      });
}
