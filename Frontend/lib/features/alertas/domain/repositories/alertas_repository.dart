import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/alertas_summary.dart';

abstract class AlertasRepository {
  Future<Either<AppFailure, AlertasSummary>> getAll();
}
