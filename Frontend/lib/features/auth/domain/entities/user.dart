import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String nombre;
  final String email;
  final String rol; // admin | propietario | empleado
  final String tenantId;
  final String? telefono;

  const User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.tenantId,
    this.telefono,
  });

  @override
  List<Object?> get props => [id, nombre, email, rol, tenantId, telefono];
}
