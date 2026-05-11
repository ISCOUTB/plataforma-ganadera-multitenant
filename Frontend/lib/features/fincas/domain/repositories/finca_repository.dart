import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/finca.dart';

class CreateFincaInput {
  final String id;
  final String nombre;
  final String? ubicacion;
  final String? propietario;
  final double? areaTotal;
  final DateTime? fechaRegistro;

  const CreateFincaInput({
    required this.id,
    required this.nombre,
    this.ubicacion,
    this.propietario,
    this.areaTotal,
    this.fechaRegistro,
  });
}

class UpdateFincaInput {
  final String? nombre;
  final String? ubicacion;
  final String? propietario;
  final double? areaTotal;
  final DateTime? fechaRegistro;

  const UpdateFincaInput({
    this.nombre,
    this.ubicacion,
    this.propietario,
    this.areaTotal,
    this.fechaRegistro,
  });
}

abstract class FincaRepository {
  Future<Either<AppFailure, PaginatedResponse<Finca>>> list({
    int page = 1,
    int limit = 20,
    String? nombre,
    String? ubicacion,
  });

  Future<Either<AppFailure, Finca>> getById(String id);
  Future<Either<AppFailure, Finca>> create(CreateFincaInput input);
  Future<Either<AppFailure, Finca>> update(String id, UpdateFincaInput input);
  Future<Either<AppFailure, Unit>> delete(String id);
}
