import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';

sealed class AnimalFormEvent extends Equatable {
  const AnimalFormEvent();
  @override
  List<Object?> get props => [];
}

class AnimalFormSubmitted extends AnimalFormEvent {
  final int? editId;
  final String numeroIdentificacion;
  final DateTime fechaNacimiento;
  final AnimalGenero genero;
  final double peso;
  final String raza;
  final double? altura;
  final String? fincaId;
  final String? potreroId;

  const AnimalFormSubmitted({
    this.editId,
    required this.numeroIdentificacion,
    required this.fechaNacimiento,
    required this.genero,
    required this.peso,
    required this.raza,
    this.altura,
    this.fincaId,
    this.potreroId,
  });

  bool get isEdit => editId != null;

  @override
  List<Object?> get props => [
        editId,
        numeroIdentificacion,
        fechaNacimiento,
        genero,
        peso,
        raza,
        altura,
        fincaId,
        potreroId,
      ];
}

enum AnimalFormStatus { idle, submitting, success, failure }

class AnimalFormState extends Equatable {
  final AnimalFormStatus status;
  final Animal? animal;
  final AppFailure? failure;

  const AnimalFormState({
    this.status = AnimalFormStatus.idle,
    this.animal,
    this.failure,
  });

  AnimalFormState copyWith({
    AnimalFormStatus? status,
    Animal? animal,
    AppFailure? failure,
  }) =>
      AnimalFormState(
        status: status ?? this.status,
        animal: animal ?? this.animal,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, animal, failure];
}

class AnimalFormBloc extends Bloc<AnimalFormEvent, AnimalFormState> {
  final AnimalRepository _repository;

  AnimalFormBloc({required AnimalRepository repository})
      : _repository = repository,
        super(const AnimalFormState()) {
    on<AnimalFormSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    AnimalFormSubmitted event,
    Emitter<AnimalFormState> emit,
  ) async {
    emit(state.copyWith(status: AnimalFormStatus.submitting, failure: null));
    final result = event.isEdit
        ? await _repository.update(
            event.editId!,
            UpdateAnimalInput(
              numeroIdentificacion: event.numeroIdentificacion,
              fechaNacimiento: event.fechaNacimiento,
              genero: event.genero,
              peso: event.peso,
              raza: event.raza,
              altura: event.altura,
              fincaId: event.fincaId,
              potreroId: event.potreroId,
            ),
          )
        : await _repository.create(
            CreateAnimalInput(
              numeroIdentificacion: event.numeroIdentificacion,
              fechaNacimiento: event.fechaNacimiento,
              genero: event.genero,
              peso: event.peso,
              raza: event.raza,
              altura: event.altura,
              fincaId: event.fincaId,
              potreroId: event.potreroId,
            ),
          );
    result.fold(
      (failure) => emit(
        state.copyWith(status: AnimalFormStatus.failure, failure: failure),
      ),
      (animal) => emit(
        state.copyWith(status: AnimalFormStatus.success, animal: animal),
      ),
    );
  }
}
