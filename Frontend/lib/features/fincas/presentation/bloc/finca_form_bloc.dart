import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/finca.dart';
import '../../domain/repositories/finca_repository.dart';

sealed class FincaFormEvent extends Equatable {
  const FincaFormEvent();
  @override
  List<Object?> get props => [];
}

class FincaFormSubmitted extends FincaFormEvent {
  final String id;
  final String nombre;
  final String? ubicacion;
  final String? propietario;
  final double? areaTotal;
  final DateTime? fechaRegistro;
  final bool isEdit;

  const FincaFormSubmitted({
    required this.id,
    required this.nombre,
    this.ubicacion,
    this.propietario,
    this.areaTotal,
    this.fechaRegistro,
    required this.isEdit,
  });

  @override
  List<Object?> get props =>
      [id, nombre, ubicacion, propietario, areaTotal, fechaRegistro, isEdit];
}

enum FincaFormStatus { idle, submitting, success, failure }

class FincaFormState extends Equatable {
  final FincaFormStatus status;
  final Finca? finca;
  final AppFailure? failure;

  const FincaFormState({
    this.status = FincaFormStatus.idle,
    this.finca,
    this.failure,
  });

  FincaFormState copyWith({
    FincaFormStatus? status,
    Finca? finca,
    AppFailure? failure,
  }) =>
      FincaFormState(
        status: status ?? this.status,
        finca: finca ?? this.finca,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, finca, failure];
}

class FincaFormBloc extends Bloc<FincaFormEvent, FincaFormState> {
  final FincaRepository _repository;

  FincaFormBloc({required FincaRepository repository})
      : _repository = repository,
        super(const FincaFormState()) {
    on<FincaFormSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    FincaFormSubmitted event,
    Emitter<FincaFormState> emit,
  ) async {
    emit(state.copyWith(status: FincaFormStatus.submitting, failure: null));

    final result = event.isEdit
        ? await _repository.update(
            event.id,
            UpdateFincaInput(
              nombre: event.nombre,
              ubicacion: event.ubicacion,
              propietario: event.propietario,
              areaTotal: event.areaTotal,
              fechaRegistro: event.fechaRegistro,
            ),
          )
        : await _repository.create(
            CreateFincaInput(
              id: event.id,
              nombre: event.nombre,
              ubicacion: event.ubicacion,
              propietario: event.propietario,
              areaTotal: event.areaTotal,
              fechaRegistro: event.fechaRegistro,
            ),
          );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FincaFormStatus.failure,
        failure: failure,
      )),
      (finca) => emit(state.copyWith(
        status: FincaFormStatus.success,
        finca: finca,
      )),
    );
  }
}
