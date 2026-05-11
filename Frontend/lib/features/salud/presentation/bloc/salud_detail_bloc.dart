import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/salud.dart';
import '../../domain/repositories/salud_repository.dart';

sealed class SaludDetailEvent extends Equatable {
  const SaludDetailEvent();
  @override
  List<Object?> get props => [];
}

class SaludDetailLoaded extends SaludDetailEvent {
  final int id;
  const SaludDetailLoaded(this.id);
  @override
  List<Object?> get props => [id];
}

class SaludDetailDeleted extends SaludDetailEvent {
  const SaludDetailDeleted();
}

enum SaludDetailStatus { initial, loading, loaded, deleting, deleted, error }

class SaludDetailState extends Equatable {
  final SaludDetailStatus status;
  final Salud? salud;
  final AppFailure? failure;

  const SaludDetailState({
    this.status = SaludDetailStatus.initial,
    this.salud,
    this.failure,
  });

  SaludDetailState copyWith({
    SaludDetailStatus? status,
    Salud? salud,
    AppFailure? failure,
  }) =>
      SaludDetailState(
        status: status ?? this.status,
        salud: salud ?? this.salud,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, salud, failure];
}

class SaludDetailBloc extends Bloc<SaludDetailEvent, SaludDetailState> {
  final SaludRepository _repository;

  SaludDetailBloc({required SaludRepository repository})
      : _repository = repository,
        super(const SaludDetailState()) {
    on<SaludDetailLoaded>((e, emit) async {
      emit(state.copyWith(status: SaludDetailStatus.loading));
      final r = await _repository.getById(e.id);
      r.fold(
        (f) => emit(
            state.copyWith(status: SaludDetailStatus.error, failure: f)),
        (s) => emit(
            state.copyWith(status: SaludDetailStatus.loaded, salud: s)),
      );
    });
    on<SaludDetailDeleted>((e, emit) async {
      if (state.salud == null) return;
      emit(state.copyWith(status: SaludDetailStatus.deleting));
      final r = await _repository.delete(state.salud!.id);
      r.fold(
        (f) => emit(
            state.copyWith(status: SaludDetailStatus.error, failure: f)),
        (_) => emit(state.copyWith(status: SaludDetailStatus.deleted)),
      );
    });
  }
}
