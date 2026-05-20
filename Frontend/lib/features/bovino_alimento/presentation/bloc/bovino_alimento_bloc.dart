import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/bovino_alimento.dart';
import '../../domain/repositories/bovino_alimento_repository.dart';

sealed class BovinoAlimentoEvent extends Equatable {
  const BovinoAlimentoEvent();
  @override
  List<Object?> get props => [];
}

class BovinoAlimentoLoadByAnimal extends BovinoAlimentoEvent {
  final int animalId;
  const BovinoAlimentoLoadByAnimal(this.animalId);
  @override
  List<Object?> get props => [animalId];
}

class BovinoAlimentoAssign extends BovinoAlimentoEvent {
  final int animalId;
  final String alimentoId;
  final double cantidad;
  final DateTime fecha;

  const BovinoAlimentoAssign({
    required this.animalId,
    required this.alimentoId,
    required this.cantidad,
    required this.fecha,
  });

  @override
  List<Object?> get props => [animalId, alimentoId, cantidad, fecha];
}

class BovinoAlimentoRemoved extends BovinoAlimentoEvent {
  final int animalId;
  final String alimentoId;

  const BovinoAlimentoRemoved({
    required this.animalId,
    required this.alimentoId,
  });

  @override
  List<Object?> get props => [animalId, alimentoId];
}

enum BovinoAlimentoStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  error,
}

class BovinoAlimentoState extends Equatable {
  final BovinoAlimentoStatus status;
  final List<BovinoAlimento> items;
  final int? animalId;
  final AppFailure? failure;

  const BovinoAlimentoState({
    this.status = BovinoAlimentoStatus.initial,
    this.items = const [],
    this.animalId,
    this.failure,
  });

  BovinoAlimentoState copyWith({
    BovinoAlimentoStatus? status,
    List<BovinoAlimento>? items,
    int? animalId,
    AppFailure? failure,
  }) =>
      BovinoAlimentoState(
        status: status ?? this.status,
        items: items ?? this.items,
        animalId: animalId ?? this.animalId,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, items, animalId, failure];
}

class BovinoAlimentoBloc
    extends Bloc<BovinoAlimentoEvent, BovinoAlimentoState> {
  final BovinoAlimentoRepository _repository;

  BovinoAlimentoBloc({required BovinoAlimentoRepository repository})
      : _repository = repository,
        super(const BovinoAlimentoState()) {
    on<BovinoAlimentoLoadByAnimal>(_onLoad);
    on<BovinoAlimentoAssign>(_onAssign);
    on<BovinoAlimentoRemoved>(_onRemoved);
  }

  Future<void> _onLoad(
    BovinoAlimentoLoadByAnimal event,
    Emitter<BovinoAlimentoState> emit,
  ) async {
    emit(state.copyWith(
      status: BovinoAlimentoStatus.loading,
      animalId: event.animalId,
    ));
    final result = await _repository.getByAnimal(event.animalId);
    result.fold(
      (f) => emit(state.copyWith(
        status: BovinoAlimentoStatus.error,
        failure: f,
      )),
      (items) => emit(state.copyWith(
        status: BovinoAlimentoStatus.loaded,
        items: items,
      )),
    );
  }

  Future<void> _onAssign(
    BovinoAlimentoAssign event,
    Emitter<BovinoAlimentoState> emit,
  ) async {
    emit(state.copyWith(status: BovinoAlimentoStatus.submitting));
    final result = await _repository.assign(
      AsignarBovinoAlimentoInput(
        animalId: event.animalId,
        alimentoId: event.alimentoId,
        cantidad: event.cantidad,
        fecha: event.fecha,
      ),
    );
    result.fold(
      (f) => emit(state.copyWith(
        status: BovinoAlimentoStatus.error,
        failure: f,
      )),
      (item) {
        final updated = [item, ...state.items];
        emit(state.copyWith(
          status: BovinoAlimentoStatus.success,
          items: updated,
        ));
        emit(state.copyWith(
          status: BovinoAlimentoStatus.loaded,
          items: updated,
        ));
      },
    );
  }

  Future<void> _onRemoved(
    BovinoAlimentoRemoved event,
    Emitter<BovinoAlimentoState> emit,
  ) async {
    emit(state.copyWith(status: BovinoAlimentoStatus.submitting));
    final result = await _repository.remove(event.animalId, event.alimentoId);
    result.fold(
      (f) => emit(state.copyWith(
        status: BovinoAlimentoStatus.error,
        failure: f,
      )),
      (_) => emit(state.copyWith(
        status: BovinoAlimentoStatus.loaded,
        items: state.items
            .where((i) => !(i.animalId == event.animalId &&
                i.alimentoId == event.alimentoId))
            .toList(),
      )),
    );
  }
}
