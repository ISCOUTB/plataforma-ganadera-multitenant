import 'package:equatable/equatable.dart';

class Potrero extends Equatable {
  final String id; // pk_id_potrero (string)
  final String nombre;
  final double? area;
  final int capacidadAnimales;
  final String? estado;
  final DateTime? fechaRotacion;
  final DateTime? fechaProximaRotacion;
  final String? fincaId;

  const Potrero({
    required this.id,
    required this.nombre,
    required this.capacidadAnimales,
    this.area,
    this.estado,
    this.fechaRotacion,
    this.fechaProximaRotacion,
    this.fincaId,
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        capacidadAnimales,
        area,
        estado,
        fechaRotacion,
        fechaProximaRotacion,
        fincaId,
      ];
}

class PotreroOcupacion extends Equatable {
  final int actual;
  final int capacidad;
  final int porcentaje;
  final String estado;

  const PotreroOcupacion({
    required this.actual,
    required this.capacidad,
    required this.porcentaje,
    required this.estado,
  });

  @override
  List<Object?> get props => [actual, capacidad, porcentaje, estado];
}
