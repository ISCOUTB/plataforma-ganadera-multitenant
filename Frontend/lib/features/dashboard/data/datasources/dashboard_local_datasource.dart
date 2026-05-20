import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/dashboard_summary_model.dart';

/// Cache local del payload del BFF `GET /api/dashboard/summary`.
///
/// Persiste el JSON crudo en `shared_preferences` para que el Dashboard
/// pueda renderizar INSTANTÁNEAMENTE al abrir la app en fincas sin
/// conexión, mientras la llamada remota refresca en segundo plano.
///
/// La clave se compone de `tenantId + ':' + (fincaId ?? '__all__')` para
/// que rotar el selector de finca en la UI no sobrescriba el cache de
/// otra finca: cada vista filtrada vive en su propia entrada.
class DashboardLocalDataSource {
  static const String _kPrefixSummary = 'farmlink.dashboard_summary.';
  static const String _kPrefixUpdatedAt = 'farmlink.dashboard_summary_at.';
  static const String _kAllFincas = '__all__';

  final SharedPreferences _prefs;

  DashboardLocalDataSource(this._prefs);

  String _scope(String tenantId, String? fincaId) =>
      '$tenantId:${fincaId ?? _kAllFincas}';

  /// Lee el summary cacheado para [tenantId] (y opcionalmente [fincaId]).
  /// Devuelve `null` si no existe o si el JSON está corrupto.
  DashboardSummaryModel? readSummary(String tenantId, {String? fincaId}) {
    final raw = _prefs.getString(_kPrefixSummary + _scope(tenantId, fincaId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return DashboardSummaryModel.fromJson(map);
    } catch (_) {
      // Cache corrupto → lo ignoramos y forzamos refetch remoto.
      return null;
    }
  }

  /// Marca de tiempo (ISO-8601) del último write. Útil para UI de
  /// "actualizado hace X minutos" en modo offline.
  DateTime? readUpdatedAt(String tenantId, {String? fincaId}) {
    final raw = _prefs.getString(_kPrefixUpdatedAt + _scope(tenantId, fincaId));
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Guarda el summary en cache con el timestamp de ahora.
  /// Sobrescribe cualquier versión previa para el mismo tenant+finca.
  Future<void> saveSummary(
    String tenantId,
    DashboardSummaryModel model, {
    String? fincaId,
  }) async {
    final scope = _scope(tenantId, fincaId);
    await _prefs.setString(
      _kPrefixSummary + scope,
      jsonEncode(model.toJson()),
    );
    await _prefs.setString(
      _kPrefixUpdatedAt + scope,
      DateTime.now().toIso8601String(),
    );
  }

  /// Borra TODAS las entradas (todas las fincas) del tenant. Llamar en
  /// logout para no filtrar datos entre sesiones distintas.
  Future<void> clear(String tenantId) async {
    final summaryPrefix = _kPrefixSummary + tenantId;
    final updatedAtPrefix = _kPrefixUpdatedAt + tenantId;
    final keys = _prefs
        .getKeys()
        .where((k) =>
            k.startsWith(summaryPrefix) || k.startsWith(updatedAtPrefix))
        .toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }

  /// Borra el cache de TODOS los tenants. Usado en logout global o reset.
  Future<void> clearAll() async {
    final keys = _prefs.getKeys().where(
          (k) =>
              k.startsWith(_kPrefixSummary) || k.startsWith(_kPrefixUpdatedAt),
        );
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}
