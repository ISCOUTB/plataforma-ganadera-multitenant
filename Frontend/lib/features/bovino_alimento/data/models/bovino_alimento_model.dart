import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/bovino_alimento.dart';

class BovinoAlimentoModel {
  final int fkIdBovino;
  final String fkIdAlimento;
  final double cantidad;
  final DateTime fecha;
  final String? alimentoNombre;
  final double? alimentoCosto;

  const BovinoAlimentoModel({
    required this.fkIdBovino,
    required this.fkIdAlimento,
    required this.cantidad,
    required this.fecha,
    this.alimentoNombre,
    this.alimentoCosto,
  });

  factory BovinoAlimentoModel.fromJson(Map<String, dynamic> json) {
    final alimento = json['alimento'];
    final alimentoMap =
        alimento is Map<String, dynamic> ? alimento : const <String, dynamic>{};

    final bovino = json['bovino'];
    final bovinoMap =
        bovino is Map<String, dynamic> ? bovino : const <String, dynamic>{};

    final animalId = parseInt(json['fk_id_bovino']) ??
        parseInt(json['animalId']) ??
        parseInt(bovinoMap['id']) ??
        0;

    final alimentoId = (json['fk_id_alimento'] as String?) ??
        (json['alimentoId'] as String?) ??
        (alimentoMap['pk_id_alimento'] as String?) ??
        '';

    return BovinoAlimentoModel(
      fkIdBovino: animalId,
      fkIdAlimento: alimentoId,
      cantidad: parseDouble(json['cantidad']) ?? 0,
      fecha: _parseDate(json['fecha']) ?? DateTime.now(),
      alimentoNombre: alimentoMap['tipo_alimento'] as String?,
      alimentoCosto: parseDouble(alimentoMap['costo']),
    );
  }

  BovinoAlimento toEntity() => BovinoAlimento(
        animalId: fkIdBovino,
        alimentoId: fkIdAlimento,
        cantidad: cantidad,
        fecha: fecha,
        alimentoNombre: alimentoNombre,
        alimentoCosto: alimentoCosto,
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw.toString());
  }
}
