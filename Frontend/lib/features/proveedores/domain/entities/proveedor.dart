import 'package:equatable/equatable.dart';

class ProveedorPrecio extends Equatable {
  final int id;
  final String fkIdAlimento;
  final double precio;
  final String? unidad;
  final DateTime actualizadoEn;
  final Proveedor? proveedor;

  const ProveedorPrecio({
    required this.id,
    required this.fkIdAlimento,
    required this.precio,
    this.unidad,
    required this.actualizadoEn,
    this.proveedor,
  });

  factory ProveedorPrecio.fromJson(Map<String, dynamic> json) => ProveedorPrecio(
        id: json['id'] as int,
        fkIdAlimento: json['fk_id_alimento'] as String,
        precio: double.parse(json['precio'].toString()),
        unidad: json['unidad'] as String?,
        actualizadoEn: DateTime.parse(json['actualizado_en'] as String),
        proveedor: json['proveedor'] != null
            ? Proveedor.fromJson(json['proveedor'] as Map<String, dynamic>)
            : null,
      );

  @override
  List<Object?> get props => [id, fkIdAlimento, precio];
}

class Proveedor extends Equatable {
  final int id;
  final String nombre;
  final String? contacto;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? notas;
  final List<ProveedorPrecio> precios;

  const Proveedor({
    required this.id,
    required this.nombre,
    this.contacto,
    this.telefono,
    this.email,
    this.direccion,
    this.notas,
    this.precios = const [],
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) => Proveedor(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        contacto: json['contacto'] as String?,
        telefono: json['telefono'] as String?,
        email: json['email'] as String?,
        direccion: json['direccion'] as String?,
        notas: json['notas'] as String?,
        precios: (json['precios'] as List<dynamic>? ?? [])
            .map((e) => ProveedorPrecio.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [id, nombre];
}