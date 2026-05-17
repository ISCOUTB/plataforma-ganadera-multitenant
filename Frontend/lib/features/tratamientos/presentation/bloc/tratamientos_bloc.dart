import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/tratamiento.dart';
import '../../domain/repositories/tratamientos_repository.dart';

abstract class TratamientosEvent extends Equatable {
  const TratamientosEvent();
  @override List<Object?> get props => [];
}
class TratamientosStarted extends TratamientosEvent { const TratamientosStarted(); }
class TratamientosByAnimalStarted extends TratamientosEvent {
  final int bovinoId;
  const TratamientosByAnimalStarted(this.bovinoId);
  @override List<Object?> get props => [bovinoId];
}
class TratamientosRefreshed extends TratamientosEvent { const TratamientosRefreshed(); }
class SeguimientoAdded extends TratamientosEvent {
  final int tratamientoId;
  final String observacion;
  final String? registradoPor;
  const SeguimientoAdded({required this.tratamientoId, required this.observacion, this.registradoPor});
  @override List<Object?> get props => [tratamientoId, observacion];
}

enum TratamientosStatus { initial, loading, loaded, error }

class TratamientosState extends Equatable {
  final TratamientosStatus status;
  final List<Tratamiento> items;
  final String? error;
  const TratamientosState({this.status = TratamientosStatus.initial, this.items = const [], this.error});
  TratamientosState copyWith({TratamientosStatus? status, List<Tratamiento>? items, String? error}) =>
      TratamientosState(status: status ?? this.status, items: items ?? this.items, error: error ?? this.error);
  @override List<Object?> get props => [status, items, error];
}

class TratamientosBloc extends Bloc<TratamientosEvent, TratamientosState> {
  final TratamientosRepository _repo;
  int? _currentBovinoId;

  TratamientosBloc({required TratamientosRepository repository})
      : _repo = repository, super(const TratamientosState()) {
    on<TratamientosStarted>(_onStarted);
    on<TratamientosByAnimalStarted>(_onByAnimal);
    on<TratamientosRefreshed>(_onRefreshed);
    on<SeguimientoAdded>(_onSeguimientoAdded);
  }

  Future<void> _onStarted(TratamientosStarted event, Emitter<TratamientosState> emit) async {
    emit(state.copyWith(status: TratamientosStatus.loading));
    try {
      final items = await _repo.getAll();
      emit(state.copyWith(status: TratamientosStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: TratamientosStatus.error, error: e.toString()));
    }
  }

  Future<void> _onByAnimal(TratamientosByAnimalStarted event, Emitter<TratamientosState> emit) async {
    _currentBovinoId = event.bovinoId;
    emit(state.copyWith(status: TratamientosStatus.loading));
    try {
      final items = await _repo.getByAnimal(event.bovinoId);
      emit(state.copyWith(status: TratamientosStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: TratamientosStatus.error, error: e.toString()));
    }
  }

  Future<void> _onRefreshed(TratamientosRefreshed event, Emitter<TratamientosState> emit) async {
    if (_currentBovinoId != null) {
      add(TratamientosByAnimalStarted(_currentBovinoId!));
    } else {
      add(const TratamientosStarted());
    }
  }

  Future<void> _onSeguimientoAdded(SeguimientoAdded event, Emitter<TratamientosState> emit) async {
    try {
      await _repo.addSeguimiento(event.tratamientoId, {
        'observacion': event.observacion,
        if (event.registradoPor != null) 'registrado_por': event.registradoPor,
      });
      add(const TratamientosRefreshed());
    } catch (e) {
      emit(state.copyWith(status: TratamientosStatus.error, error: e.toString()));
    }
  }
}
