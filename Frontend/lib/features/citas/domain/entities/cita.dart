import 'package:equatable/equatable.dart';
import '../../../veterinarios/domain/entities/veterinario.dart';

enum TipoCita { revisionGeneral, vacunacion, desparasitacion, partoAsistido, emergencia, otro }
enum EstadoCita { pendiente, completada, cancelada }
enum AlcanceCita { animal, potrero }

extension TipoCitaX on TipoCita {
  static TipoCita fromApi(String? raw) => switch (raw) {
        'vacunacion' => TipoCita.vacunacion,
        'desparasitacion' => TipoCita.desparasitacion,
        'parto_asistido' => TipoCita.partoAsistido,
        'emergencia' => TipoCita.emergencia,
        'otro' => TipoCita.otro,
        _ => TipoCita.revisionGeneral,
      };

  String get label => switch (this) {
        TipoCita.revisionGeneral => 'Revisión general',
        TipoCita.vacunacion => 'Vacunación',
        TipoCita.desparasitacion => 'Desparasitación',
        TipoCita.partoAsistido => 'Parto asistido',
        TipoCita.emergencia => 'Emergencia',
        TipoCita.otro => 'Otro',
      };

  String get apiValue => switch (this) {
        TipoCita.revisionGeneral => 'revision_general',
        TipoCita.vacunacion => 'vacunacion',
        TipoCita.desparasitacion => 'desparasitacion',
        TipoCita.partoAsistido => 'parto_asistido',
        TipoCita.emergencia => 'emergencia',
        TipoCita.otro => 'otro',
      };
}

extension EstadoCitaX on EstadoCita {
  static EstadoCita fromApi(String? raw) => switch (raw) {
        'completada' => EstadoCita.completada,
        'cancelada' => EstadoCita.cancelada,
        _ => EstadoCita.pendiente,
      };

  String get label => switch (this) {
        EstadoCita.pendiente => 'Pendiente',
        EstadoCita.completada => 'Completada',
        EstadoCita.cancelada => 'Cancelada',
      };
}

extension AlcanceCitaX on AlcanceCita {
  static AlcanceCita fromApi(String? raw) => switch (raw) {
        'potrero' => AlcanceCita.potrero,
        _ => AlcanceCita.animal,
      };

  String get label => switch (this) {
        AlcanceCita.animal => 'Animal específico',
        AlcanceCita.potrero => 'Potrero completo',
      };

  String get apiValue => switch (this) {
        AlcanceCita.animal => 'animal',
        AlcanceCita.potrero => 'potrero',
      };
}

class Cita extends Equatable {
  final int id;
  final TipoCita tipo;
  final EstadoCita estado;
  final AlcanceCita alcance;
  final DateTime fechaHora;
  final int? fkIdBovino;
  final String? fkIdPotrero;
  final String? notas;
  final int? recordatorioDias;
  final Veterinario? veterinario;

  const Cita({
    required this.id,
    required this.tipo,
    required this.estado,
    required this.alcance,
    required this.fechaHora,
    this.fkIdBovino,
    this.fkIdPotrero,
    this.notas,
    this.recordatorioDias,
    this.veterinario,
  });

  factory Cita.fromJson(Map<String, dynamic> json) => Cita(
        id: json['id'] as int,
        tipo: TipoCitaX.fromApi(json['tipo'] as String?),
        estado: EstadoCitaX.fromApi(json['estado'] as String?),
        alcance: AlcanceCitaX.fromApi(json['alcance'] as String?),
        fechaHora: DateTime.parse(json['fecha_hora'] as String),
        fkIdBovino: json['fk_id_bovino'] as int?,
        fkIdPotrero: json['fk_id_potrero'] as String?,
        notas: json['notas'] as String?,
        recordatorioDias: json['recordatorio_dias'] as int?,
        veterinario: json['veterinario'] != null
            ? Veterinario.fromJson(json['veterinario'] as Map<String, dynamic>)
            : null,
      );

  @override
  List<Object?> get props => [id, tipo, estado, alcance, fechaHora];
}
