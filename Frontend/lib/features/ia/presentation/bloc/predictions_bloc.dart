import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/ia_repository.dart';
import 'predictions_event.dart';
import 'predictions_state.dart';

/// BLoC for managing predictions from the AI service.
///
/// This BLoC handles retrieving predictions for a specific farm,
/// managing the request lifecycle and handling success/error states.
class PredictionsBloc extends Bloc<PredictionsEvent, PredictionsState> {
  final IaRepository _repository;

  PredictionsBloc({required IaRepository repository})
      : _repository = repository,
        super(const PredictionsInitialState()) {
    on<GetPredictionsEvent>(_onGetPredictions);
  }

  /// Handles getting predictions for a specific tenant and farm.
  ///
  /// Flow:
  /// 1. Emit loading state
  /// 2. Call repository to get predictions
  /// 3. On success: emit success state with predictions list
  /// 4. On failure: emit error state with failure message
  Future<void> _onGetPredictions(
    GetPredictionsEvent event,
    Emitter<PredictionsState> emit,
  ) async {
    emit(const PredictionsLoadingState());

    final result = await _repository.getPredictions(
      tenantId: event.tenantId,
      fincaId: event.fincaId,
    );

    result.fold(
      (failure) {
        emit(PredictionsErrorState(failure.message));
      },
      (predictions) {
        emit(PredictionsSuccessState(predictions));
      },
    );
  }
}
