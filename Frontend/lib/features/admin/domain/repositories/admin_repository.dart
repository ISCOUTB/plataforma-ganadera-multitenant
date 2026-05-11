import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/admin_user.dart';
import '../entities/tenant_summary.dart';

abstract class AdminRepository {
  Future<Either<AppFailure, List<TenantSummary>>> listTenants();
  Future<Either<AppFailure, List<AdminUser>>> listAllUsers();
  Future<Either<AppFailure, AdminUser>> createUser({
    required String email,
    required String password,
    required String nombre,
    required String tenantId,
    String? rol,
    String? telefono,
  });
}
