import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/prediction.dart';

/// Data model for [Prediction] with JSON serialization support.
///
/// Extends the domain [Prediction] entity and adds serialization/deserialization
/// capabilities for API communication.
class PredictionModel extends Prediction {
  const PredictionModel({
    required super.id,
    required super.type,
    required super.metric,
    required super.values,
    required super.labels,
    required super.confidence,
    required super.trend,
    required super.description,
    required super.generatedAt,
  });

  /// Creates a [PredictionModel] from a JSON map.
  ///
  /// Handles various JSON formats and provides sensible defaults:
  /// - `id`: required, used as-is
  /// - `type`: parses using [PredictionTypeX.fromApi], defaults to 'precio'
  /// - `metric`: required field name
  /// - `values`: List of double values, defaults to empty list if missing
  /// - `labels`: List of string labels, defaults to empty list if missing
  /// - `confidence`: parses as double, defaults to 0.0 if missing
  /// - `trend`: parses using [TrendTypeX.fromApi], defaults to 'up'
  /// - `description`: required field
  /// - `generatedAt`: parses as DateTime, defaults to now if missing or invalid
  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    final generatedAt = _parseDate(json['generatedAt']);
    final values = _parseDoubleList(json['values']);
    final labels = _parseStringList(json['labels']);

    return PredictionModel(
      id: (json['id'] as String?) ?? '',
      type: PredictionTypeX.fromApi(json['type'] as String?),
      metric: (json['metric'] as String?) ?? '',
      values: values,
      labels: labels,
      confidence: parseDouble(json['confidence']) ?? 0.0,
      trend: TrendTypeX.fromApi(json['trend'] as String?),
      description: (json['description'] as String?) ?? '',
      generatedAt: generatedAt ?? DateTime.now(),
    );
  }

  /// Converts this model to a JSON map suitable for API calls.
  ///
  /// Returns a map with camelCase keys matching API conventions.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.apiValue,
        'metric': metric,
        'values': values,
        'labels': labels,
        'confidence': confidence,
        'trend': trend.apiValue,
        'description': description,
        'generatedAt': generatedAt.toIso8601String(),
      };

  /// Parses a dynamic value as a [DateTime].
  ///
  /// Handles null, empty strings, and invalid formats gracefully.
  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw.toString());
  }

  /// Parses a dynamic value as a list of doubles.
  ///
  /// Handles null, non-list types, and invalid conversions gracefully.
  static List<double> _parseDoubleList(dynamic raw) {
    if (raw == null) return [];
    if (raw is! List) return [];
    
    return raw
        .map((item) {
          if (item is num) return item.toDouble();
          if (item is String) return double.tryParse(item);
          return null;
        })
        .whereType<double>()
        .toList();
  }

  /// Parses a dynamic value as a list of strings.
  ///
  /// Handles null, non-list types, and null items gracefully.
  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return [];
    if (raw is! List) return [];
    
    return raw
        .map((item) => item?.toString())
        .whereType<String>()
        .toList();
  }
}
