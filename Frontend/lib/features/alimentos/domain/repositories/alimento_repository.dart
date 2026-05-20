import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/alimento.dart';

class CreateAlimentoInput {
  final String id;
  final String tipoAlimento;
  final double? cantidadTotal;
  final String? frecuencia;
  final DateTime? fechaInicio;
  final DateTime? fechaFinEstimada;
  final double? costo;

  const CreateAlimentoInput({
    required this.id,
    required this.tipoAlimento,
    this.cantidadTotal,
    this.frecuencia,
    this.fechaInicio,
    this.fechaFinEstimada,
    this.costo,
  });
}

class UpdateAlimentoInput {
  final String? tipoAlimento;
  final double? cantidadTotal;
  final String? frecuencia;
  final DateTime? fechaInicio;
  final DateTime? fechaFinEstimada;
  final double? costo;

  const UpdateAlimentoInput({
    this.tipoAlimento,
    this.cantidadTotal,
    this.frecuencia,
    this.fechaInicio,
    this.fechaFinEstimada,
    this.costo,
  });
}

abstract class AlimentoRepository {
  Future<Either<AppFailure, PaginatedResponse<Alimento>>> list({
    int page = 1,
    int limit = 20,
  });

  Future<Either<AppFailure, Alimento>> getById(String id);
  Future<Either<AppFailure, Alimento>> create(CreateAlimentoInput input);
  Future<Either<AppFailure, Alimento>> update(
      String id, UpdateAlimentoInput input);
  Future<Either<AppFailure, Unit>> delete(String id);
}
