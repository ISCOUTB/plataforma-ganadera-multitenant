import 'package:equatable/equatable.dart';

/// Costo total acumulado de salud + alimentación de TODOS los animales del
/// tenant (o finca cuando se filtra). Sirve como indicador macro: cuánto
/// está costando mantener el hato.
class CostoTotalAnimales extends Equatable {
  final double costoSalud;
  final double costoAlimentacion;
  final double costoTotal;

  const CostoTotalAnimales({
    required this.costoSalud,
    required this.costoAlimentacion,
    required this.costoTotal,
  });

  @override
  List<Object?> get props => [costoSalud, costoAlimentacion, costoTotal];
}

/// Animal individual rankeado por costo acumulado (top 5). Permite detectar
/// los animales que más recursos consumen y decidir intervenciones.
class AnimalCostoso extends Equatable {
  final String id;
  final String numeroIdentificacion;
  final double costoTotal;
  final double costoSalud;
  final double costoAlimentacion;

  const AnimalCostoso({
    required this.id,
    required this.numeroIdentificacion,
    required this.costoTotal,
    required this.costoSalud,
    required this.costoAlimentacion,
  });

  @override
  List<Object?> get props => [
        id,
        numeroIdentificacion,
        costoTotal,
        costoSalud,
        costoAlimentacion,
      ];
}

/// Resumen de la operación de venta: total ingresado, costos asociados a los
/// animales vendidos y ganancia neta. `animalesVendidos == 0` significa que
/// no hay base para calcular y la UI debe mostrar placeholder.
class EstimacionGanancia extends Equatable {
  final double totalVentas;
  final double costosVendidos;
  final double gananciaNeta;
  final int animalesVendidos;

  const EstimacionGanancia({
    required this.totalVentas,
    required this.costosVendidos,
    required this.gananciaNeta,
    required this.animalesVendidos,
  });

  @override
  List<Object?> get props => [
        totalVentas,
        costosVendidos,
        gananciaNeta,
        animalesVendidos,
      ];
}

/// Payload de `GET /api/dashboard/inteligencia` — datos costosos servidos en
/// un endpoint aparte para poder cargarse lazy sin penalizar el dashboard
/// principal. Ignora `top_5_potreros_activos` del backend porque el
/// `DashboardSummary.topPotreros` ya cubre ese caso visualmente.
class DashboardInteligencia extends Equatable {
  final CostoTotalAnimales costoTotal;
  final List<AnimalCostoso> topAnimalesCostosos;
  final int animalesSinPotrero;
  final EstimacionGanancia estimacionGanancia;

  const DashboardInteligencia({
    required this.costoTotal,
    required this.topAnimalesCostosos,
    required this.animalesSinPotrero,
    required this.estimacionGanancia,
  });

  @override
  List<Object?> get props => [
        costoTotal,
        topAnimalesCostosos,
        animalesSinPotrero,
        estimacionGanancia,
      ];
}
