import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/reproduccion.dart';
import '../../domain/repositories/reproduccion_repository.dart';
import '../datasources/reproduccion_remote_datasource.dart';

class ReproduccionRepositoryImpl implements ReproduccionRepository {
  final ReproduccionRemoteDataSource _remote;
  ReproduccionRepositoryImpl({required ReproduccionRemoteDataSource remote})
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
  Future<Either<AppFailure, PaginatedResponse<Reproduccion>>> list({
    int page = 1,
    int limit = 20,
    String? fincaId,
  }) =>
      _guard(() async {
        final dto = await _remote.list(
          page: page,
          limit: limit,
          fincaId: fincaId,
        );
        return PaginatedResponse<Reproduccion>(
          data: dto.data.map((e) => e.toEntity()).toList(),
          total: dto.total,
          page: dto.page,
          lastPage: dto.lastPage,
        );
      });

  @override
  Future<Either<AppFailure, Reproduccion>> getById(String id) =>
      _guard(() async => (await _remote.getById(id)).toEntity());

  @override
  Future<Either<AppFailure, ReproduccionAlertas>> getAlertas() =>
      _guard(() async {
        final raw = await _remote.getAlertas();
        return ReproduccionAlertas(
          partosProximos:
              raw['partos_proximos']!.map((e) => e.toEntity()).toList(),
          partosVencidos:
              raw['partos_vencidos']!.map((e) => e.toEntity()).toList(),
          enCelo: raw['en_celo']!.map((e) => e.toEntity()).toList(),
        );
      });

  @override
  Future<Either<AppFailure, Reproduccion>> create(CreateReproduccionInput input) =>
      _guard(() async => (await _remote.create(input)).toEntity());

  @override
  Future<Either<AppFailure, Reproduccion>> update(
    String id,
    UpdateReproduccionInput input,
  ) =>
      _guard(() async => (await _remote.update(id, input)).toEntity());

  @override
  Future<Either<AppFailure, Unit>> delete(String id) => _guard(() async {
        await _remote.delete(id);
        return unit;
      });
}
