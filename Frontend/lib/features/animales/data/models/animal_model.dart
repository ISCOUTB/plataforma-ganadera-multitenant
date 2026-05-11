import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/animal.dart';

class AnimalModel {
  final int id;
  final String numeroIdentificacion;
  final String? metodoIdentificacion;
  final DateTime? fechaNacimiento;
  final int? edadActual;
  final String genero;
  final double peso;
  final double? altura;
  final String raza;
  final String? origen;
  final DateTime? fechaIngreso;
  final DateTime? fechaSalida;
  final String? fincaId;
  final String? potreroId;
  final String estado;

  AnimalModel({
    required this.id,
    required this.numeroIdentificacion,
    required this.genero,
    required this.peso,
    required this.raza,
    required this.estado,
    this.metodoIdentificacion,
    this.fechaNacimiento,
    this.edadActual,
    this.altura,
    this.origen,
    this.fechaIngreso,
    this.fechaSalida,
    this.fincaId,
    this.potreroId,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) => AnimalModel(
        id: parseInt(json['id'])!,
        numeroIdentificacion: json['numero_identificacion'] as String,
        metodoIdentificacion: json['metodo_identificacion'] as String?,
        fechaNacimiento: _parseDate(json['fecha_nacimiento']),
        edadActual: parseInt(json['edad_actual']),
        genero: (json['genero'] as String?) ?? 'n',
        peso: parseDouble(json['peso']) ?? 0,
        altura: parseDouble(json['altura']),
        raza: (json['raza'] as String?) ?? '',
        origen: json['origen'] as String?,
        fechaIngreso: _parseDate(json['fecha_ingreso']),
        fechaSalida: _parseDate(json['fecha_salida']),
        fincaId: json['fincaId'] as String? ??
            (json['finca'] is Map
                ? (json['finca'] as Map)['pk_id_finca'] as String?
                : null),
        potreroId: json['potreroId'] as String? ??
            (json['potrero'] is Map
                ? (json['potrero'] as Map)['pk_id_potrero'] as String?
                : null),
        estado: (json['estado'] as String?) ?? 'activo',
      );

  Animal toEntity() => Animal(
        id: id,
        numeroIdentificacion: numeroIdentificacion,
        metodoIdentificacion: metodoIdentificacion,
        fechaNacimiento: fechaNacimiento,
        edadActual: edadActual,
        genero: AnimalGeneroX.fromApi(genero),
        peso: peso,
        altura: altura,
        raza: raza,
        origen: origen,
        fechaIngreso: fechaIngreso,
        fechaSalida: fechaSalida,
        fincaId: fincaId,
        potreroId: potreroId,
        estado: AnimalEstadoX.fromApi(estado),
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw.toString());
  }
}

class AnimalCostosModel {
  final double costoSalud;
  final double costoAlimentacion;
  final double costoTotal;

  AnimalCostosModel({
    required this.costoSalud,
    required this.costoAlimentacion,
    required this.costoTotal,
  });

  factory AnimalCostosModel.fromJson(Map<String, dynamic> json) =>
      AnimalCostosModel(
        costoSalud: parseDouble(json['costo_salud']) ?? 0,
        costoAlimentacion: parseDouble(json['costo_alimentacion']) ?? 0,
        costoTotal: parseDouble(json['costo_total']) ?? 0,
      );

  AnimalCostos toEntity() => AnimalCostos(
        costoSalud: costoSalud,
        costoAlimentacion: costoAlimentacion,
        costoTotal: costoTotal,
      );
}
