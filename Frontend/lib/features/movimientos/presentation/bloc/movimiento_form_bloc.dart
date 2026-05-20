import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/movimiento.dart';
import '../../domain/repositories/movimiento_repository.dart';

sealed class MovimientoFormEvent extends Equatable {
  const MovimientoFormEvent();
  @override
  List<Object?> get props => [];
}

class MovimientoFormSubmitted extends MovimientoFormEvent {
  final int animalId;
  final String potreroOrigenId;
  final String potreroDestinoId;
  final DateTime fecha;
  final String? motivo;

  const MovimientoFormSubmitted({
    required this.animalId,
    required this.potreroOrigenId,
    required this.potreroDestinoId,
    required this.fecha,
    this.motivo,
  });

  @override
  List<Object?> get props =>
      [animalId, potreroOrigenId, potreroDestinoId, fecha, motivo];
}

enum MovimientoFormStatus { idle, submitting, success, failure }

class MovimientoFormState extends Equatable {
  final MovimientoFormStatus status;
  final Movimiento? movimiento;
  final AppFailure? failure;

  const MovimientoFormState({
    this.status = MovimientoFormStatus.idle,
    this.movimiento,
    this.failure,
  });

  MovimientoFormState copyWith({
    MovimientoFormStatus? status,
    Movimiento? movimiento,
    AppFailure? failure,
  }) =>
      MovimientoFormState(
        status: status ?? this.status,
        movimiento: movimiento ?? this.movimiento,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, movimiento, failure];
}

class MovimientoFormBloc
    extends Bloc<MovimientoFormEvent, MovimientoFormState> {
  final MovimientoRepository _repository;

  MovimientoFormBloc({required MovimientoRepository repository})
      : _repository = repository,
        super(const MovimientoFormState()) {
    on<MovimientoFormSubmitted>((e, emit) async {
      emit(state.copyWith(status: MovimientoFormStatus.submitting));
      final r = await _repository.create(
        CreateMovimientoInput(
          animalId: e.animalId,
          potreroOrigenId: e.potreroOrigenId,
          potreroDestinoId: e.potreroDestinoId,
          fecha: e.fecha,
          motivo: e.motivo,
        ),
      );
      r.fold(
        (f) => emit(
            state.copyWith(status: MovimientoFormStatus.failure, failure: f)),
        (m) => emit(state.copyWith(
            status: MovimientoFormStatus.success, movimiento: m)),
      );
    });
  }
}
