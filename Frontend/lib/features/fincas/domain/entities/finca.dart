import 'package:equatable/equatable.dart';

class Finca extends Equatable {
  final String id; // pk_id_finca (string ej. FINCA001)
  final String nombre;
  final String? ubicacion;
  final String? propietario;
  final double? areaTotal;
  final DateTime? fechaRegistro;

  const Finca({
    required this.id,
    required this.nombre,
    this.ubicacion,
    this.propietario,
    this.areaTotal,
    this.fechaRegistro,
  });

  @override
  List<Object?> get props =>
      [id, nombre, ubicacion, propietario, areaTotal, fechaRegistro];
}
