import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/dashboard_inteligencia.dart';

/// Modelo espejo del payload `GET /api/dashboard/inteligencia`.
/// No tiene `toJson` porque este endpoint no se cachea en disco — siempre
/// se solicita fresh al backend (datos derivados, no críticos para offline).
class DashboardInteligenciaModel {
  final CostoTotalAnimalesModel costoTotalAnimales;
  final List<AnimalCostosoModel> top5AnimalesCostosos;
  final int animalesSinPotrero;
  final EstimacionGananciaModel estimacionGanancia;

  DashboardInteligenciaModel({
    required this.costoTotalAnimales,
    required this.top5AnimalesCostosos,
    required this.animalesSinPotrero,
    required this.estimacionGanancia,
  });

  factory DashboardInteligenciaModel.fromJson(Map<String, dynamic> json) =>
      DashboardInteligenciaModel(
        costoTotalAnimales: CostoTotalAnimalesModel.fromJson(
          (json['costo_total_animales'] as Map<String, dynamic>?) ?? const {},
        ),
        top5AnimalesCostosos:
            ((json['top_5_animales_costosos'] as List<dynamic>?) ?? const [])
                .map((e) =>
                    AnimalCostosoModel.fromJson(e as Map<String, dynamic>))
                .toList(),
        animalesSinPotrero: parseInt(json['animales_sin_potrero']) ?? 0,
        estimacionGanancia: EstimacionGananciaModel.fromJson(
          (json['estimacion_ganancia'] as Map<String, dynamic>?) ?? const {},
        ),
      );

  DashboardInteligencia toEntity() => DashboardInteligencia(
        costoTotal: costoTotalAnimales.toEntity(),
        topAnimalesCostosos:
            top5AnimalesCostosos.map((e) => e.toEntity()).toList(),
        animalesSinPotrero: animalesSinPotrero,
        estimacionGanancia: estimacionGanancia.toEntity(),
      );
}

class CostoTotalAnimalesModel {
  final double costoSalud;
  final double costoAlimentacion;
  final double costoTotal;

  CostoTotalAnimalesModel({
    required this.costoSalud,
    required this.costoAlimentacion,
    required this.costoTotal,
  });

  factory CostoTotalAnimalesModel.fromJson(Map<String, dynamic> json) =>
      CostoTotalAnimalesModel(
        costoSalud: parseDouble(json['costo_salud']) ?? 0,
        costoAlimentacion: parseDouble(json['costo_alimentacion']) ?? 0,
        costoTotal: parseDouble(json['costo_total']) ?? 0,
      );

  CostoTotalAnimales toEntity() => CostoTotalAnimales(
        costoSalud: costoSalud,
        costoAlimentacion: costoAlimentacion,
        costoTotal: costoTotal,
      );
}

class AnimalCostosoModel {
  final String id;
  final String numeroIdentificacion;
  final double costoTotal;
  final double costoSalud;
  final double costoAlimentacion;

  AnimalCostosoModel({
    required this.id,
    required this.numeroIdentificacion,
    required this.costoTotal,
    required this.costoSalud,
    required this.costoAlimentacion,
  });

  factory AnimalCostosoModel.fromJson(Map<String, dynamic> json) =>
      AnimalCostosoModel(
        id: json['id']?.toString() ?? '',
        numeroIdentificacion:
            (json['numero_identificacion'] as String?) ?? '—',
        costoTotal: parseDouble(json['costo_total']) ?? 0,
        costoSalud: parseDouble(json['costo_salud']) ?? 0,
        costoAlimentacion: parseDouble(json['costo_alimentacion']) ?? 0,
      );

  AnimalCostoso toEntity() => AnimalCostoso(
        id: id,
        numeroIdentificacion: numeroIdentificacion,
        costoTotal: costoTotal,
        costoSalud: costoSalud,
        costoAlimentacion: costoAlimentacion,
      );
}

class EstimacionGananciaModel {
  final double totalVentas;
  final double costosVendidos;
  final double gananciaNeta;
  final int animalesVendidos;

  EstimacionGananciaModel({
    required this.totalVentas,
    required this.costosVendidos,
    required this.gananciaNeta,
    required this.animalesVendidos,
  });

  factory EstimacionGananciaModel.fromJson(Map<String, dynamic> json) =>
      EstimacionGananciaModel(
        totalVentas: parseDouble(json['total_ventas']) ?? 0,
        costosVendidos: parseDouble(json['costos_vendidos']) ?? 0,
        gananciaNeta: parseDouble(json['ganancia_neta']) ?? 0,
        animalesVendidos: parseInt(json['animales_vendidos']) ?? 0,
      );

  EstimacionGanancia toEntity() => EstimacionGanancia(
        totalVentas: totalVentas,
        costosVendidos: costosVendidos,
        gananciaNeta: gananciaNeta,
        animalesVendidos: animalesVendidos,
      );
}
