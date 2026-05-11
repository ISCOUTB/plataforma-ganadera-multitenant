import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/reproduccion.dart';
import '../../domain/repositories/reproduccion_repository.dart';

sealed class ReproduccionFormEvent extends Equatable {
  const ReproduccionFormEvent();
  @override
  List<Object?> get props => [];
}

class ReproduccionFormSubmitted extends ReproduccionFormEvent {
  final String? editId;
  final String id;
  final String? metodoReproduccion;
  final bool enCelo;
  final bool prenada;
  final int? numeroCrias;
  final DateTime? fechaEstimadoParto;

  const ReproduccionFormSubmitted({
    this.editId,
    required this.id,
    this.metodoReproduccion,
    required this.enCelo,
    required this.prenada,
    this.numeroCrias,
    this.fechaEstimadoParto,
  });

  bool get isEdit => editId != null;

  @override
  List<Object?> get props =>
      [editId, id, metodoReproduccion, enCelo, prenada, numeroCrias];
}

enum ReproduccionFormStatus { idle, submitting, success, failure }

class ReproduccionFormState extends Equatable {
  final ReproduccionFormStatus status;
  final Reproduccion? reproduccion;
  final AppFailure? failure;

  const ReproduccionFormState({
    this.status = ReproduccionFormStatus.idle,
    this.reproduccion,
    this.failure,
  });

  ReproduccionFormState copyWith({
    ReproduccionFormStatus? status,
    Reproduccion? reproduccion,
    AppFailure? failure,
  }) =>
      ReproduccionFormState(
        status: status ?? this.status,
        reproduccion: reproduccion ?? this.reproduccion,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, reproduccion, failure];
}

class ReproduccionFormBloc
    extends Bloc<ReproduccionFormEvent, ReproduccionFormState> {
  final ReproduccionRepository _repository;

  ReproduccionFormBloc({required ReproduccionRepository repository})
      : _repository = repository,
        super(const ReproduccionFormState()) {
    on<ReproduccionFormSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    ReproduccionFormSubmitted event,
    Emitter<ReproduccionFormState> emit,
  ) async {
    emit(state.copyWith(status: ReproduccionFormStatus.submitting));
    final result = event.isEdit
        ? await _repository.update(
            event.editId!,
            UpdateReproduccionInput(
              metodoReproduccion: event.metodoReproduccion,
              enCelo: event.enCelo,
              prenada: event.prenada,
              numeroCrias: event.numeroCrias,
              fechaEstimadoParto: event.fechaEstimadoParto,
            ),
          )
        : await _repository.create(
            CreateReproduccionInput(
              id: event.id,
              metodoReproduccion: event.metodoReproduccion,
              enCelo: event.enCelo,
              prenada: event.prenada,
              numeroCrias: event.numeroCrias,
              fechaEstimadoParto: event.fechaEstimadoParto,
            ),
          );
    result.fold(
      (f) => emit(
          state.copyWith(status: ReproduccionFormStatus.failure, failure: f)),
      (r) => emit(state.copyWith(
          status: ReproduccionFormStatus.success, reproduccion: r)),
    );
  }
}
