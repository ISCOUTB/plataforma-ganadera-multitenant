import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bovino_alimento.dart';

class AsignarBovinoAlimentoInput {
  final int animalId;
  final String alimentoId;
  final double cantidad;
  final DateTime fecha;

  const AsignarBovinoAlimentoInput({
    required this.animalId,
    required this.alimentoId,
    required this.cantidad,
    required this.fecha,
  });
}

abstract class BovinoAlimentoRepository {
  Future<Either<AppFailure, List<BovinoAlimento>>> getByAnimal(int animalId);

  Future<Either<AppFailure, BovinoAlimento>> assign(
    AsignarBovinoAlimentoInput input,
  );

  Future<Either<AppFailure, Unit>> remove(int animalId, String alimentoId);
}
