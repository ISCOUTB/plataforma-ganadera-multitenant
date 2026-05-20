import 'package:equatable/equatable.dart';

enum RecommendationCategory {
  alimentacion,
  salud,
  reproduccion,
  finanzas,
}

extension RecommendationCategoryX on RecommendationCategory {
  String get apiValue => switch (this) {
        RecommendationCategory.alimentacion => 'alimentacion',
        RecommendationCategory.salud => 'salud',
        RecommendationCategory.reproduccion => 'reproduccion',
        RecommendationCategory.finanzas => 'finanzas',
      };

  String get label => switch (this) {
        RecommendationCategory.alimentacion => 'Alimentación',
        RecommendationCategory.salud => 'Salud',
        RecommendationCategory.reproduccion => 'Reproducción',
        RecommendationCategory.finanzas => 'Finanzas',
      };

  static RecommendationCategory fromApi(String? raw) => switch (raw) {
        'salud' => RecommendationCategory.salud,
        'reproduccion' => RecommendationCategory.reproduccion,
        'finanzas' => RecommendationCategory.finanzas,
        _ => RecommendationCategory.alimentacion,
      };
}

class Recommendation extends Equatable {
  final String id;
  final RecommendationCategory category;
  final String title;
  final String description;
  final String? actionUrl;
  final double confidence;
  final String? targetAnimalId;
  final DateTime generatedAt;

  const Recommendation({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.confidence,
    required this.generatedAt,
    this.actionUrl,
    this.targetAnimalId,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        title,
        description,
        actionUrl,
        confidence,
        targetAnimalId,
        generatedAt,
      ];
}
