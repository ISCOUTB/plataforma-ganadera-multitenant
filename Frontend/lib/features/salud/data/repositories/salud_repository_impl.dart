import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/salud.dart';
import '../../domain/repositories/salud_repository.dart';
import '../datasources/salud_remote_datasource.dart';

class SaludRepositoryImpl implements SaludRepository {
  final SaludRemoteDataSource _remote;
  SaludRepositoryImpl({required SaludRemoteDataSource remote}) : _remote = remote;

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
  Future<Either<AppFailure, PaginatedResponse<Salud>>> list({
    int page = 1,
    int limit = 20,
    TipoIntervencion? tipoIntervencion,
    String? fincaId,
  }) =>
      _guard(() async {
        final dto = await _remote.list(
          page: page,
          limit: limit,
          tipoIntervencion: tipoIntervencion,
          fincaId: fincaId,
        );
        return PaginatedResponse<Salud>(
          data: dto.data.map((e) => e.toEntity()).toList(),
          total: dto.total,
          page: dto.page,
          lastPage: dto.lastPage,
        );
      });

  @override
  Future<Either<AppFailure, Salud>> getById(int id) =>
      _guard(() async => (await _remote.getById(id)).toEntity());

  @override
  Future<Either<AppFailure, SaludAlertas>> getAlertas() => _guard(() async {
        final raw = await _remote.getAlertas();
        return SaludAlertas(
          proximas: raw['proximas']!.map((e) => e.toEntity()).toList(),
          vencidas: raw['vencidas']!.map((e) => e.toEntity()).toList(),
        );
      });

  @override
  Future<Either<AppFailure, Salud>> create(CreateSaludInput input) =>
      _guard(() async => (await _remote.create(input)).toEntity());

  @override
  Future<Either<AppFailure, Salud>> update(int id, UpdateSaludInput input) =>
      _guard(() async => (await _remote.update(id, input)).toEntity());

  @override
  Future<Either<AppFailure, Unit>> delete(int id) => _guard(() async {
        await _remote.delete(id);
        return unit;
      });
}
