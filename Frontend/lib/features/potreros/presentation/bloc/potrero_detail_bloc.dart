import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../animales/domain/entities/animal.dart';
import '../../data/datasources/potrero_remote_datasource.dart';
import '../../domain/entities/potrero.dart';
import '../../domain/repositories/potrero_repository.dart';

sealed class PotreroDetailEvent extends Equatable {
  const PotreroDetailEvent();
  @override
  List<Object?> get props => [];
}

class PotreroDetailLoaded extends PotreroDetailEvent {
  final String id;
  const PotreroDetailLoaded(this.id);
  @override
  List<Object?> get props => [id];
}

class PotreroDetailDeleted extends PotreroDetailEvent {
  const PotreroDetailDeleted();
}

enum PotreroDetailStatus { initial, loading, loaded, deleting, deleted, error }

class PotreroDetailState extends Equatable {
  final PotreroDetailStatus status;
  final Potrero? potrero;
  final PotreroOcupacion? ocupacion;
  final List<Animal> animales;
  final AppFailure? failure;

  const PotreroDetailState({
    this.status = PotreroDetailStatus.initial,
    this.potrero,
    this.ocupacion,
    this.animales = const [],
    this.failure,
  });

  PotreroDetailState copyWith({
    PotreroDetailStatus? status,
    Potrero? potrero,
    PotreroOcupacion? ocupacion,
    List<Animal>? animales,
    AppFailure? failure,
  }) =>
      PotreroDetailState(
        status: status ?? this.status,
        potrero: potrero ?? this.potrero,
        ocupacion: ocupacion ?? this.ocupacion,
        animales: animales ?? this.animales,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, potrero, ocupacion, animales, failure];
}

class PotreroDetailBloc extends Bloc<PotreroDetailEvent, PotreroDetailState> {
  final PotreroRepository _repository;
  final PotreroRemoteDataSource _remote;

  PotreroDetailBloc({
    required PotreroRepository repository,
    required PotreroRemoteDataSource remote,
  })  : _repository = repository,
        _remote = remote,
        super(const PotreroDetailState()) {
    on<PotreroDetailLoaded>(_onLoaded);
    on<PotreroDetailDeleted>(_onDeleted);
  }

  Future<void> _onLoaded(
    PotreroDetailLoaded event,
    Emitter<PotreroDetailState> emit,
  ) async {
    emit(state.copyWith(status: PotreroDetailStatus.loading));
    // Disparamos las dos llamadas en paralelo.
    final detailFuture = _repository.getById(event.id);
    final ocupacionFuture = _repository.getOcupacion(event.id);
    final detailResult = await detailFuture;
    final ocupacionResult = await ocupacionFuture;

    detailResult.fold(
      (failure) => emit(state.copyWith(
        status: PotreroDetailStatus.error,
        failure: failure,
      )),
      (potrero) {
        final ocupacion = ocupacionResult.fold((_) => null, (o) => o);
        emit(state.copyWith(
          status: PotreroDetailStatus.loaded,
          potrero: potrero,
          ocupacion: ocupacion,
        ));
      },
    );

    // Cargar animales del potrero (best-effort).
    if (state.potrero != null) {
      try {
        final models = await _remote.getAnimales(event.id);
        if (!emit.isDone) {
          emit(state.copyWith(
            animales: models.map((m) => m.toEntity()).toList(),
          ));
        }
      } catch (_) {
        // No bloquea el detalle si falla.
      }
    }
  }

  Future<void> _onDeleted(
    PotreroDetailDeleted event,
    Emitter<PotreroDetailState> emit,
  ) async {
    if (state.potrero == null) return;
    emit(state.copyWith(status: PotreroDetailStatus.deleting));
    final result = await _repository.delete(state.potrero!.id);
    result.fold(
      (failure) => emit(
        state.copyWith(status: PotreroDetailStatus.error, failure: failure),
      ),
      (_) => emit(state.copyWith(status: PotreroDetailStatus.deleted)),
    );
  }
}
