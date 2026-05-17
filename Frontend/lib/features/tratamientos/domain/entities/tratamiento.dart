import 'package:equatable/equatable.dart';
import '../../../veterinarios/domain/entities/veterinario.dart';

enum EstadoTratamiento { enCurso, completado, abandonado }

extension EstadoTratamientoX on EstadoTratamiento {
  static EstadoTratamiento fromApi(String? raw) => switch (raw) {
        'completado' => EstadoTratamiento.completado,
        'abandonado' => EstadoTratamiento.abandonado,
        _ => EstadoTratamiento.enCurso,
      };

  String get label => switch (this) {
        EstadoTratamiento.enCurso => 'En curso',
        EstadoTratamiento.completado => 'Completado',
        EstadoTratamiento.abandonado => 'Abandonado',
      };
}

class SeguimientoTratamiento extends Equatable {
  final int id;
  final String observacion;
  final String? registradoPor;
  final DateTime creadoEn;

  const SeguimientoTratamiento({
    required this.id,
    required this.observacion,
    this.registradoPor,
    required this.creadoEn,
  });

  factory SeguimientoTratamiento.fromJson(Map<String, dynamic> json) =>
      SeguimientoTratamiento(
        id: json['id'] as int,
        observacion: json['observacion'] as String,
        registradoPor: json['registrado_por'] as String?,
        creadoEn: DateTime.parse(json['creado_en'] as String),
      );

  @override
  List<Object?> get props => [id, observacion, creadoEn];
}

class Tratamiento extends Equatable {
  final int id;
  final int fkIdBovino;
  final String diagnostico;
  final DateTime fechaInicio;
  final DateTime? fechaFinEstimada;
  final EstadoTratamiento estado;
  final Veterinario? veterinario;
  final List<SeguimientoTratamiento> seguimientos;

  const Tratamiento({
    required this.id,
    required this.fkIdBovino,
    required this.diagnostico,
    required this.fechaInicio,
    this.fechaFinEstimada,
    required this.estado,
    this.veterinario,
    this.seguimientos = const [],
  });

  factory Tratamiento.fromJson(Map<String, dynamic> json) => Tratamiento(
        id: json['id'] as int,
        fkIdBovino: json['fk_id_bovino'] as int,
        diagnostico: json['diagnostico'] as String,
        fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
        fechaFinEstimada: json['fecha_fin_estimada'] != null
            ? DateTime.parse(json['fecha_fin_estimada'] as String)
            : null,
        estado: EstadoTratamientoX.fromApi(json['estado'] as String?),
        veterinario: json['veterinario'] != null
            ? Veterinario.fromJson(json['veterinario'] as Map<String, dynamic>)
            : null,
        seguimientos: (json['seguimientos'] as List<dynamic>? ?? [])
            .map((e) => SeguimientoTratamiento.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [id, fkIdBovino, diagnostico, estado];
}
