import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/finca.dart';

class FincaModel {
  final String pkIdFinca;
  final String nombreFinca;
  final String? ubicacion;
  final String? propietario;
  final double? areaTotal;
  final DateTime? fechaRegistro;

  FincaModel({
    required this.pkIdFinca,
    required this.nombreFinca,
    this.ubicacion,
    this.propietario,
    this.areaTotal,
    this.fechaRegistro,
  });

  factory FincaModel.fromJson(Map<String, dynamic> json) => FincaModel(
        pkIdFinca: json['pk_id_finca'] as String,
        nombreFinca: json['nombre_finca'] as String,
        ubicacion: json['ubicacion'] as String?,
        propietario: json['propietario'] as String?,
        areaTotal: parseDouble(json['area_total']),
        fechaRegistro: _parseDate(json['fecha_registro']),
      );

  Finca toEntity() => Finca(
        id: pkIdFinca,
        nombre: nombreFinca,
        ubicacion: ubicacion,
        propietario: propietario,
        areaTotal: areaTotal,
        fechaRegistro: fechaRegistro,
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw.toString());
  }
}
