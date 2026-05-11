import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/admin_user.dart';

class AdminUserModel {
  static AdminUser fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: parseInt(json['id']) ?? 0,
      email: (json['email'] as String?) ?? '',
      nombre: (json['nombre'] as String?) ?? '',
      rol: (json['rol'] as String?) ?? 'empleado',
      tenantId: (json['tenant_id'] as String?) ?? '',
      telefono: json['telefono'] as String?,
    );
  }
}
