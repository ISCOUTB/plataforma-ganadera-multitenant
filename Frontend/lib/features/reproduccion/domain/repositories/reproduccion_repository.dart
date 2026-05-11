import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/reproduccion.dart';

class CreateReproduccionInput {
  final String id;
  final String? fkIdPadre;
  final String? fkIdMadre;
  final String? metodoReproduccion;
  final bool enCelo;
  final bool prenada;
  final int? numeroCrias;
  final DateTime? fechaEstimadoParto;

  const CreateReproduccionInput({
    required this.id,
    required this.enCelo,
    required this.prenada,
    this.fkIdPadre,
    this.fkIdMadre,
    this.metodoReproduccion,
    this.numeroCrias,
    this.fechaEstimadoParto,
  });
}

class UpdateReproduccionInput {
  final String? fkIdPadre;
  final String? fkIdMadre;
  final String? metodoReproduccion;
  final bool? enCelo;
  final bool? prenada;
  final int? numeroCrias;
  final DateTime? fechaEstimadoParto;

  const UpdateReproduccionInput({
    this.fkIdPadre,
    this.fkIdMadre,
    this.metodoReproduccion,
    this.enCelo,
    this.prenada,
    this.numeroCrias,
    this.fechaEstimadoParto,
  });
}

abstract class ReproduccionRepository {
  Future<Either<AppFailure, PaginatedResponse<Reproduccion>>> list({
    int page = 1,
    int limit = 20,
    String? fincaId,
  });

  Future<Either<AppFailure, Reproduccion>> getById(String id);
  Future<Either<AppFailure, ReproduccionAlertas>> getAlertas();
  Future<Either<AppFailure, Reproduccion>> create(CreateReproduccionInput input);
  Future<Either<AppFailure, Reproduccion>> update(
      String id, UpdateReproduccionInput input);
  Future<Either<AppFailure, Unit>> delete(String id);
}
