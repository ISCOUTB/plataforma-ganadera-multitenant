import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/alimento.dart';

class AlimentoModel {
  final String pkIdAlimento;
  final String tipoAlimento;
  final double? cantidadTotal;
  final String? frecuencia;
  final DateTime? fechaInicio;
  final DateTime? fechaFinEstimada;
  final double? costo;

  AlimentoModel({
    required this.pkIdAlimento,
    required this.tipoAlimento,
    this.cantidadTotal,
    this.frecuencia,
    this.fechaInicio,
    this.fechaFinEstimada,
    this.costo,
  });

  factory AlimentoModel.fromJson(Map<String, dynamic> json) => AlimentoModel(
        pkIdAlimento: json['pk_id_alimento'] as String,
        tipoAlimento: (json['tipo_alimento'] as String?) ?? '',
        cantidadTotal: parseDouble(json['cantidad_total']),
        frecuencia: json['frecuencia'] as String?,
        fechaInicio: _parseDate(json['fecha_inicio']),
        fechaFinEstimada: _parseDate(json['fecha_fin_estimada']),
        costo: parseDouble(json['costo']),
      );

  Alimento toEntity() => Alimento(
        id: pkIdAlimento,
        tipoAlimento: tipoAlimento,
        cantidadTotal: cantidadTotal,
        frecuencia: frecuencia,
        fechaInicio: fechaInicio,
        fechaFinEstimada: fechaFinEstimada,
        costo: costo,
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw.toString());
  }
}
