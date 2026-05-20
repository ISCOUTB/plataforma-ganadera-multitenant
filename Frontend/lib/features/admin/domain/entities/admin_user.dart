import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final int id;
  final String email;
  final String nombre;
  final String rol;
  final String tenantId;
  final String? telefono;

  const AdminUser({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.tenantId,
    this.telefono,
  });

  @override
  List<Object?> get props => [id, email, nombre, rol, tenantId, telefono];
}
