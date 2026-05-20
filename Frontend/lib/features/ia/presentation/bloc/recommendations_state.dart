import 'package:equatable/equatable.dart';

import '../../domain/entities/recommendation.dart';

sealed class RecommendationsState extends Equatable {
  const RecommendationsState();
  @override
  List<Object?> get props => [];
}

/// Initial state when recommendations feature first loads.
///
/// Used as the starting point before any user interaction or API call.
class RecommendationsInitialState extends RecommendationsState {
  const RecommendationsInitialState();
}

/// State emitted while waiting for recommendations API response.
///
/// Used during recommendations retrieval operations
/// to indicate the application is processing a request.
class RecommendationsLoadingState extends RecommendationsState {
  const RecommendationsLoadingState();
}

/// State emitted after successful recommendations retrieval.
///
/// Holds the list of recommendations for the current farm context.
class RecommendationsSuccessState extends RecommendationsState {
  final List<Recommendation> recommendations;

  const RecommendationsSuccessState(this.recommendations);

  @override
  List<Object?> get props => [recommendations];
}

/// State emitted when a recommendations operation fails.
///
/// Holds the error message describing what went wrong during the API call
/// or recommendations retrieval.
class RecommendationsErrorState extends RecommendationsState {
  final String message;

  const RecommendationsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
