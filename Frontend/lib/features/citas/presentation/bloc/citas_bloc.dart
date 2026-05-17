import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cita.dart';
import '../../domain/repositories/citas_repository.dart';

abstract class CitasEvent extends Equatable {
  const CitasEvent();
  @override List<Object?> get props => [];
}
class CitasStarted extends CitasEvent { const CitasStarted(); }
class CitasRefreshed extends CitasEvent { const CitasRefreshed(); }
class CitaDeleted extends CitasEvent {
  final int id;
  const CitaDeleted(this.id);
  @override List<Object?> get props => [id];
}

enum CitasStatus { initial, loading, loaded, error }

class CitasState extends Equatable {
  final CitasStatus status;
  final List<Cita> items;
  final String? error;
  const CitasState({this.status = CitasStatus.initial, this.items = const [], this.error});
  CitasState copyWith({CitasStatus? status, List<Cita>? items, String? error}) =>
      CitasState(status: status ?? this.status, items: items ?? this.items, error: error ?? this.error);
  @override List<Object?> get props => [status, items, error];
}

class CitasBloc extends Bloc<CitasEvent, CitasState> {
  final CitasRepository _repo;
  CitasBloc({required CitasRepository repository})
      : _repo = repository, super(const CitasState()) {
    on<CitasStarted>(_onStarted);
    on<CitasRefreshed>(_onStarted);
    on<CitaDeleted>(_onDeleted);
  }

  Future<void> _onStarted(CitasEvent event, Emitter<CitasState> emit) async {
    emit(state.copyWith(status: CitasStatus.loading));
    try {
      final items = await _repo.getAll();
      emit(state.copyWith(status: CitasStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: CitasStatus.error, error: e.toString()));
    }
  }

  Future<void> _onDeleted(CitaDeleted event, Emitter<CitasState> emit) async {
    try {
      await _repo.delete(event.id);
      final items = await _repo.getAll();
      emit(state.copyWith(status: CitasStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: CitasStatus.error, error: e.toString()));
    }
  }
}
