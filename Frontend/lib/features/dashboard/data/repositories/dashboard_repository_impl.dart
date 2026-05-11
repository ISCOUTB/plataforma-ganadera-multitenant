import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard_inteligencia.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remote;
  final DashboardLocalDataSource _local;

  DashboardRepositoryImpl({
    required DashboardRemoteDataSource remote,
    required DashboardLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  /// Cache-then-network en forma de Stream.
  ///
  /// Flujo:
  ///   1. Lee cache síncrono → si existe, yield inmediato (UI instantánea).
  ///   2. Llama al BFF remoto.
  ///   3. Al recibir OK: persiste en cache y yield el nuevo summary.
  ///
  /// Observa que los errores de red NO rompen el stream si hay cache:
  /// preferimos mostrar datos "viejos pero útiles" en una finca sin señal.
  @override
  Stream<Either<AppFailure, DashboardSummary>> watchSummary(
    String tenantId, {
    String? fincaId,
  }) async* {
    // ---- 1. Cache inmediato ----------------------------------------
    final cached = _local.readSummary(tenantId, fincaId: fincaId);
    if (cached != null) {
      yield Right(cached.toEntity());
    }

    // ---- 2. Llamada remota -----------------------------------------
    try {
      final fresh = await _remote.getSummary(fincaId: fincaId);
      await _local.saveSummary(tenantId, fresh, fincaId: fincaId);
      // ---- 3. Yield del dato fresco ------------------------------
      yield Right(fresh.toEntity());
    } on DioException catch (e) {
      // Si hay cache, no propagamos el error — el usuario ya ve data.
      if (cached != null) return;
      final err = e.error;
      yield Left(err is AppFailure ? err : const UnknownFailure());
    } catch (_) {
      if (cached != null) return;
      yield const Left(
        UnknownFailure('Error procesando la respuesta del servidor'),
      );
    }
  }

  @override
  Future<void> clearLocalCache(String tenantId) => _local.clear(tenantId);

  @override
  Future<Either<AppFailure, DashboardInteligencia>> getInteligencia({
    String? fincaId,
  }) async {
    try {
      final res = await _remote.getInteligencia(fincaId: fincaId);
      return Right(res.toEntity());
    } on DioException catch (e) {
      final err = e.error;
      return Left(err is AppFailure ? err : const UnknownFailure());
    } catch (_) {
      return const Left(
        UnknownFailure('Error procesando inteligencia del dashboard'),
      );
    }
  }
}
