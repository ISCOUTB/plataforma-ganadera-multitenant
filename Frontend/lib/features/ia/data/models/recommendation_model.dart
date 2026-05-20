import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/recommendation.dart';

/// Data model for [Recommendation] with JSON serialization support.
///
/// Extends the domain [Recommendation] entity and adds serialization/deserialization
/// capabilities for API communication.
class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.id,
    required super.category,
    required super.title,
    required super.description,
    required super.confidence,
    required super.generatedAt,
    super.actionUrl,
    super.targetAnimalId,
  });

  /// Creates a [RecommendationModel] from a JSON map.
  ///
  /// Handles various JSON formats and provides sensible defaults:
  /// - `id`: required, used as-is
  /// - `category`: parses using [RecommendationCategoryX.fromApi], defaults to 'alimentacion'
  /// - `title`: required field
  /// - `description`: required field
  /// - `actionUrl`: optional URL for actionable recommendations
  /// - `confidence`: parses as double, defaults to 0.8 if missing
  /// - `targetAnimalId`: optional animal ID this recommendation applies to
  /// - `generatedAt`: parses as DateTime, defaults to now if missing or invalid
  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    final generatedAt = _parseDate(json['generatedAt']);

    return RecommendationModel(
      id: (json['id'] as String?) ?? '',
      category: RecommendationCategoryX.fromApi(json['category'] as String?),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      actionUrl: json['actionUrl'] as String?,
      confidence: parseDouble(json['confidence']) ?? 0.8,
      targetAnimalId: json['targetAnimalId'] as String?,
      generatedAt: generatedAt ?? DateTime.now(),
    );
  }

  /// Converts this model to a JSON map suitable for API calls.
  ///
  /// Returns a map with camelCase keys matching API conventions.
  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.apiValue,
        'title': title,
        'description': description,
        'actionUrl': actionUrl,
        'confidence': confidence,
        'targetAnimalId': targetAnimalId,
        'generatedAt': generatedAt.toIso8601String(),
      };

  /// Creates a copy of this model with optionally overridden fields.
  ///
  /// Useful for immutable updates to specific fields without replacing
  /// the entire object.
  RecommendationModel copyWith({
    String? id,
    RecommendationCategory? category,
    String? title,
    String? description,
    String? actionUrl,
    double? confidence,
    String? targetAnimalId,
    DateTime? generatedAt,
  }) =>
      RecommendationModel(
        id: id ?? this.id,
        category: category ?? this.category,
        title: title ?? this.title,
        description: description ?? this.description,
        actionUrl: actionUrl ?? this.actionUrl,
        confidence: confidence ?? this.confidence,
        targetAnimalId: targetAnimalId ?? this.targetAnimalId,
        generatedAt: generatedAt ?? this.generatedAt,
      );

  /// Parses a dynamic value as a [DateTime].
  ///
  /// Handles null, empty strings, and invalid formats gracefully.
  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw.toString());
  }
}
