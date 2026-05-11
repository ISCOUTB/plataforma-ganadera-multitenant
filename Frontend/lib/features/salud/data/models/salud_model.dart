import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/salud.dart';

class SaludModel {
  final int id;
  final String tipoIntervencion;
  final String? descripcionEnfermedad;
  final String? productoAplicado;
  final String? dosis;
  final DateTime? fechaAplicacion;
  final DateTime? fechaProximaAplicacion;
  final double? costo;
  final int? animalId;

  SaludModel({
    required this.id,
    required this.tipoIntervencion,
    this.descripcionEnfermedad,
    this.productoAplicado,
    this.dosis,
    this.fechaAplicacion,
    this.fechaProximaAplicacion,
    this.costo,
    this.animalId,
  });

  factory SaludModel.fromJson(Map<String, dynamic> json) => SaludModel(
        id: parseInt(json['id'])!,
        tipoIntervencion: (json['tipo_intervencion'] as String?) ?? 'vacunacion',
        descripcionEnfermedad: json['descripcion_enfermedad'] as String?,
        productoAplicado: json['producto_aplicado'] as String?,
        dosis: json['dosis'] as String?,
        fechaAplicacion: _parseDate(json['fecha_aplicacion']),
        fechaProximaAplicacion: _parseDate(json['fecha_proxima_aplicacion']),
        costo: parseDouble(json['costo']),
        animalId: parseInt(json['animalId']) ??
            (json['animal'] is Map
                ? parseInt((json['animal'] as Map)['id'])
                : null),
      );

  Salud toEntity() => Salud(
        id: id,
        tipoIntervencion: TipoIntervencionX.fromApi(tipoIntervencion),
        descripcionEnfermedad: descripcionEnfermedad,
        productoAplicado: productoAplicado,
        dosis: dosis,
        fechaAplicacion: fechaAplicacion,
        fechaProximaAplicacion: fechaProximaAplicacion,
        costo: costo,
        animalId: animalId,
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw.toString());
  }
}
