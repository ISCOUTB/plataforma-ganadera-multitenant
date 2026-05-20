import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/movimiento.dart';

class MovimientoModel {
  final int id;
  final int? animalId;
  final String? potreroOrigen;
  final String? potreroDestino;
  final DateTime? fecha;
  final String? motivo;

  MovimientoModel({
    required this.id,
    this.animalId,
    this.potreroOrigen,
    this.potreroDestino,
    this.fecha,
    this.motivo,
  });

  factory MovimientoModel.fromJson(Map<String, dynamic> json) => MovimientoModel(
        id: parseInt(json['id'])!,
        animalId: parseInt(json['animalId']) ??
            (json['animal'] is Map
                ? parseInt((json['animal'] as Map)['id'])
                : null),
        potreroOrigen: (json['potreroOrigen'] is Map
            ? (json['potreroOrigen'] as Map)['nombre_potrero'] as String?
            : null) ??
            json['potreroOrigenId'] as String?,
        potreroDestino: (json['potreroDestino'] is Map
            ? (json['potreroDestino'] as Map)['nombre_potrero'] as String?
            : null) ??
            json['potreroDestinoId'] as String?,
        fecha: _parseDate(json['fecha']),
        motivo: json['motivo'] as String?,
      );

  Movimiento toEntity() => Movimiento(
        id: id,
        animalId: animalId,
        potreroOrigen: potreroOrigen,
        potreroDestino: potreroDestino,
        fecha: fecha,
        motivo: motivo,
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw.toString());
  }
}
