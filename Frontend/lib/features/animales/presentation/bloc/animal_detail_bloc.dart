import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';

sealed class AnimalDetailEvent extends Equatable {
  const AnimalDetailEvent();
  @override
  List<Object?> get props => [];
}

class AnimalDetailLoaded extends AnimalDetailEvent {
  final int id;
  const AnimalDetailLoaded(this.id);
  @override
  List<Object?> get props => [id];
}

class AnimalDetailDeleted extends AnimalDetailEvent {
  const AnimalDetailDeleted();
}

class AnimalDetailVendido extends AnimalDetailEvent {
  final VenderAnimalInput input;
  const AnimalDetailVendido(this.input);
  @override
  List<Object?> get props => [input];
}

enum AnimalDetailStatus {
  initial,
  loading,
  loaded,
  deleting,
  deleted,
  selling,
  sold,
  error,
}

class AnimalDetailState extends Equatable {
  final AnimalDetailStatus status;
  final Animal? animal;
  final AnimalCostos? costos;
  final List<Map<String, dynamic>> timeline;
  final AppFailure? failure;

  const AnimalDetailState({
    this.status = AnimalDetailStatus.initial,
    this.animal,
    this.costos,
    this.timeline = const [],
    this.failure,
  });

  AnimalDetailState copyWith({
    AnimalDetailStatus? status,
    Animal? animal,
    AnimalCostos? costos,
    List<Map<String, dynamic>>? timeline,
    AppFailure? failure,
  }) =>
      AnimalDetailState(
        status: status ?? this.status,
        animal: animal ?? this.animal,
        costos: costos ?? this.costos,
        timeline: timeline ?? this.timeline,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, animal, costos, timeline, failure];
}

class AnimalDetailBloc extends Bloc<AnimalDetailEvent, AnimalDetailState> {
  final AnimalRepository _repository;

  AnimalDetailBloc({required AnimalRepository repository})
      : _repository = repository,
        super(const AnimalDetailState()) {
    on<AnimalDetailLoaded>(_onLoaded);
    on<AnimalDetailDeleted>(_onDeleted);
    on<AnimalDetailVendido>(_onVendido);
  }

  Future<void> _onLoaded(
    AnimalDetailLoaded event,
    Emitter<AnimalDetailState> emit,
  ) async {
    emit(state.copyWith(status: AnimalDetailStatus.loading));
    // Disparamos las dos llamadas en paralelo (ahorra ~50% del tiempo total).
    final detailFuture = _repository.getById(event.id);
    final costosFuture = _repository.getCostos(event.id);
    final detail = await detailFuture;
    final costos = await costosFuture;
    detail.fold(
      (failure) => emit(state.copyWith(
        status: AnimalDetailStatus.error,
        failure: failure,
      )),
      (animal) => emit(state.copyWith(
        status: AnimalDetailStatus.loaded,
        animal: animal,
        costos: costos.fold((_) => null, (c) => c),
      )),
    );

    // Timeline (best-effort — no bloquea el detalle si falla)
    if (state.animal != null && !emit.isDone) {
      final tlResult = await _repository.getTimeline(event.id);
      tlResult.fold((_) {}, (events) {
        if (!emit.isDone) emit(state.copyWith(timeline: events));
      });
    }
  }

  Future<void> _onDeleted(
    AnimalDetailDeleted event,
    Emitter<AnimalDetailState> emit,
  ) async {
    if (state.animal == null) return;
    emit(state.copyWith(status: AnimalDetailStatus.deleting));
    final result = await _repository.delete(state.animal!.id);
    result.fold(
      (failure) => emit(
        state.copyWith(status: AnimalDetailStatus.error, failure: failure),
      ),
      (_) => emit(state.copyWith(status: AnimalDetailStatus.deleted)),
    );
  }

  Future<void> _onVendido(
    AnimalDetailVendido event,
    Emitter<AnimalDetailState> emit,
  ) async {
    if (state.animal == null) return;
    emit(state.copyWith(status: AnimalDetailStatus.selling));
    final result = await _repository.vender(state.animal!.id, event.input);
    result.fold(
      (failure) => emit(
        state.copyWith(status: AnimalDetailStatus.error, failure: failure),
      ),
      (animal) => emit(state.copyWith(
        status: AnimalDetailStatus.sold,
        animal: animal,
      )),
    );
  }
}
