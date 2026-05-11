import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/finanza.dart';
import '../../domain/repositories/finanza_repository.dart';
import '../datasources/finanza_remote_datasource.dart';

class FinanzaRepositoryImpl implements FinanzaRepository {
  final FinanzaRemoteDataSource _remote;
  FinanzaRepositoryImpl({required FinanzaRemoteDataSource remote})
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
  Future<Either<AppFailure, PaginatedResponse<Finanza>>> list({
    int page = 1,
    int limit = 20,
    TipoMovimiento? tipo,
    String? categoria,
    String? fincaId,
  }) =>
      _guard(() async {
        final dto = await _remote.list(
          page: page,
          limit: limit,
          tipo: tipo,
          categoria: categoria,
          fincaId: fincaId,
        );
        return PaginatedResponse<Finanza>(
          data: dto.data.map((e) => e.toEntity()).toList(),
          total: dto.total,
          page: dto.page,
          lastPage: dto.lastPage,
        );
      });

  @override
  Future<Either<AppFailure, Finanza>> getById(String id) =>
      _guard(() async => (await _remote.getById(id)).toEntity());

  @override
  Future<Either<AppFailure, FinanzasResumen>> getResumen({String? fincaId}) =>
      _guard(() async =>
          (await _remote.getResumen(fincaId: fincaId)).toEntity());

  @override
  Future<Either<AppFailure, Finanza>> create(CreateFinanzaInput input) =>
      _guard(() async => (await _remote.create(input)).toEntity());

  @override
  Future<Either<AppFailure, Finanza>> update(
          String id, UpdateFinanzaInput input) =>
      _guard(() async => (await _remote.update(id, input)).toEntity());

  @override
  Future<Either<AppFailure, Unit>> delete(String id) => _guard(() async {
        await _remote.delete(id);
        return unit;
      });
}
