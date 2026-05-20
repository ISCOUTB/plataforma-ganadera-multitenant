import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_inteligencia.dart';
import '../entities/dashboard_summary.dart';

abstract class DashboardRepository {
  /// Endpoint BFF `GET /api/dashboard/summary` consumido por la UI "Bento
  /// Box", con estrategia **cache-then-network**:
  ///
  ///   1. Emite INMEDIATAMENTE el summary cacheado en disco (si existe)
  ///      para que la UI aparezca al instante, incluso sin conexión.
  ///   2. Dispara la llamada remota en paralelo.
  ///   3. Al recibir respuesta OK del backend: persiste el nuevo JSON
  ///      en disco y emite el summary actualizado. La UI re-renderiza.
  ///
  /// Si `fincaId` es null se obtiene la vista global del tenant; en caso
  /// contrario se filtran los KPIs a esa finca (el backend valida
  /// ownership). El cache local usa clave compuesta `tenantId+fincaId`
  /// para que rotar entre fincas no se sobrescriba.
  ///
  /// Si la red falla y hay cache: emite sólo el cache (no error).
  /// Si la red falla y NO hay cache: emite `Left(failure)`.
  Stream<Either<AppFailure, DashboardSummary>> watchSummary(
    String tenantId, {
    String? fincaId,
  });

  /// Limpia el cache local del tenant (llamar en logout).
  Future<void> clearLocalCache(String tenantId);

  /// Endpoint `GET /api/dashboard/inteligencia` — datos costosos (5 queries)
  /// servidos en su propio endpoint para carga lazy. No tiene cache local;
  /// si la red falla retorna `Left(failure)` y la sección muestra error
  /// inline sin afectar el resto del dashboard.
  Future<Either<AppFailure, DashboardInteligencia>> getInteligencia({
    String? fincaId,
  });
}
