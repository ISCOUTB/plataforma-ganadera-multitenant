import 'package:equatable/equatable.dart';

sealed class PredictionsEvent extends Equatable {
  const PredictionsEvent();
  @override
  List<Object?> get props => [];
}

class GetPredictionsEvent extends PredictionsEvent {
  final String metric;
  final List<double> values;
  final String tenantId;
  final String fincaId;
  final int steps;

  const GetPredictionsEvent({
    required this.metric,
    required this.values,
    required this.tenantId,
    required this.fincaId,
    this.steps = 30,
  });

  @override
  List<Object?> get props => [metric, values, tenantId, fincaId, steps];
}
