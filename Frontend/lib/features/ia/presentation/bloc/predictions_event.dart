import 'package:equatable/equatable.dart';

sealed class PredictionsEvent extends Equatable {
  const PredictionsEvent();
  @override
  List<Object?> get props => [];
}

/// Event triggered when user wants predictions for a specific farm.
///
/// This event includes the tenant ID and finca ID
/// needed to retrieve predictions through the AI service.
class GetPredictionsEvent extends PredictionsEvent {
  final String tenantId;
  final String fincaId;

  const GetPredictionsEvent({
    required this.tenantId,
    required this.fincaId,
  });

  @override
  List<Object?> get props => [tenantId, fincaId];
}
