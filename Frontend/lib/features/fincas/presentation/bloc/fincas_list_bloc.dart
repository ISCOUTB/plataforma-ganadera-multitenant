import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/finca.dart';
import '../../domain/repositories/finca_repository.dart';

// ---------- Events ----------
sealed class FincasListEvent extends Equatable {
  const FincasListEvent();
  @override
  List<Object?> get props => [];
}

class FincasListStarted extends FincasListEvent {
  const FincasListStarted();
}

class FincasListRefreshed extends FincasListEvent {
  const FincasListRefreshed();
}

class FincasListNextPageRequested extends FincasListEvent {
  const FincasListNextPageRequested();
}

class FincasListFilterChanged extends FincasListEvent {
  final String? nombre;
  final String? ubicacion;
  const FincasListFilterChanged({this.nombre, this.ubicacion});
  @override
  List<Object?> get props => [nombre, ubicacion];
}

/// Cambia la finca activa para filtrar el Dashboard.
/// `fincaId == null` significa "Todas las fincas" (vista global del tenant).
class FincaSelected extends FincasListEvent {
  final String? fincaId;
  const FincaSelected({required this.fincaId});
  @override
  List<Object?> get props => [fincaId];
}

// ---------- State ----------
enum FincasListStatus { initial, loading, loaded, loadingMore, error }

class FincasListState extends Equatable {
  final FincasListStatus status;
  final List<Finca> items;
  final int page;
  final int lastPage;
  final int total;
  final String? nombreFilter;
  final String? ubicacionFilter;
  final String? selectedFincaId;
  final AppFailure? failure;

  const FincasListState({
    this.status = FincasListStatus.initial,
    this.items = const [],
    this.page = 1,
    this.lastPage = 1,
    this.total = 0,
    this.nombreFilter,
    this.ubicacionFilter,
    this.selectedFincaId,
    this.failure,
  });

  bool get hasMore => page < lastPage;

  /// Finca actualmente seleccionada en la UI, o `null` si está activa la
  /// vista global ("Todas las fincas").
  Finca? get selected {
    if (selectedFincaId == null) return null;
    for (final f in items) {
      if (f.id == selectedFincaId) return f;
    }
    return null;
  }

  FincasListState copyWith({
    FincasListStatus? status,
    List<Finca>? items,
    int? page,
    int? lastPage,
    int? total,
    Object? nombreFilter = _sentinel,
    Object? ubicacionFilter = _sentinel,
    Object? selectedFincaId = _sentinel,
    AppFailure? failure,
  }) =>
      FincasListState(
        status: status ?? this.status,
        items: items ?? this.items,
        page: page ?? this.page,
        lastPage: lastPage ?? this.lastPage,
        total: total ?? this.total,
        nombreFilter:
            nombreFilter == _sentinel ? this.nombreFilter : nombreFilter as String?,
        ubicacionFilter: ubicacionFilter == _sentinel
            ? this.ubicacionFilter
            : ubicacionFilter as String?,
        selectedFincaId: selectedFincaId == _sentinel
            ? this.selectedFincaId
            : selectedFincaId as String?,
        failure: failure,
      );

  @override
  List<Object?> get props => [
        status,
        items,
        page,
        lastPage,
        total,
        nombreFilter,
        ubicacionFilter,
        selectedFincaId,
        failure,
      ];
}

const _sentinel = Object();

// ---------- Bloc ----------
class FincasListBloc extends Bloc<FincasListEvent, FincasListState> {
  final FincaRepository _repository;

  FincasListBloc({required FincaRepository repository})
      : _repository = repository,
        super(const FincasListState()) {
    on<FincasListStarted>(_onStarted);
    on<FincasListRefreshed>(_onRefreshed);
    on<FincasListNextPageRequested>(_onNextPage);
    on<FincasListFilterChanged>(_onFilterChanged);
    on<FincaSelected>(_onFincaSelected);
  }

  void _onFincaSelected(
    FincaSelected event,
    Emitter<FincasListState> emit,
  ) {
    if (state.selectedFincaId == event.fincaId) return;
    emit(state.copyWith(selectedFincaId: event.fincaId));
  }

  Future<void> _onStarted(
    FincasListStarted event,
    Emitter<FincasListState> emit,
  ) async {
    if (state.status == FincasListStatus.loaded) return;
    await _fetch(emit, page: 1, replace: true);
  }

  Future<void> _onRefreshed(
    FincasListRefreshed event,
    Emitter<FincasListState> emit,
  ) async {
    await _fetch(emit, page: 1, replace: true);
  }

  Future<void> _onNextPage(
    FincasListNextPageRequested event,
    Emitter<FincasListState> emit,
  ) async {
    if (!state.hasMore || state.status == FincasListStatus.loadingMore) return;
    await _fetch(emit, page: state.page + 1, replace: false);
  }

  Future<void> _onFilterChanged(
    FincasListFilterChanged event,
    Emitter<FincasListState> emit,
  ) async {
    emit(state.copyWith(
      nombreFilter: event.nombre,
      ubicacionFilter: event.ubicacion,
    ));
    await _fetch(emit, page: 1, replace: true);
  }

  Future<void> _fetch(
    Emitter<FincasListState> emit, {
    required int page,
    required bool replace,
  }) async {
    emit(state.copyWith(
      status: replace ? FincasListStatus.loading : FincasListStatus.loadingMore,
      failure: null,
    ));

    final result = await _repository.list(
      page: page,
      limit: 20,
      nombre: state.nombreFilter,
      ubicacion: state.ubicacionFilter,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FincasListStatus.error,
        failure: failure,
      )),
      (response) => emit(state.copyWith(
        status: FincasListStatus.loaded,
        items: replace ? response.data : [...state.items, ...response.data],
        page: response.page,
        lastPage: response.lastPage,
        total: response.total,
      )),
    );
  }
}
