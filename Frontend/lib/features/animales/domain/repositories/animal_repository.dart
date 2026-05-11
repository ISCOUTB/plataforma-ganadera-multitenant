import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/animal.dart';

class CreateAnimalInput {
  final String numeroIdentificacion;
  final DateTime fechaNacimiento;
  final AnimalGenero genero;
  final double peso;
  final String raza;
  final String? metodoIdentificacion;
  final double? altura;
  final String? origen;
  final DateTime? fechaIngreso;
  final String? fincaId;
  final String? potreroId;

  const CreateAnimalInput({
    required this.numeroIdentificacion,
    required this.fechaNacimiento,
    required this.genero,
    required this.peso,
    required this.raza,
    this.metodoIdentificacion,
    this.altura,
    this.origen,
    this.fechaIngreso,
    this.fincaId,
    this.potreroId,
  });
}

class UpdateAnimalInput {
  final String? numeroIdentificacion;
  final DateTime? fechaNacimiento;
  final AnimalGenero? genero;
  final double? peso;
  final String? raza;
  final double? altura;
  final String? fincaId;
  final String? potreroId;

  const UpdateAnimalInput({
    this.numeroIdentificacion,
    this.fechaNacimiento,
    this.genero,
    this.peso,
    this.raza,
    this.altura,
    this.fincaId,
    this.potreroId,
  });
}

class VenderAnimalInput {
  final double precioVenta;
  final String comprador;
  final DateTime fechaVenta;
  final String? fincaId;

  const VenderAnimalInput({
    required this.precioVenta,
    required this.comprador,
    required this.fechaVenta,
    this.fincaId,
  });
}

class AnimalFilter {
  final String? raza;
  final AnimalGenero? genero;
  final AnimalEstado? estado;
  const AnimalFilter({this.raza, this.genero, this.estado});

  AnimalFilter copyWith({
    Object? raza = _sentinel,
    Object? genero = _sentinel,
    Object? estado = _sentinel,
  }) =>
      AnimalFilter(
        raza: raza == _sentinel ? this.raza : raza as String?,
        genero: genero == _sentinel ? this.genero : genero as AnimalGenero?,
        estado: estado == _sentinel ? this.estado : estado as AnimalEstado?,
      );
}

const _sentinel = Object();

abstract class AnimalRepository {
  Future<Either<AppFailure, PaginatedResponse<Animal>>> list({
    int page = 1,
    int limit = 20,
    AnimalFilter filter = const AnimalFilter(),
    String? fincaId,
  });

  Future<Either<AppFailure, Animal>> getById(int id);
  Future<Either<AppFailure, AnimalCostos>> getCostos(int id);
  Future<Either<AppFailure, Animal>> create(CreateAnimalInput input);
  Future<Either<AppFailure, Animal>> update(int id, UpdateAnimalInput input);
  Future<Either<AppFailure, Unit>> delete(int id);
  Future<Either<AppFailure, Animal>> vender(int id, VenderAnimalInput input);
  Future<Either<AppFailure, List<Map<String, dynamic>>>> getTimeline(int id);
}
