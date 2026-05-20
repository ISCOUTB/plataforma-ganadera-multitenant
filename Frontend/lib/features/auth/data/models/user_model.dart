import '../../domain/entities/user.dart';

/// Mapeo del JSON del backend (`/auth/me`, `/auth/login.user`, `/auth/registro`).
class UserModel {
  final int id;
  final String nombre;
  final String email;
  final String rol;
  final String tenantId;
  final String? telefono;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.tenantId,
    this.telefono,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] as num).toInt(),
        nombre: json['nombre'] as String,
        email: json['email'] as String,
        rol: json['rol'] as String,
        tenantId: json['tenant_id'] as String,
        telefono: json['telefono'] as String?,
      );

  User toEntity() => User(
        id: id,
        nombre: nombre,
        email: email,
        rol: rol,
        tenantId: tenantId,
        telefono: telefono,
      );
}
