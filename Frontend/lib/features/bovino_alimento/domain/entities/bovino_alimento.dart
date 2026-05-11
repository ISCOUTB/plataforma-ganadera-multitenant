import 'package:equatable/equatable.dart';

class BovinoAlimento extends Equatable {
  final int animalId;
  final String alimentoId;
  final double cantidad;
  final DateTime fecha;
  final String? alimentoNombre;
  final double? alimentoCosto;

  const BovinoAlimento({
    required this.animalId,
    required this.alimentoId,
    required this.cantidad,
    required this.fecha,
    this.alimentoNombre,
    this.alimentoCosto,
  });

  @override
  List<Object?> get props => [
        animalId,
        alimentoId,
        cantidad,
        fecha,
        alimentoNombre,
        alimentoCosto,
      ];
}
