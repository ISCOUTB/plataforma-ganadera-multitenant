import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../animales/domain/entities/animal.dart';
import '../../../potreros/domain/entities/potrero.dart';
import '../../domain/entities/finca.dart';
import '../../domain/repositories/finca_repository.dart';
import '../../data/datasources/finca_remote_datasource.dart';

sealed class FincaDetailEvent extends Equatable {
  const FincaDetailEvent();
  @override
  List<Object?> get props => [];
}

class FincaDetailLoaded extends FincaDetailEvent {
  final String id;
  const FincaDetailLoaded(this.id);
  @override
  List<Object?> get props => [id];
}

class FincaDetailDeleted extends FincaDetailEvent {
  const FincaDetailDeleted();
}

enum FincaDetailStatus { initial, loading, loaded, deleting, deleted, error }

class FincaDetailState extends Equatable {
  final FincaDetailStatus status;
  final Finca? finca;
  final List<Animal> animales;
  final List<Potrero> potreros;
  final AppFailure? failure;

  const FincaDetailState({
    this.status = FincaDetailStatus.initial,
    this.finca,
    this.animales = const [],
    this.potreros = const [],
    this.failure,
  });

  FincaDetailState copyWith({
    FincaDetailStatus? status,
    Finca? finca,
    List<Animal>? animales,
    List<Potrero>? potreros,
    AppFailure? failure,
  }) =>
      FincaDetailState(
        status: status ?? this.status,
        finca: finca ?? this.finca,
        animales: animales ?? this.animales,
        potreros: potreros ?? this.potreros,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, finca, animales, potreros, failure];
}

class FincaDetailBloc extends Bloc<FincaDetailEvent, FincaDetailState> {
  final FincaRepository _repository;
  final FincaRemoteDataSource _remote;

  FincaDetailBloc({
    required FincaRepository repository,
    required FincaRemoteDataSource remote,
  })  : _repository = repository,
        _remote = remote,
        super(const FincaDetailState()) {
    on<FincaDetailLoaded>(_onLoaded);
    on<FincaDetailDeleted>(_onDeleted);
  }

  Future<void> _onLoaded(
    FincaDetailLoaded event,
    Emitter<FincaDetailState> emit,
  ) async {
    emit(state.copyWith(status: FincaDetailStatus.loading));
    final result = await _repository.getById(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: FincaDetailStatus.error,
        failure: failure,
      )),
      (finca) => emit(state.copyWith(
        status: FincaDetailStatus.loaded,
        finca: finca,
      )),
    );

    // Cargar sub-listas en paralelo sin bloquear el render del detalle.
    if (state.finca != null) {
      try {
        final futures = await Future.wait([
          _remote.getAnimales(event.id),
          _remote.getPotreros(event.id),
        ]);
        final animalModels = futures[0];
        final potreroModels = futures[1];
        if (!emit.isDone) {
          emit(state.copyWith(
            animales: (animalModels as List).map((m) => m.toEntity() as Animal).toList(),
            potreros: (potreroModels as List).map((m) => m.toEntity() as Potrero).toList(),
          ));
        }
      } catch (_) {
        // Sub-listas son best-effort — si fallan, el detalle sigue mostrándose.
      }
    }
  }

  Future<void> _onDeleted(
    FincaDetailDeleted event,
    Emitter<FincaDetailState> emit,
  ) async {
    if (state.finca == null) return;
    emit(state.copyWith(status: FincaDetailStatus.deleting));
    final result = await _repository.delete(state.finca!.id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: FincaDetailStatus.error,
        failure: failure,
      )),
      (_) => emit(state.copyWith(status: FincaDetailStatus.deleted)),
    );
  }
}
