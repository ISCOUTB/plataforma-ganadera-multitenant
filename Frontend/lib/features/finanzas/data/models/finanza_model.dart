import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/finanza.dart';

class FinanzaModel {
  final String pkIdFinanza;
  final String tipoMovimiento;
  final String concepto;
  final String? categoria;
  final double monto;
  final DateTime? fecha;
  final String? factura;
  final String? metodoPago;
  final String? fincaId;
  final int? animalId;

  FinanzaModel({
    required this.pkIdFinanza,
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

  factory FinanzaModel.fromJson(Map<String, dynamic> json) => FinanzaModel(
        pkIdFinanza: json['pk_id_finanza'] as String,
        tipoMovimiento: (json['tipo_movimiento'] as String?) ?? 'ingreso',
        concepto: (json['concepto'] as String?) ?? '',
        categoria: json['categoria'] as String?,
        monto: parseDouble(json['monto']) ?? 0,
        fecha: _parseDate(json['fecha']),
        factura: json['factura'] as String?,
        metodoPago: json['metodo_pago'] as String?,
        fincaId: json['fincaId'] as String? ??
            (json['finca'] is Map
                ? (json['finca'] as Map)['pk_id_finca'] as String?
                : null),
        animalId: parseInt(json['animalId']) ??
            (json['animal'] is Map
                ? parseInt((json['animal'] as Map)['id'])
                : null),
      );

  Finanza toEntity() => Finanza(
        id: pkIdFinanza,
        tipoMovimiento: TipoMovimientoX.fromApi(tipoMovimiento),
        concepto: concepto,
        categoria: categoria,
        monto: monto,
        fecha: fecha,
        factura: factura,
        metodoPago: metodoPago,
        fincaId: fincaId,
        animalId: animalId,
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw.toString());
  }
}

class FinanzaResumenModel {
  final double totalIngresos;
  final double totalGastos;
  final double balance;

  FinanzaResumenModel({
    required this.totalIngresos,
    required this.totalGastos,
    required this.balance,
  });

  factory FinanzaResumenModel.fromJson(Map<String, dynamic> json) =>
      FinanzaResumenModel(
        totalIngresos: parseDouble(json['total_ingresos']) ?? 0,
        totalGastos: parseDouble(json['total_gastos']) ?? 0,
        balance: parseDouble(json['balance']) ?? 0,
      );

  FinanzasResumen toEntity() => FinanzasResumen(
        totalIngresos: totalIngresos,
        totalGastos: totalGastos,
        balance: balance,
      );
}
