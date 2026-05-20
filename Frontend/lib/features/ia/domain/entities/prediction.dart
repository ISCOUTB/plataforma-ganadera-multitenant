import 'package:equatable/equatable.dart';

enum PredictionType { precio, produccion, crecimiento }

extension PredictionTypeX on PredictionType {
  String get apiValue => switch (this) {
        PredictionType.precio => 'precio',
        PredictionType.produccion => 'produccion',
        PredictionType.crecimiento => 'crecimiento',
      };

  String get label => switch (this) {
        PredictionType.precio => 'Precio',
        PredictionType.produccion => 'Producción',
        PredictionType.crecimiento => 'Crecimiento',
      };

  static PredictionType fromApi(String? raw) => switch (raw) {
        'produccion' => PredictionType.produccion,
        'crecimiento' => PredictionType.crecimiento,
        _ => PredictionType.precio,
      };
}

enum TrendType { up, down, stable }

extension TrendTypeX on TrendType {
  String get apiValue => switch (this) {
        TrendType.up => 'up',
        TrendType.down => 'down',
        TrendType.stable => 'stable',
      };

  String get label => switch (this) {
        TrendType.up => 'Ascendente',
        TrendType.down => 'Descendente',
        TrendType.stable => 'Estable',
      };

  static TrendType fromApi(String? raw) => switch (raw) {
        'down' => TrendType.down,
        'stable' => TrendType.stable,
        _ => TrendType.up,
      };
}

class Prediction extends Equatable {
  final String id;
  final PredictionType type;
  final String metric;
  final List<double> values;
  final List<String> labels;
  final double confidence;
  final TrendType trend;
  final String description;
  final DateTime generatedAt;

  const Prediction({
    required this.id,
    required this.type,
    required this.metric,
    required this.values,
    required this.labels,
    required this.confidence,
    required this.trend,
    required this.description,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        metric,
        values,
        labels,
        confidence,
        trend,
        description,
        generatedAt,
      ];
}
