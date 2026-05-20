import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/ia_repository.dart';
import 'recommendations_event.dart';
import 'recommendations_state.dart';

/// BLoC for managing recommendations from the AI service.
///
/// This BLoC handles retrieving recommendations for a specific farm,
/// managing the request lifecycle and handling success/error states.
class RecommendationsBloc
    extends Bloc<RecommendationsEvent, RecommendationsState> {
  final IaRepository _repository;

  RecommendationsBloc({required IaRepository repository})
      : _repository = repository,
        super(const RecommendationsInitialState()) {
    on<GetRecommendationsEvent>(_onGetRecommendations);
  }

  /// Handles getting recommendations for a specific tenant and farm.
  ///
  /// Flow:
  /// 1. Emit loading state
  /// 2. Call repository to get recommendations
  /// 3. On success: emit success state with recommendations list
  /// 4. On failure: emit error state with failure message
  Future<void> _onGetRecommendations(
    GetRecommendationsEvent event,
    Emitter<RecommendationsState> emit,
  ) async {
    emit(const RecommendationsLoadingState());

    final result = await _repository.getRecommendations(
      tenantId: event.tenantId,
      fincaId: event.fincaId,
    );

    result.fold(
      (failure) {
        emit(RecommendationsErrorState(failure.message));
      },
      (recommendations) {
        emit(RecommendationsSuccessState(recommendations));
      },
    );
  }
}
