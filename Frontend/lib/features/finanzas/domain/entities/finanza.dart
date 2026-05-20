import 'package:equatable/equatable.dart';

enum TipoMovimiento { ingreso, gasto }

extension TipoMovimientoX on TipoMovimiento {
  String get apiValue =>
      this == TipoMovimiento.ingreso ? 'ingreso' : 'gasto';
  String get label => this == TipoMovimiento.ingreso ? 'Ingreso' : 'Gasto';
  static TipoMovimiento fromApi(String? raw) =>
      raw == 'gasto' ? TipoMovimiento.gasto : TipoMovimiento.ingreso;
}

class Finanza extends Equatable {
  final String id;
  final TipoMovimiento tipoMovimiento;
  final String concepto;
  final String? categoria;
  final double monto;
  final DateTime? fecha;
  final String? factura;
  final String? metodoPago;
  final String? fincaId;
  final int? animalId;

  const Finanza({
    required this.id,
    required this.tipoMovimiento,
    required this.concepto,
    required this.monto,
    this.categoria,
    this.fecha,
    this.factura,
    this.metodoPago,
    this.fincaId,
    this.animalId,
  });

  @override
  List<Object?> get props =>
      [id, tipoMovimiento, concepto, monto, categoria, fecha];
}

class FinanzasResumen extends Equatable {
  final double totalIngresos;
  final double totalGastos;
  final double balance;

  const FinanzasResumen({
    required this.totalIngresos,
    required this.totalGastos,
    required this.balance,
  });

  @override
  List<Object?> get props => [totalIngresos, totalGastos, balance];
}
