import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/veterinario.dart';
import '../../domain/repositories/veterinarios_repository.dart';

// Events
abstract class VeterinariosEvent extends Equatable {
  const VeterinariosEvent();
  @override List<Object?> get props => [];
}
class VeterinariosStarted extends VeterinariosEvent { const VeterinariosStarted(); }
class VeterinariosRefreshed extends VeterinariosEvent { const VeterinariosRefreshed(); }
class VeterinarioDeleted extends VeterinariosEvent {
  final int id;
  const VeterinarioDeleted(this.id);
  @override List<Object?> get props => [id];
}

// States
enum VeterinariosStatus { initial, loading, loaded, error }

class VeterinariosState extends Equatable {
  final VeterinariosStatus status;
  final List<Veterinario> items;
  final String? error;
  const VeterinariosState({this.status = VeterinariosStatus.initial, this.items = const [], this.error});
  VeterinariosState copyWith({VeterinariosStatus? status, List<Veterinario>? items, String? error}) =>
      VeterinariosState(status: status ?? this.status, items: items ?? this.items, error: error ?? this.error);
  @override List<Object?> get props => [status, items, error];
}

class VeterinariosBloc extends Bloc<VeterinariosEvent, VeterinariosState> {
  final VeterinariosRepository _repo;
  VeterinariosBloc({required VeterinariosRepository repository})
      : _repo = repository, super(const VeterinariosState()) {
    on<VeterinariosStarted>(_onStarted);
    on<VeterinariosRefreshed>(_onStarted);
    on<VeterinarioDeleted>(_onDeleted);
  }

  Future<void> _onStarted(VeterinariosEvent event, Emitter<VeterinariosState> emit) async {
    emit(state.copyWith(status: VeterinariosStatus.loading));
    try {
      final items = await _repo.getAll();
      emit(state.copyWith(status: VeterinariosStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: VeterinariosStatus.error, error: e.toString()));
    }
  }

  Future<void> _onDeleted(VeterinarioDeleted event, Emitter<VeterinariosState> emit) async {
    try {
      await _repo.delete(event.id);
      final items = await _repo.getAll();
      emit(state.copyWith(status: VeterinariosStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: VeterinariosStatus.error, error: e.toString()));
    }
  }
}
