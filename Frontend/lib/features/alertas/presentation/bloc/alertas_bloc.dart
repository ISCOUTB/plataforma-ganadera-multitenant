import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/alertas_summary.dart';
import '../../domain/repositories/alertas_repository.dart';

sealed class AlertasEvent extends Equatable {
  const AlertasEvent();
  @override
  List<Object?> get props => [];
}

class AlertasStarted extends AlertasEvent {
  const AlertasStarted();
}

class AlertasRefreshed extends AlertasEvent {
  const AlertasRefreshed();
}

enum AlertasStatus { initial, loading, loaded, error }

class AlertasState extends Equatable {
  final AlertasStatus status;
  final AlertasSummary? data;
  final AppFailure? failure;

  const AlertasState({
    this.status = AlertasStatus.initial,
    this.data,
    this.failure,
  });

  AlertasState copyWith({
    AlertasStatus? status,
    AlertasSummary? data,
    AppFailure? failure,
  }) =>
      AlertasState(
        status: status ?? this.status,
        data: data ?? this.data,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, data, failure];
}

class AlertasBloc extends Bloc<AlertasEvent, AlertasState> {
  final AlertasRepository _repository;

  AlertasBloc({required AlertasRepository repository})
      : _repository = repository,
        super(const AlertasState()) {
    on<AlertasStarted>(_fetch);
    on<AlertasRefreshed>(_fetch);
  }

  Future<void> _fetch(AlertasEvent event, Emitter<AlertasState> emit) async {
    emit(state.copyWith(status: AlertasStatus.loading));
    final result = await _repository.getAll();
    result.fold(
      (f) => emit(state.copyWith(status: AlertasStatus.error, failure: f)),
      (d) => emit(state.copyWith(status: AlertasStatus.loaded, data: d)),
    );
  }
}
