import 'package:equatable/equatable.dart';

class UsuarioTenant extends Equatable {
  final int id;
  final String nombre;
  final String email;
  final String rol;
  final String? telefono;

  const UsuarioTenant({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.telefono,
  });

  @override
  List<Object?> get props => [id, nombre, email, rol];
}
