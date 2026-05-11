import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/finanza.dart';
import '../../domain/repositories/finanza_repository.dart';

sealed class FinanzasListEvent extends Equatable {
  const FinanzasListEvent();
  @override
  List<Object?> get props => [];
}

class FinanzasListStarted extends FinanzasListEvent {
  const FinanzasListStarted();
}

class FinanzasListRefreshed extends FinanzasListEvent {
  const FinanzasListRefreshed();
}

class FinanzasListNextPageRequested extends FinanzasListEvent {
  const FinanzasListNextPageRequested();
}

class FinanzasListFilterChanged extends FinanzasListEvent {
  final TipoMovimiento? tipo;
  const FinanzasListFilterChanged({this.tipo});
  @override
  List<Object?> get props => [tipo];
}

class FinanzasListFincaFilterChanged extends FinanzasListEvent {
  final String? fincaId;
  const FinanzasListFincaFilterChanged({this.fincaId});
  @override
  List<Object?> get props => [fincaId];
}

enum FinanzasListStatus { initial, loading, loaded, loadingMore, error }

class FinanzasListState extends Equatable {
  final FinanzasListStatus status;
  final List<Finanza> items;
  final int page;
  final int lastPage;
  final int total;
  final TipoMovimiento? filter;
  final String? fincaIdFilter;
  final AppFailure? failure;

  const FinanzasListState({
    this.status = FinanzasListStatus.initial,
    this.items = const [],
    this.page = 1,
    this.lastPage = 1,
    this.total = 0,
    this.filter,
    this.fincaIdFilter,
    this.failure,
  });

  bool get hasMore => page < lastPage;

  FinanzasListState copyWith({
    FinanzasListStatus? status,
    List<Finanza>? items,
    int? page,
    int? lastPage,
    int? total,
    Object? filter = _sentinel,
    Object? fincaIdFilter = _sentinel,
    AppFailure? failure,
  }) =>
      FinanzasListState(
        status: status ?? this.status,
        items: items ?? this.items,
        page: page ?? this.page,
        lastPage: lastPage ?? this.lastPage,
        total: total ?? this.total,
        filter: filter == _sentinel ? this.filter : filter as TipoMovimiento?,
        fincaIdFilter: fincaIdFilter == _sentinel
            ? this.fincaIdFilter
            : fincaIdFilter as String?,
        failure: failure,
      );

  @override
  List<Object?> get props =>
      [status, items, page, lastPage, total, filter, fincaIdFilter, failure];
}

const _sentinel = Object();

class FinanzasListBloc extends Bloc<FinanzasListEvent, FinanzasListState> {
  final FinanzaRepository _repository;

  FinanzasListBloc({required FinanzaRepository repository})
      : _repository = repository,
        super(const FinanzasListState()) {
    on<FinanzasListStarted>((e, emit) async {
      if (state.status == FinanzasListStatus.loaded) return;
      await _fetch(emit, page: 1, replace: true);
    });
    on<FinanzasListRefreshed>(
        (e, emit) => _fetch(emit, page: 1, replace: true));
    on<FinanzasListNextPageRequested>((e, emit) async {
      if (!state.hasMore || state.status == FinanzasListStatus.loadingMore) {
        return;
      }
      await _fetch(emit, page: state.page + 1, replace: false);
    });
    on<FinanzasListFilterChanged>((e, emit) async {
      emit(state.copyWith(filter: e.tipo));
      await _fetch(emit, page: 1, replace: true);
    });
    on<FinanzasListFincaFilterChanged>((e, emit) async {
      if (state.status == FinanzasListStatus.loaded &&
          state.fincaIdFilter == e.fincaId) {
        return;
      }
      emit(state.copyWith(fincaIdFilter: e.fincaId));
      await _fetch(emit, page: 1, replace: true);
    });
  }

  Future<void> _fetch(
    Emitter<FinanzasListState> emit, {
    required int page,
    required bool replace,
  }) async {
    emit(state.copyWith(
      status: replace
          ? FinanzasListStatus.loading
          : FinanzasListStatus.loadingMore,
      failure: null,
    ));
    final result = await _repository.list(
      page: page,
      limit: 20,
      tipo: state.filter,
      fincaId: state.fincaIdFilter,
    );
    result.fold(
      (f) => emit(state.copyWith(status: FinanzasListStatus.error, failure: f)),
      (r) => emit(state.copyWith(
        status: FinanzasListStatus.loaded,
        items: replace ? r.data : [...state.items, ...r.data],
        page: r.page,
        lastPage: r.lastPage,
        total: r.total,
      )),
    );
  }
}
