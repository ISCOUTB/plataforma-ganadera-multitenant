import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard_inteligencia.dart';
import '../../domain/repositories/dashboard_repository.dart';

// ---------- Events ----------
sealed class DashboardInteligenciaEvent extends Equatable {
  const DashboardInteligenciaEvent();
  @override
  List<Object?> get props => [];
}

/// Dispara la carga lazy del bloque de inteligencia. Re-emitir este evento
/// (p. ej. al rotar la finca activa) recarga con el `fincaId` nuevo.
class DashboardInteligenciaRequested extends DashboardInteligenciaEvent {
  final String? fincaId;
  const DashboardInteligenciaRequested({this.fincaId});
  @override
  List<Object?> get props => [fincaId];
}

// ---------- State ----------
enum DashboardInteligenciaStatus { initial, loading, loaded, error }

class DashboardInteligenciaState extends Equatable {
  final DashboardInteligenciaStatus status;
  final DashboardInteligencia? data;
  final AppFailure? failure;

  const DashboardInteligenciaState({
    this.status = DashboardInteligenciaStatus.initial,
    this.data,
    this.failure,
  });

  DashboardInteligenciaState copyWith({
    DashboardInteligenciaStatus? status,
    DashboardInteligencia? data,
    AppFailure? failure,
  }) =>
      DashboardInteligenciaState(
        status: status ?? this.status,
        data: data ?? this.data,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, data, failure];
}

// ---------- Bloc ----------
class DashboardInteligenciaBloc
    extends Bloc<DashboardInteligenciaEvent, DashboardInteligenciaState> {
  final DashboardRepository _repository;

  DashboardInteligenciaBloc({required DashboardRepository repository})
      : _repository = repository,
        super(const DashboardInteligenciaState()) {
    on<DashboardInteligenciaRequested>(_onRequested);
  }

  Future<void> _onRequested(
    DashboardInteligenciaRequested event,
    Emitter<DashboardInteligenciaState> emit,
  ) async {
    emit(state.copyWith(status: DashboardInteligenciaStatus.loading));
    final either = await _repository.getInteligencia(fincaId: event.fincaId);
    either.fold(
      (failure) => emit(state.copyWith(
        status: DashboardInteligenciaStatus.error,
        failure: failure,
      )),
      (data) => emit(DashboardInteligenciaState(
        status: DashboardInteligenciaStatus.loaded,
        data: data,
      )),
    );
  }
}
