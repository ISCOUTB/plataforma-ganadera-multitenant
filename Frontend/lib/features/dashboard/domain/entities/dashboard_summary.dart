import 'package:equatable/equatable.dart';

/// Nivel de urgencia de una alerta crítica.
enum AlertUrgency { high, medium, low }

extension AlertUrgencyX on AlertUrgency {
  String get apiValue => switch (this) {
        AlertUrgency.high => 'high',
        AlertUrgency.medium => 'medium',
        AlertUrgency.low => 'low',
      };

  static AlertUrgency fromApi(String? raw) => switch (raw) {
        'high' => AlertUrgency.high,
        'low' => AlertUrgency.low,
        _ => AlertUrgency.medium,
      };
}

/// Distribución demográfica del hato (Bento card "Demografía").
class DemographyData extends Equatable {
  final int produccionPct;
  final int crecimientoPct;
  final int secasPct;
  final int total;

  const DemographyData({
    required this.produccionPct,
    required this.crecimientoPct,
    required this.secasPct,
    required this.total,
  });

  @override
  List<Object?> get props => [produccionPct, crecimientoPct, secasPct, total];
}

/// Ocupación del terreno en hectáreas (Bento card "Ocupación").
class OccupancyData extends Equatable {
  final int totalHectares;
  final int usedHectares;

  const OccupancyData({
    required this.totalHectares,
    required this.usedHectares,
  });

  /// Porcentaje usado (0–100). Evita división por cero.
  int get usedPct =>
      totalHectares > 0 ? ((usedHectares / totalHectares) * 100).round() : 0;

  @override
  List<Object?> get props => [totalHectares, usedHectares];
}

/// Alerta crítica individual (Bento card "Alertas Críticas").
class CriticalAlert extends Equatable {
  final String id;
  final String animalId;
  final String reason;
  final AlertUrgency urgency;

  const CriticalAlert({
    required this.id,
    required this.animalId,
    required this.reason,
    required this.urgency,
  });

  @override
  List<Object?> get props => [id, animalId, reason, urgency];
}

/// Movimiento reciente entre potreros (Bento card "Movimientos Recientes").
class RecentMovement extends Equatable {
  final String id;
  final String time;
  final String origin;
  final String destination;

  const RecentMovement({
    required this.id,
    required this.time,
    required this.origin,
    required this.destination,
  });

  @override
  List<Object?> get props => [id, time, origin, destination];
}

/// Distribución por género (donut macho/hembra).
class GenderSplitData extends Equatable {
  final int machos;
  final int hembras;
  final int otros;
  final int total;

  const GenderSplitData({
    required this.machos,
    required this.hembras,
    this.otros = 0,
    required this.total,
  });

  @override
  List<Object?> get props => [machos, hembras, otros, total];
}

/// Resumen financiero (bar chart ingresos vs gastos).
class FinancesSummaryData extends Equatable {
  final double totalIngresos;
  final double totalGastos;
  final double balance;

  const FinancesSummaryData({
    required this.totalIngresos,
    required this.totalGastos,
    required this.balance,
  });

  @override
  List<Object?> get props => [totalIngresos, totalGastos, balance];
}

/// Potrero con ocupación (bar horizontal + mapa visual).
class PotreroRankData extends Equatable {
  final String id;
  final String nombre;
  final int capacidad;
  final int ocupacion;
  final double area;
  final String? estado;

  const PotreroRankData({
    required this.id,
    required this.nombre,
    required this.capacidad,
    required this.ocupacion,
    this.area = 0,
    this.estado,
  });

  double get pct => capacidad > 0 ? ocupacion / capacidad : 0;

  @override
  List<Object?> get props => [id, nombre, capacidad, ocupacion, area, estado];
}

/// Payload completo devuelto por `GET /api/dashboard/summary` (BFF).
class DashboardSummary extends Equatable {
  final DemographyData demography;
  final OccupancyData occupancy;
  final List<CriticalAlert> criticalAlerts;
  final List<RecentMovement> recentMovements;
  final GenderSplitData genderSplit;
  final FinancesSummaryData financesSummary;
  final List<PotreroRankData> topPotreros;
  final List<PotreroRankData> allPotreros;
  final TrendsData trends;

  const DashboardSummary({
    required this.demography,
    required this.occupancy,
    required this.criticalAlerts,
    required this.recentMovements,
    required this.genderSplit,
    required this.financesSummary,
    required this.topPotreros,
    required this.allPotreros,
    required this.trends,
  });

  @override
  List<Object?> get props => [
        demography,
        occupancy,
        criticalAlerts,
        recentMovements,
        genderSplit,
        financesSummary,
        topPotreros,
        allPotreros,
        trends,
      ];
}

/// Series de tendencias semanales para sparklines.
///
/// `weeks[i]` es el inicio de la semana ISO correspondiente a `values[i]`.
/// Si el cache viejo no traía `week`, `weeks` queda vacío y la UI omite el
/// tooltip temporal sin romper nada.
class TrendSeries extends Equatable {
  final List<double> values;
  final List<DateTime> weeks;

  const TrendSeries({required this.values, this.weeks = const []});

  double get lastValue => values.isEmpty ? 0 : values.last;
  double get prevValue => values.length < 2 ? 0 : values[values.length - 2];

  /// Delta porcentual vs el periodo anterior.
  double get deltaPct {
    if (prevValue == 0) return values.isEmpty ? 0 : 100;
    return ((lastValue - prevValue) / prevValue) * 100;
  }

  bool get isPositive => deltaPct >= 0;

  /// Devuelve la semana asociada a `values[i]` o `null` si no se conoce.
  DateTime? weekAt(int i) =>
      (i >= 0 && i < weeks.length) ? weeks[i] : null;

  @override
  List<Object?> get props => [values, weeks];
}

class TrendsData extends Equatable {
  final TrendSeries animales;
  final TrendSeries ingresos;
  final TrendSeries gastos;
  final TrendSeries salud;

  const TrendsData({
    required this.animales,
    required this.ingresos,
    required this.gastos,
    required this.salud,
  });

  @override
  List<Object?> get props => [animales, ingresos, gastos, salud];
}
