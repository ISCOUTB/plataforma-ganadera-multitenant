import 'package:equatable/equatable.dart';

class Alimento extends Equatable {
  final String id;
  final String tipoAlimento;
  final double? cantidadTotal;
  final String? frecuencia;
  final DateTime? fechaInicio;
  final DateTime? fechaFinEstimada;
  final double? costo;

  const Alimento({
    required this.id,
    required this.tipoAlimento,
    this.cantidadTotal,
    this.frecuencia,
    this.fechaInicio,
    this.fechaFinEstimada,
    this.costo,
  });

  @override
  List<Object?> get props => [id, tipoAlimento, cantidadTotal, costo];
}
