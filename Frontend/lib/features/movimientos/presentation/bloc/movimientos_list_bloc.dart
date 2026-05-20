import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/movimiento.dart';
import '../../domain/repositories/movimiento_repository.dart';

sealed class MovimientosListEvent extends Equatable {
  const MovimientosListEvent();
  @override
  List<Object?> get props => [];
}

class MovimientosListStarted extends MovimientosListEvent {
  const MovimientosListStarted();
}

class MovimientosListRefreshed extends MovimientosListEvent {
  const MovimientosListRefreshed();
}

class MovimientosListNextPageRequested extends MovimientosListEvent {
  const MovimientosListNextPageRequested();
}

enum MovimientosListStatus { initial, loading, loaded, loadingMore, error }

class MovimientosListState extends Equatable {
  final MovimientosListStatus status;
  final List<Movimiento> items;
  final int page;
  final int lastPage;
  final int total;
  final AppFailure? failure;

  const MovimientosListState({
    this.status = MovimientosListStatus.initial,
    this.items = const [],
    this.page = 1,
    this.lastPage = 1,
    this.total = 0,
    this.failure,
  });

  bool get hasMore => page < lastPage;

  MovimientosListState copyWith({
    MovimientosListStatus? status,
    List<Movimiento>? items,
    int? page,
    int? lastPage,
    int? total,
    AppFailure? failure,
  }) =>
      MovimientosListState(
        status: status ?? this.status,
        items: items ?? this.items,
        page: page ?? this.page,
        lastPage: lastPage ?? this.lastPage,
        total: total ?? this.total,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, items, page, lastPage, total, failure];
}

class MovimientosListBloc
    extends Bloc<MovimientosListEvent, MovimientosListState> {
  final MovimientoRepository _repository;

  MovimientosListBloc({required MovimientoRepository repository})
      : _repository = repository,
        super(const MovimientosListState()) {
    on<MovimientosListStarted>((e, emit) async {
      if (state.status == MovimientosListStatus.loaded) return;
      await _fetch(emit, page: 1, replace: true);
    });
    on<MovimientosListRefreshed>(
        (e, emit) => _fetch(emit, page: 1, replace: true));
    on<MovimientosListNextPageRequested>((e, emit) async {
      if (!state.hasMore ||
          state.status == MovimientosListStatus.loadingMore) return;
      await _fetch(emit, page: state.page + 1, replace: false);
    });
  }

  Future<void> _fetch(
    Emitter<MovimientosListState> emit, {
    required int page,
    required bool replace,
  }) async {
    emit(state.copyWith(
      status: replace
          ? MovimientosListStatus.loading
          : MovimientosListStatus.loadingMore,
      failure: null,
    ));
    final r = await _repository.list(page: page, limit: 20);
    r.fold(
      (f) =>
          emit(state.copyWith(status: MovimientosListStatus.error, failure: f)),
      (res) => emit(state.copyWith(
        status: MovimientosListStatus.loaded,
        items: replace ? res.data : [...state.items, ...res.data],
        page: res.page,
        lastPage: res.lastPage,
        total: res.total,
      )),
    );
  }
}
