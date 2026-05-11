import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/salud.dart';
import '../../domain/repositories/salud_repository.dart';

sealed class SaludFormEvent extends Equatable {
  const SaludFormEvent();
  @override
  List<Object?> get props => [];
}

class SaludFormSubmitted extends SaludFormEvent {
  final int? editId;
  final TipoIntervencion tipoIntervencion;
  final String? productoAplicado;
  final String? dosis;
  final DateTime? fechaAplicacion;
  final DateTime? fechaProximaAplicacion;
  final double? costo;
  final int? animalId;

  const SaludFormSubmitted({
    this.editId,
    required this.tipoIntervencion,
    this.productoAplicado,
    this.dosis,
    this.fechaAplicacion,
    this.fechaProximaAplicacion,
    this.costo,
    this.animalId,
  });

  bool get isEdit => editId != null;

  @override
  List<Object?> get props => [
        editId,
        tipoIntervencion,
        productoAplicado,
        fechaAplicacion,
        fechaProximaAplicacion,
        costo,
        animalId,
      ];
}

enum SaludFormStatus { idle, submitting, success, failure }

class SaludFormState extends Equatable {
  final SaludFormStatus status;
  final Salud? salud;
  final AppFailure? failure;

  const SaludFormState({
    this.status = SaludFormStatus.idle,
    this.salud,
    this.failure,
  });

  SaludFormState copyWith({
    SaludFormStatus? status,
    Salud? salud,
    AppFailure? failure,
  }) =>
      SaludFormState(
        status: status ?? this.status,
        salud: salud ?? this.salud,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, salud, failure];
}

class SaludFormBloc extends Bloc<SaludFormEvent, SaludFormState> {
  final SaludRepository _repository;

  SaludFormBloc({required SaludRepository repository})
      : _repository = repository,
        super(const SaludFormState()) {
    on<SaludFormSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    SaludFormSubmitted event,
    Emitter<SaludFormState> emit,
  ) async {
    emit(state.copyWith(status: SaludFormStatus.submitting, failure: null));
    final result = event.isEdit
        ? await _repository.update(
            event.editId!,
            UpdateSaludInput(
              tipoIntervencion: event.tipoIntervencion,
              productoAplicado: event.productoAplicado,
              dosis: event.dosis,
              fechaAplicacion: event.fechaAplicacion,
              fechaProximaAplicacion: event.fechaProximaAplicacion,
              costo: event.costo,
              animalId: event.animalId,
            ),
          )
        : await _repository.create(
            CreateSaludInput(
              tipoIntervencion: event.tipoIntervencion,
              productoAplicado: event.productoAplicado,
              dosis: event.dosis,
              fechaAplicacion: event.fechaAplicacion,
              fechaProximaAplicacion: event.fechaProximaAplicacion,
              costo: event.costo,
              animalId: event.animalId,
            ),
          );
    result.fold(
      (failure) =>
          emit(state.copyWith(status: SaludFormStatus.failure, failure: failure)),
      (salud) =>
          emit(state.copyWith(status: SaludFormStatus.success, salud: salud)),
    );
  }
}
