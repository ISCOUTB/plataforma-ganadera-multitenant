import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/finanza.dart';

class CreateFinanzaInput {
  final String id;
  final TipoMovimiento tipoMovimiento;
  final String concepto;
  final String? categoria;
  final double monto;
  final DateTime? fecha;
  final String? factura;
  final String? metodoPago;
  final String? fincaId;
  final int? animalId;

  const CreateFinanzaInput({
    required this.id,
    required this.tipoMovimiento,
    required this.concepto,
    required this.monto,
    this.categoria,
    this.fecha,
    this.factura,
    this.metodoPago,
    this.fincaId,
    this.animalId,
  });
}

class UpdateFinanzaInput {
  final TipoMovimiento? tipoMovimiento;
  final String? concepto;
  final String? categoria;
  final double? monto;
  final DateTime? fecha;
  final String? factura;
  final String? metodoPago;

  const UpdateFinanzaInput({
    this.tipoMovimiento,
    this.concepto,
    this.categoria,
    this.monto,
    this.fecha,
    this.factura,
    this.metodoPago,
  });
}

abstract class FinanzaRepository {
  Future<Either<AppFailure, PaginatedResponse<Finanza>>> list({
    int page = 1,
    int limit = 20,
    TipoMovimiento? tipo,
    String? categoria,
    String? fincaId,
  });

  Future<Either<AppFailure, Finanza>> getById(String id);
  Future<Either<AppFailure, FinanzasResumen>> getResumen({String? fincaId});
  Future<Either<AppFailure, Finanza>> create(CreateFinanzaInput input);
  Future<Either<AppFailure, Finanza>> update(
      String id, UpdateFinanzaInput input);
  Future<Either<AppFailure, Unit>> delete(String id);
}
