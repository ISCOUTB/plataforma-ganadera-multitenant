import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/alimento.dart';
import '../../domain/repositories/alimento_repository.dart';

sealed class AlimentoFormEvent extends Equatable {
  const AlimentoFormEvent();
  @override
  List<Object?> get props => [];
}

class AlimentoFormSubmitted extends AlimentoFormEvent {
  final String? editId;
  final String id;
  final String tipoAlimento;
  final double? cantidadTotal;
  final String? frecuencia;
  final double? costo;

  const AlimentoFormSubmitted({
    this.editId,
    required this.id,
    required this.tipoAlimento,
    this.cantidadTotal,
    this.frecuencia,
    this.costo,
  });

  bool get isEdit => editId != null;

  @override
  List<Object?> get props =>
      [editId, id, tipoAlimento, cantidadTotal, frecuencia, costo];
}

enum AlimentoFormStatus { idle, submitting, success, failure }

class AlimentoFormState extends Equatable {
  final AlimentoFormStatus status;
  final Alimento? alimento;
  final AppFailure? failure;

  const AlimentoFormState({
    this.status = AlimentoFormStatus.idle,
    this.alimento,
    this.failure,
  });

  AlimentoFormState copyWith({
    AlimentoFormStatus? status,
    Alimento? alimento,
    AppFailure? failure,
  }) =>
      AlimentoFormState(
        status: status ?? this.status,
        alimento: alimento ?? this.alimento,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, alimento, failure];
}

class AlimentoFormBloc extends Bloc<AlimentoFormEvent, AlimentoFormState> {
  final AlimentoRepository _repository;

  AlimentoFormBloc({required AlimentoRepository repository})
      : _repository = repository,
        super(const AlimentoFormState()) {
    on<AlimentoFormSubmitted>((e, emit) async {
      emit(state.copyWith(status: AlimentoFormStatus.submitting));
      final r = e.isEdit
          ? await _repository.update(
              e.editId!,
              UpdateAlimentoInput(
                tipoAlimento: e.tipoAlimento,
                cantidadTotal: e.cantidadTotal,
                frecuencia: e.frecuencia,
                costo: e.costo,
              ),
            )
          : await _repository.create(
              CreateAlimentoInput(
                id: e.id,
                tipoAlimento: e.tipoAlimento,
                cantidadTotal: e.cantidadTotal,
                frecuencia: e.frecuencia,
                costo: e.costo,
              ),
            );
      r.fold(
        (f) => emit(
            state.copyWith(status: AlimentoFormStatus.failure, failure: f)),
        (a) =>
            emit(state.copyWith(status: AlimentoFormStatus.success, alimento: a)),
      );
    });
  }
}
