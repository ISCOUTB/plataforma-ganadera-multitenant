import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/potrero.dart';
import '../../domain/repositories/potrero_repository.dart';

sealed class PotreroFormEvent extends Equatable {
  const PotreroFormEvent();
  @override
  List<Object?> get props => [];
}

class PotreroFormSubmitted extends PotreroFormEvent {
  final String id;
  final String nombre;
  final int capacidadAnimales;
  final double? area;
  final String? estado;
  final String? fincaId;
  final bool isEdit;

  const PotreroFormSubmitted({
    required this.id,
    required this.nombre,
    required this.capacidadAnimales,
    this.area,
    this.estado,
    this.fincaId,
    required this.isEdit,
  });

  @override
  List<Object?> get props =>
      [id, nombre, capacidadAnimales, area, estado, fincaId, isEdit];
}

enum PotreroFormStatus { idle, submitting, success, failure }

class PotreroFormState extends Equatable {
  final PotreroFormStatus status;
  final Potrero? potrero;
  final AppFailure? failure;

  const PotreroFormState({
    this.status = PotreroFormStatus.idle,
    this.potrero,
    this.failure,
  });

  PotreroFormState copyWith({
    PotreroFormStatus? status,
    Potrero? potrero,
    AppFailure? failure,
  }) =>
      PotreroFormState(
        status: status ?? this.status,
        potrero: potrero ?? this.potrero,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, potrero, failure];
}

class PotreroFormBloc extends Bloc<PotreroFormEvent, PotreroFormState> {
  final PotreroRepository _repository;

  PotreroFormBloc({required PotreroRepository repository})
      : _repository = repository,
        super(const PotreroFormState()) {
    on<PotreroFormSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    PotreroFormSubmitted event,
    Emitter<PotreroFormState> emit,
  ) async {
    emit(state.copyWith(status: PotreroFormStatus.submitting, failure: null));
    final result = event.isEdit
        ? await _repository.update(
            event.id,
            UpdatePotreroInput(
              nombre: event.nombre,
              capacidadAnimales: event.capacidadAnimales,
              area: event.area,
              estado: event.estado,
              fincaId: event.fincaId,
            ),
          )
        : await _repository.create(
            CreatePotreroInput(
              id: event.id,
              nombre: event.nombre,
              capacidadAnimales: event.capacidadAnimales,
              area: event.area,
              estado: event.estado,
              fincaId: event.fincaId,
            ),
          );
    result.fold(
      (failure) => emit(state.copyWith(
        status: PotreroFormStatus.failure,
        failure: failure,
      )),
      (potrero) => emit(state.copyWith(
        status: PotreroFormStatus.success,
        potrero: potrero,
      )),
    );
  }
}
