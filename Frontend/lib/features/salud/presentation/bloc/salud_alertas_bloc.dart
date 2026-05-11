import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/salud.dart';
import '../../domain/repositories/salud_repository.dart';

sealed class SaludAlertasEvent extends Equatable {
  const SaludAlertasEvent();
  @override
  List<Object?> get props => [];
}

class SaludAlertasStarted extends SaludAlertasEvent {
  const SaludAlertasStarted();
}

enum SaludAlertasStatus { initial, loading, loaded, error }

class SaludAlertasState extends Equatable {
  final SaludAlertasStatus status;
  final SaludAlertas? data;
  final AppFailure? failure;

  const SaludAlertasState({
    this.status = SaludAlertasStatus.initial,
    this.data,
    this.failure,
  });

  SaludAlertasState copyWith({
    SaludAlertasStatus? status,
    SaludAlertas? data,
    AppFailure? failure,
  }) =>
      SaludAlertasState(
        status: status ?? this.status,
        data: data ?? this.data,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, data, failure];
}

class SaludAlertasBloc extends Bloc<SaludAlertasEvent, SaludAlertasState> {
  final SaludRepository _repository;

  SaludAlertasBloc({required SaludRepository repository})
      : _repository = repository,
        super(const SaludAlertasState()) {
    on<SaludAlertasStarted>(_onStarted);
  }

  Future<void> _onStarted(
    SaludAlertasStarted event,
    Emitter<SaludAlertasState> emit,
  ) async {
    emit(state.copyWith(status: SaludAlertasStatus.loading));
    final result = await _repository.getAlertas();
    result.fold(
      (failure) =>
          emit(state.copyWith(status: SaludAlertasStatus.error, failure: failure)),
      (data) =>
          emit(state.copyWith(status: SaludAlertasStatus.loaded, data: data)),
    );
  }
}
