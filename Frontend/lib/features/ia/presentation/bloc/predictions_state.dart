import 'package:equatable/equatable.dart';

import '../../domain/entities/prediction.dart';

sealed class PredictionsState extends Equatable {
  const PredictionsState();
  @override
  List<Object?> get props => [];
}

/// Initial state when predictions feature first loads.
///
/// Used as the starting point before any user interaction or API call.
class PredictionsInitialState extends PredictionsState {
  const PredictionsInitialState();
}

/// State emitted while waiting for predictions API response.
///
/// Used during prediction retrieval operations
/// to indicate the application is processing a request.
class PredictionsLoadingState extends PredictionsState {
  const PredictionsLoadingState();
}

/// State emitted after successful predictions retrieval.
///
/// Holds the list of predictions for the specific farm context.
class PredictionsSuccessState extends PredictionsState {
  final List<Prediction> predictions;

  const PredictionsSuccessState(this.predictions);

  @override
  List<Object?> get props => [predictions];
}

/// State emitted when a prediction operation fails.
///
/// Holds the error message describing what went wrong during the API call
/// or prediction retrieval.
class PredictionsErrorState extends PredictionsState {
  final String message;

  const PredictionsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
