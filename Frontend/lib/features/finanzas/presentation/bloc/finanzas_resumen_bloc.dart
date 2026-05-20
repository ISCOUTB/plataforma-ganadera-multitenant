import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/finanza.dart';
import '../../domain/repositories/finanza_repository.dart';

sealed class FinanzasResumenEvent extends Equatable {
  const FinanzasResumenEvent();
  @override
  List<Object?> get props => [];
}

class FinanzasResumenStarted extends FinanzasResumenEvent {
  const FinanzasResumenStarted();
}

class FinanzasResumenFincaFilterChanged extends FinanzasResumenEvent {
  final String? fincaId;
  const FinanzasResumenFincaFilterChanged({this.fincaId});
  @override
  List<Object?> get props => [fincaId];
}

enum FinanzasResumenStatus { initial, loading, loaded, error }

const _sentinel = Object();

class FinanzasResumenState extends Equatable {
  final FinanzasResumenStatus status;
  final FinanzasResumen? data;
  final String? fincaIdFilter;
  final AppFailure? failure;

  const FinanzasResumenState({
    this.status = FinanzasResumenStatus.initial,
    this.data,
    this.fincaIdFilter,
    this.failure,
  });

  FinanzasResumenState copyWith({
    FinanzasResumenStatus? status,
    FinanzasResumen? data,
    Object? fincaIdFilter = _sentinel,
    AppFailure? failure,
  }) =>
      FinanzasResumenState(
        status: status ?? this.status,
        data: data ?? this.data,
        fincaIdFilter: fincaIdFilter == _sentinel
            ? this.fincaIdFilter
            : fincaIdFilter as String?,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, data, fincaIdFilter, failure];
}

class FinanzasResumenBloc
    extends Bloc<FinanzasResumenEvent, FinanzasResumenState> {
  final FinanzaRepository _repository;

  FinanzasResumenBloc({required FinanzaRepository repository})
      : _repository = repository,
        super(const FinanzasResumenState()) {
    on<FinanzasResumenStarted>((e, emit) async {
      await _fetch(emit);
    });
    on<FinanzasResumenFincaFilterChanged>((e, emit) async {
      if (state.status == FinanzasResumenStatus.loaded &&
          state.fincaIdFilter == e.fincaId) {
        return;
      }
      emit(state.copyWith(fincaIdFilter: e.fincaId));
      await _fetch(emit);
    });
  }

  Future<void> _fetch(Emitter<FinanzasResumenState> emit) async {
    emit(state.copyWith(status: FinanzasResumenStatus.loading));
    final r = await _repository.getResumen(fincaId: state.fincaIdFilter);
    r.fold(
      (f) =>
          emit(state.copyWith(status: FinanzasResumenStatus.error, failure: f)),
      (d) =>
          emit(state.copyWith(status: FinanzasResumenStatus.loaded, data: d)),
    );
  }
}
