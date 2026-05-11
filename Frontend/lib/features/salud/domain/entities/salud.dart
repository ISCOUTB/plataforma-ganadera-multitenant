import 'package:equatable/equatable.dart';

enum TipoIntervencion { vacunacion, vitaminas, desparasitacion, enfermedad }

extension TipoIntervencionX on TipoIntervencion {
  String get apiValue => switch (this) {
        TipoIntervencion.vacunacion => 'vacunacion',
        TipoIntervencion.vitaminas => 'vitaminas',
        TipoIntervencion.desparasitacion => 'desparasitacion',
        TipoIntervencion.enfermedad => 'enfermedad',
      };

  String get label => switch (this) {
        TipoIntervencion.vacunacion => 'Vacunación',
        TipoIntervencion.vitaminas => 'Vitaminas',
        TipoIntervencion.desparasitacion => 'Desparasitación',
        TipoIntervencion.enfermedad => 'Enfermedad',
      };

  static TipoIntervencion fromApi(String? raw) => switch (raw) {
        'vitaminas' => TipoIntervencion.vitaminas,
        'desparasitacion' => TipoIntervencion.desparasitacion,
        'enfermedad' => TipoIntervencion.enfermedad,
        _ => TipoIntervencion.vacunacion,
      };
}

class Salud extends Equatable {
  final int id;
  final TipoIntervencion tipoIntervencion;
  final String? descripcionEnfermedad;
  final String? productoAplicado;
  final String? dosis;
  final DateTime? fechaAplicacion;
  final DateTime? fechaProximaAplicacion;
  final double? costo;
  final int? animalId;

  const Salud({
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

  @override
  List<Object?> get props => [
        id,
        tipoIntervencion,
        productoAplicado,
        fechaAplicacion,
        fechaProximaAplicacion,
        animalId,
      ];
}

class SaludAlertas extends Equatable {
  final List<Salud> proximas;
  final List<Salud> vencidas;

  const SaludAlertas({required this.proximas, required this.vencidas});

  int get total => proximas.length + vencidas.length;

  @override
  List<Object?> get props => [proximas, vencidas];
}
