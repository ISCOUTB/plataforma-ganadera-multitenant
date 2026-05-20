import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/alertas_summary.dart';
import '../../domain/repositories/alertas_repository.dart';
import '../datasources/alertas_remote_datasource.dart';

class AlertasRepositoryImpl implements AlertasRepository {
  final AlertasRemoteDataSource _remote;
  AlertasRepositoryImpl({required AlertasRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<Either<AppFailure, AlertasSummary>> getAll() async {
    try {
      final json = await _remote.getAll();
      return Right(_parse(json));
    } on DioException catch (e) {
      final err = e.error;
      if (err is AppFailure) return Left(err);
      return const Left(UnknownFailure());
    } catch (_) {
      return const Left(
        UnknownFailure('Error procesando la respuesta del servidor'),
      );
    }
  }

  AlertasSummary _parse(Map<String, dynamic> json) {
    final salud = (json['salud'] as Map<String, dynamic>?) ?? const {};
    final repro =
        (json['reproduccion'] as Map<String, dynamic>?) ?? const {};
    final resumen = (json['resumen'] as Map<String, dynamic>?) ?? const {};
    final porSev =
        (resumen['por_severidad'] as Map<String, dynamic>?) ?? const {};
    final priorizadas =
        (json['alertas_priorizadas'] as List<dynamic>?) ?? const [];

    return AlertasSummary(
      saludProximas: parseInt(salud['proximas']) ?? 0,
      saludVencidas: parseInt(salud['vencidas']) ?? 0,
      partosProximos: parseInt(repro['partos_proximos']) ?? 0,
      partosVencidos: parseInt(repro['partos_vencidos']) ?? 0,
      enCelo: parseInt(repro['en_celo']) ?? 0,
      totalAlertas: parseInt(resumen['total_alertas']) ?? 0,
      urgentes: parseInt(resumen['requiere_atencion_urgente']) ?? 0,
      porSeveridad: {
        AlertaSeverity.high: parseInt(porSev['HIGH']) ?? 0,
        AlertaSeverity.medium: parseInt(porSev['MEDIUM']) ?? 0,
        AlertaSeverity.low: parseInt(porSev['LOW']) ?? 0,
      },
      alertasPriorizadas: priorizadas
          .map((e) => e as Map<String, dynamic>)
          .map((m) => AlertaPrioritaria(
                tipo: (m['tipo'] as String?) ?? '—',
                severity: AlertaSeverityX.fromApi(m['severity'] as String?),
                detalle: (m['detalle'] as Map<String, dynamic>?) ?? const {},
              ))
          .toList(),
    );
  }
}
