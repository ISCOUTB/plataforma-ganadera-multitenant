import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/movimiento.dart';

class CreateMovimientoInput {
  final int animalId;
  final String potreroOrigenId;
  final String potreroDestinoId;
  final DateTime fecha;
  final String? motivo;

  const CreateMovimientoInput({
    required this.animalId,
    required this.potreroOrigenId,
    required this.potreroDestinoId,
    required this.fecha,
    this.motivo,
  });
}

abstract class MovimientoRepository {
  Future<Either<AppFailure, PaginatedResponse<Movimiento>>> list({
    int page = 1,
    int limit = 20,
  });

  Future<Either<AppFailure, List<Movimiento>>> getByAnimal(int animalId);
  Future<Either<AppFailure, Movimiento>> create(CreateMovimientoInput input);
}
