import 'package:equatable/equatable.dart';

sealed class RecommendationsEvent extends Equatable {
  const RecommendationsEvent();
  @override
  List<Object?> get props => [];
}

/// Event triggered when user wants recommendations for current farm.
///
/// This event includes the tenant ID and finca ID
/// needed to retrieve recommendations for the specific farm context.
class GetRecommendationsEvent extends RecommendationsEvent {
  final String tenantId;
  final String fincaId;

  const GetRecommendationsEvent({
    required this.tenantId,
    required this.fincaId,
  });

  @override
  List<Object?> get props => [tenantId, fincaId];
}
