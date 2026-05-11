import 'package:equatable/equatable.dart';

enum AnimalGenero { macho, hembra, neutro }

extension AnimalGeneroX on AnimalGenero {
  String get apiValue => switch (this) {
        AnimalGenero.macho => 'm',
        AnimalGenero.hembra => 'h',
        AnimalGenero.neutro => 'n',
      };

  String get label => switch (this) {
        AnimalGenero.macho => 'Macho',
        AnimalGenero.hembra => 'Hembra',
        AnimalGenero.neutro => 'Neutro',
      };

  static AnimalGenero fromApi(String? raw) => switch (raw) {
        'm' => AnimalGenero.macho,
        'h' => AnimalGenero.hembra,
        _ => AnimalGenero.neutro,
      };
}

enum AnimalEstado { activo, vendido }

extension AnimalEstadoX on AnimalEstado {
  String get apiValue => switch (this) {
        AnimalEstado.activo => 'activo',
        AnimalEstado.vendido => 'vendido',
      };
  String get label => switch (this) {
        AnimalEstado.activo => 'Activo',
        AnimalEstado.vendido => 'Vendido',
      };
  static AnimalEstado fromApi(String? raw) =>
      raw == 'vendido' ? AnimalEstado.vendido : AnimalEstado.activo;
}

class Animal extends Equatable {
  final int id;
  final String numeroIdentificacion;
  final String? metodoIdentificacion;
  final DateTime? fechaNacimiento;
  final int? edadActual;
  final AnimalGenero genero;
  final double peso;
  final double? altura;
  final String raza;
  final String? origen;
  final DateTime? fechaIngreso;
  final DateTime? fechaSalida;
  final String? fincaId;
  final String? potreroId;
  final AnimalEstado estado;

  const Animal({
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

  @override
  List<Object?> get props => [
        id,
        numeroIdentificacion,
        genero,
        peso,
        raza,
        estado,
        fincaId,
        potreroId,
        fechaNacimiento,
      ];
}

class AnimalCostos extends Equatable {
  final double costoSalud;
  final double costoAlimentacion;
  final double costoTotal;

  const AnimalCostos({
    required this.costoSalud,
    required this.costoAlimentacion,
    required this.costoTotal,
  });

  @override
  List<Object?> get props => [costoSalud, costoAlimentacion, costoTotal];
}
