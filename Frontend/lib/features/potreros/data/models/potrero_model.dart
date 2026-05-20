import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/potrero.dart';

class PotreroModel {
  final String pkIdPotrero;
  final String nombrePotrero;
  final double? area;
  final int capacidadAnimales;
  final String? estado;
  final DateTime? fechaRotacion;
  final DateTime? fechaProximaRotacion;
  final String? fincaId;

  PotreroModel({
    required this.pkIdPotrero,
    required this.nombrePotrero,
    required this.capacidadAnimales,
    this.area,
    this.estado,
    this.fechaRotacion,
    this.fechaProximaRotacion,
    this.fincaId,
  });

  factory PotreroModel.fromJson(Map<String, dynamic> json) => PotreroModel(
        pkIdPotrero: json['pk_id_potrero'] as String,
        nombrePotrero: json['nombre_potrero'] as String,
        area: parseDouble(json['area']),
        capacidadAnimales: parseInt(json['capacidad_animales']) ?? 0,
        estado: json['estado'] as String?,
        fechaRotacion: _parseDate(json['fecha_rotacion']),
        fechaProximaRotacion: _parseDate(json['fecha_proxima_rotacion']),
        fincaId: json['fincaId'] as String? ??
            (json['finca'] is Map
                ? (json['finca'] as Map)['pk_id_finca'] as String?
                : null),
      );

  Potrero toEntity() => Potrero(
        id: pkIdPotrero,
        nombre: nombrePotrero,
        area: area,
        capacidadAnimales: capacidadAnimales,
        estado: estado,
        fechaRotacion: fechaRotacion,
        fechaProximaRotacion: fechaProximaRotacion,
        fincaId: fincaId,
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw.toString());
  }
}

class PotreroOcupacionModel {
  final int actual;
  final int capacidad;
  final int porcentaje;
  final String estado;

  PotreroOcupacionModel({
    required this.actual,
    required this.capacidad,
    required this.porcentaje,
    required this.estado,
  });

  /// El backend devuelve `{ pk_id_potrero, nombre_potrero, capacidad_animales,
  /// ocupacion_actual, porcentaje_ocupacion, estado_ocupacion }`. Los keys
  /// reales son los `*_ocupacion` y `ocupacion_actual`, NO `actual/porcentaje/
  /// estado` que asumí inicialmente.
  factory PotreroOcupacionModel.fromJson(Map<String, dynamic> json) =>
      PotreroOcupacionModel(
        actual: parseInt(json['ocupacion_actual']) ?? 0,
        capacidad: parseInt(json['capacidad_animales']) ?? 0,
        porcentaje: parseInt(json['porcentaje_ocupacion']) ?? 0,
        estado: (json['estado_ocupacion'] as String?) ?? 'desconocido',
      );

  PotreroOcupacion toEntity() => PotreroOcupacion(
        actual: actual,
        capacidad: capacidad,
        porcentaje: porcentaje,
        estado: estado,
      );
}
