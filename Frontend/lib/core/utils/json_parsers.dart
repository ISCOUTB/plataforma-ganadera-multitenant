/// Parsea un valor JSON heterogéneo (num, string, null) a [double].
///
/// PostgreSQL/TypeORM serializan columnas `decimal/numeric` como string
/// (`"515.00"`), no como número, para preservar precisión. Este helper
/// absorbe esa diferencia sin lanzar `TypeError`.
double? parseDouble(dynamic raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toDouble();
  if (raw is String) {
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }
  return null;
}

/// Parsea un valor JSON heterogéneo (num, string, null) a [int].
int? parseInt(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) {
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }
  return null;
}
