import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/usuario_tenant.dart';

class UsuarioTenantModel {
  static UsuarioTenant fromJson(Map<String, dynamic> json) {
    return UsuarioTenant(
      id: parseInt(json['id']) ?? 0,
      nombre: (json['nombre'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      rol: (json['rol'] as String?) ?? 'empleado',
      telefono: json['telefono'] as String?,
    );
  }
}
