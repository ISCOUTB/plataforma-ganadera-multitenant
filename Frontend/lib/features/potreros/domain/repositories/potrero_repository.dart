import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/potrero.dart';

class CreatePotreroInput {
  final String id;
  final String nombre;
  final int capacidadAnimales;
  final double? area;
  final String? estado;
  final DateTime? fechaRotacion;
  final DateTime? fechaProximaRotacion;
  final String? fincaId;

  const CreatePotreroInput({
    required this.id,
    required this.nombre,
    required this.capacidadAnimales,
    this.area,
    this.estado,
    this.fechaRotacion,
    this.fechaProximaRotacion,
    this.fincaId,
  });
}

class UpdatePotreroInput {
  final String? nombre;
  final int? capacidadAnimales;
  final double? area;
  final String? estado;
  final DateTime? fechaRotacion;
  final DateTime? fechaProximaRotacion;
  final String? fincaId;

  const UpdatePotreroInput({
    this.nombre,
    this.capacidadAnimales,
    this.area,
    this.estado,
    this.fechaRotacion,
    this.fechaProximaRotacion,
    this.fincaId,
  });
}

abstract class PotreroRepository {
  Future<Either<AppFailure, PaginatedResponse<Potrero>>> list({
    int page = 1,
    int limit = 20,
    String? fincaId,
  });

  Future<Either<AppFailure, Potrero>> getById(String id);
  Future<Either<AppFailure, PotreroOcupacion>> getOcupacion(String id);
  Future<Either<AppFailure, Potrero>> create(CreatePotreroInput input);
  Future<Either<AppFailure, Potrero>> update(
      String id, UpdatePotreroInput input);
  Future<Either<AppFailure, Unit>> delete(String id);
}
