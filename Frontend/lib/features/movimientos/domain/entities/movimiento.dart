import 'package:equatable/equatable.dart';

class Movimiento extends Equatable {
  final int id;
  final int? animalId;
  final String? potreroOrigen;
  final String? potreroDestino;
  final DateTime? fecha;
  final String? motivo;

  const Movimiento({
    required this.id,
    this.animalId,
    this.potreroOrigen,
    this.potreroDestino,
    this.fecha,
    this.motivo,
  });

  @override
  List<Object?> get props =>
      [id, animalId, potreroOrigen, potreroDestino, fecha];
}
