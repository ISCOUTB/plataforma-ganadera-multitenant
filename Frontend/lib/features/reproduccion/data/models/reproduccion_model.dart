import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/reproduccion.dart';

class ReproduccionModel {
  final String pkIdReproduccion;
  final String? fkIdPadre;
  final String? fkIdMadre;
  final String? metodoReproduccion;
  final bool enCelo;
  final bool prenada;
  final int? numeroCrias;
  final DateTime? fechaEstimadoParto;

  ReproduccionModel({
    required this.pkIdReproduccion,
    required this.enCelo,
    required this.prenada,
    this.fkIdPadre,
    this.fkIdMadre,
    this.metodoReproduccion,
    this.numeroCrias,
    this.fechaEstimadoParto,
  });

  factory ReproduccionModel.fromJson(Map<String, dynamic> json) =>
      ReproduccionModel(
        pkIdReproduccion: json['pk_id_reproduccion'] as String,
        fkIdPadre: json['fk_id_padre'] as String?,
        fkIdMadre: json['fk_id_madre'] as String?,
        metodoReproduccion: json['metodo_reproduccion'] as String?,
        enCelo: (json['en_celo'] as bool?) ?? false,
        // El JSON usa la clave con ñ ("preñada")
        prenada: (json['preñada'] as bool?) ??
            (json['prenada'] as bool?) ??
            false,
        numeroCrias: parseInt(json['numero_crias']),
        fechaEstimadoParto: _parseDate(json['fecha_estimado_parto']),
      );

  Reproduccion toEntity() => Reproduccion(
        id: pkIdReproduccion,
        fkIdPadre: fkIdPadre,
        fkIdMadre: fkIdMadre,
        metodoReproduccion: metodoReproduccion,
        enCelo: enCelo,
        prenada: prenada,
        numeroCrias: numeroCrias,
        fechaEstimadoParto: fechaEstimadoParto,
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw.toString());
  }
}
