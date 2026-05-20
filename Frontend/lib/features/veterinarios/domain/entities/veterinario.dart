import 'package:equatable/equatable.dart';

class Veterinario extends Equatable {
  final int id;
  final String nombre;
  final String? especialidad;
  final String? telefono;
  final String? email;
  final String? notas;

  const Veterinario({
    required this.id,
    required this.nombre,
    this.especialidad,
    this.telefono,
    this.email,
    this.notas,
  });

  factory Veterinario.fromJson(Map<String, dynamic> json) => Veterinario(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        especialidad: json['especialidad'] as String?,
        telefono: json['telefono'] as String?,
        email: json['email'] as String?,
        notas: json['notas'] as String?,
      );

  @override
  List<Object?> get props => [id, nombre, especialidad, telefono, email];
}
