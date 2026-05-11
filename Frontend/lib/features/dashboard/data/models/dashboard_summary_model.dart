import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Modelo espejo del payload `GET /api/dashboard/summary`.
/// Tiene `toJson` porque el cache local guarda la respuesta serializada.
class DashboardSummaryModel {
  final DemographyModel demography;
  final OccupancyModel occupancy;
  final List<CriticalAlertModel> criticalAlerts;
  final List<RecentMovementModel> recentMovements;
  final GenderSplitModel genderSplit;
  final FinancesSummaryModel financesSummary;
  final List<PotreroRankModel> topPotreros;
  final List<PotreroRankModel> allPotreros;
  final TrendsModel trends;

  DashboardSummaryModel({
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

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      DashboardSummaryModel(
        demography: DemographyModel.fromJson(
          (json['demography'] as Map<String, dynamic>?) ?? const {},
        ),
        occupancy: OccupancyModel.fromJson(
          (json['occupancy'] as Map<String, dynamic>?) ?? const {},
        ),
        criticalAlerts: ((json['critical_alerts'] as List<dynamic>?) ?? const [])
            .map((e) => CriticalAlertModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        recentMovements:
            ((json['recent_movements'] as List<dynamic>?) ?? const [])
                .map((e) =>
                    RecentMovementModel.fromJson(e as Map<String, dynamic>))
                .toList(),
        genderSplit: GenderSplitModel.fromJson(
          (json['gender_split'] as Map<String, dynamic>?) ?? const {},
        ),
        financesSummary: FinancesSummaryModel.fromJson(
          (json['finances_summary'] as Map<String, dynamic>?) ?? const {},
        ),
        topPotreros: ((json['top_potreros'] as List<dynamic>?) ?? const [])
            .map((e) => PotreroRankModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        allPotreros: ((json['all_potreros'] as List<dynamic>?) ?? const [])
            .map((e) => PotreroRankModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        trends: TrendsModel.fromJson(
          (json['trends'] as Map<String, dynamic>?) ?? const {},
        ),
      );

  Map<String, dynamic> toJson() => {
        'demography': demography.toJson(),
        'occupancy': occupancy.toJson(),
        'critical_alerts': criticalAlerts.map((e) => e.toJson()).toList(),
        'recent_movements': recentMovements.map((e) => e.toJson()).toList(),
        'gender_split': genderSplit.toJson(),
        'finances_summary': financesSummary.toJson(),
        'top_potreros': topPotreros.map((e) => e.toJson()).toList(),
        'all_potreros': allPotreros.map((e) => e.toJson()).toList(),
        'trends': trends.toJson(),
      };

  DashboardSummary toEntity() => DashboardSummary(
        demography: demography.toEntity(),
        occupancy: occupancy.toEntity(),
        criticalAlerts: criticalAlerts.map((e) => e.toEntity()).toList(),
        recentMovements: recentMovements.map((e) => e.toEntity()).toList(),
        genderSplit: genderSplit.toEntity(),
        financesSummary: financesSummary.toEntity(),
        topPotreros: topPotreros.map((e) => e.toEntity()).toList(),
        allPotreros: allPotreros.map((e) => e.toEntity()).toList(),
        trends: trends.toEntity(),
      );
}

class GenderSplitModel {
  final int machos;
  final int hembras;
  final int otros;
  final int total;

  GenderSplitModel({
    required this.machos,
    required this.hembras,
    this.otros = 0,
    required this.total,
  });

  factory GenderSplitModel.fromJson(Map<String, dynamic> json) =>
      GenderSplitModel(
        machos: parseInt(json['machos']) ?? 0,
        hembras: parseInt(json['hembras']) ?? 0,
        otros: parseInt(json['otros']) ?? 0,
        total: parseInt(json['total']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'machos': machos,
        'hembras': hembras,
        'otros': otros,
        'total': total,
      };

  GenderSplitData toEntity() => GenderSplitData(
        machos: machos,
        hembras: hembras,
        otros: otros,
        total: total,
      );
}

class FinancesSummaryModel {
  final double totalIngresos;
  final double totalGastos;
  final double balance;

  FinancesSummaryModel({
    required this.totalIngresos,
    required this.totalGastos,
    required this.balance,
  });

  factory FinancesSummaryModel.fromJson(Map<String, dynamic> json) =>
      FinancesSummaryModel(
        totalIngresos: parseDouble(json['total_ingresos']) ?? 0,
        totalGastos: parseDouble(json['total_gastos']) ?? 0,
        balance: parseDouble(json['balance']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'total_ingresos': totalIngresos,
        'total_gastos': totalGastos,
        'balance': balance,
      };

  FinancesSummaryData toEntity() => FinancesSummaryData(
        totalIngresos: totalIngresos,
        totalGastos: totalGastos,
        balance: balance,
      );
}

class PotreroRankModel {
  final String id;
  final String nombre;
  final int capacidad;
  final int ocupacion;
  final double area;
  final String? estado;

  PotreroRankModel({
    required this.id,
    required this.nombre,
    required this.capacidad,
    required this.ocupacion,
    this.area = 0,
    this.estado,
  });

  factory PotreroRankModel.fromJson(Map<String, dynamic> json) =>
      PotreroRankModel(
        id: (json['pk_id_potrero'] as String?) ?? '',
        nombre: (json['nombre_potrero'] as String?) ?? '',
        capacidad: parseInt(json['capacidad_animales']) ?? 0,
        ocupacion: parseInt(json['cantidad_animales']) ?? 0,
        area: parseDouble(json['area']) ?? 0,
        estado: json['estado'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'pk_id_potrero': id,
        'nombre_potrero': nombre,
        'capacidad_animales': capacidad,
        'cantidad_animales': ocupacion,
        'area': area,
        'estado': estado,
      };

  PotreroRankData toEntity() => PotreroRankData(
        id: id,
        nombre: nombre,
        capacidad: capacidad,
        ocupacion: ocupacion,
        area: area,
        estado: estado,
      );
}

class DemographyModel {
  final int produccionPct;
  final int crecimientoPct;
  final int secasPct;
  final int total;

  DemographyModel({
    required this.produccionPct,
    required this.crecimientoPct,
    required this.secasPct,
    required this.total,
  });

  factory DemographyModel.fromJson(Map<String, dynamic> json) => DemographyModel(
        produccionPct: parseInt(json['produccion_pct']) ?? 0,
        crecimientoPct: parseInt(json['crecimiento_pct']) ?? 0,
        secasPct: parseInt(json['secas_pct']) ?? 0,
        total: parseInt(json['total']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'produccion_pct': produccionPct,
        'crecimiento_pct': crecimientoPct,
        'secas_pct': secasPct,
        'total': total,
      };

  DemographyData toEntity() => DemographyData(
        produccionPct: produccionPct,
        crecimientoPct: crecimientoPct,
        secasPct: secasPct,
        total: total,
      );
}

class OccupancyModel {
  final int totalHectares;
  final int usedHectares;

  OccupancyModel({required this.totalHectares, required this.usedHectares});

  factory OccupancyModel.fromJson(Map<String, dynamic> json) => OccupancyModel(
        totalHectares: parseInt(json['total_hectares']) ?? 0,
        usedHectares: parseInt(json['used_hectares']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'total_hectares': totalHectares,
        'used_hectares': usedHectares,
      };

  OccupancyData toEntity() => OccupancyData(
        totalHectares: totalHectares,
        usedHectares: usedHectares,
      );
}

class CriticalAlertModel {
  final String id;
  final String animalId;
  final String reason;
  final String urgency;

  CriticalAlertModel({
    required this.id,
    required this.animalId,
    required this.reason,
    required this.urgency,
  });

  factory CriticalAlertModel.fromJson(Map<String, dynamic> json) =>
      CriticalAlertModel(
        id: json['id']?.toString() ?? '',
        animalId: (json['animal_id'] as String?) ?? '',
        reason: (json['reason'] as String?) ?? '',
        urgency: (json['urgency'] as String?) ?? 'medium',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'animal_id': animalId,
        'reason': reason,
        'urgency': urgency,
      };

  CriticalAlert toEntity() => CriticalAlert(
        id: id,
        animalId: animalId,
        reason: reason,
        urgency: AlertUrgencyX.fromApi(urgency),
      );
}

class RecentMovementModel {
  final String id;
  final String time;
  final String origin;
  final String destination;

  RecentMovementModel({
    required this.id,
    required this.time,
    required this.origin,
    required this.destination,
  });

  factory RecentMovementModel.fromJson(Map<String, dynamic> json) =>
      RecentMovementModel(
        id: json['id']?.toString() ?? '',
        time: (json['time'] as String?) ?? '—',
        origin: (json['origin'] as String?) ?? '—',
        destination: (json['destination'] as String?) ?? '—',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time,
        'origin': origin,
        'destination': destination,
      };

  RecentMovement toEntity() => RecentMovement(
        id: id,
        time: time,
        origin: origin,
        destination: destination,
      );
}

class TrendPointModel {
  final DateTime? week;
  final double value;

  TrendPointModel({required this.week, required this.value});

  factory TrendPointModel.fromJson(Map<String, dynamic> j) => TrendPointModel(
        week: DateTime.tryParse(j['week']?.toString() ?? ''),
        value: parseDouble(j['value']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        if (week != null) 'week': week!.toIso8601String(),
        'value': value,
      };
}

class TrendsModel {
  final List<TrendPointModel> animales;
  final List<TrendPointModel> ingresos;
  final List<TrendPointModel> gastos;
  final List<TrendPointModel> salud;

  TrendsModel({
    required this.animales,
    required this.ingresos,
    required this.gastos,
    required this.salud,
  });

  factory TrendsModel.fromJson(Map<String, dynamic> json) {
    List<TrendPointModel> parseList(String key) {
      final raw = json[key];
      if (raw is List) {
        return raw
            .map((e) => TrendPointModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return const [];
    }

    return TrendsModel(
      animales: parseList('animales'),
      ingresos: parseList('ingresos'),
      gastos: parseList('gastos'),
      salud: parseList('salud'),
    );
  }

  Map<String, dynamic> toJson() => {
        'animales': animales.map((p) => p.toJson()).toList(),
        'ingresos': ingresos.map((p) => p.toJson()).toList(),
        'gastos': gastos.map((p) => p.toJson()).toList(),
        'salud': salud.map((p) => p.toJson()).toList(),
      };

  TrendSeries _toSeries(List<TrendPointModel> points) {
    final values = points.map((p) => p.value).toList();
    final weeks = points
        .where((p) => p.week != null)
        .map((p) => p.week!)
        .toList();
    // Solo propagamos `weeks` si es una correspondencia 1-a-1 con `values`
    // (cache viejo o backend sin week ⇒ weeks vacío ⇒ UI sin tooltip).
    return TrendSeries(
      values: values,
      weeks: weeks.length == values.length ? weeks : const [],
    );
  }

  TrendsData toEntity() => TrendsData(
        animales: _toSeries(animales),
        ingresos: _toSeries(ingresos),
        gastos: _toSeries(gastos),
        salud: _toSeries(salud),
      );
}
