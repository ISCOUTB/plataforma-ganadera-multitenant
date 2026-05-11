import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/salud.dart';

class CreateSaludInput {
  final TipoIntervencion tipoIntervencion;
  final String? descripcionEnfermedad;
  final String? productoAplicado;
  final String? dosis;
  final DateTime? fechaAplicacion;
  final DateTime? fechaProximaAplicacion;
  final double? costo;
  final int? animalId;

  const CreateSaludInput({
    required this.tipoIntervencion,
    this.descripcionEnfermedad,
    this.productoAplicado,
    this.dosis,
    this.fechaAplicacion,
    this.fechaProximaAplicacion,
    this.costo,
    this.animalId,
  });
}

class UpdateSaludInput {
  final TipoIntervencion? tipoIntervencion;
  final String? descripcionEnfermedad;
  final String? productoAplicado;
  final String? dosis;
  final DateTime? fechaAplicacion;
  final DateTime? fechaProximaAplicacion;
  final double? costo;
  final int? animalId;

  const UpdateSaludInput({
    this.tipoIntervencion,
    this.descripcionEnfermedad,
    this.productoAplicado,
    this.dosis,
    this.fechaAplicacion,
    this.fechaProximaAplicacion,
    this.costo,
    this.animalId,
  });
}

abstract class SaludRepository {
  Future<Either<AppFailure, PaginatedResponse<Salud>>> list({
    int page = 1,
    int limit = 20,
    TipoIntervencion? tipoIntervencion,
    String? fincaId,
  });

  Future<Either<AppFailure, Salud>> getById(int id);
  Future<Either<AppFailure, SaludAlertas>> getAlertas();
  Future<Either<AppFailure, Salud>> create(CreateSaludInput input);
  Future<Either<AppFailure, Salud>> update(int id, UpdateSaludInput input);
  Future<Either<AppFailure, Unit>> delete(int id);
}
