import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/salud.dart';
import '../../domain/repositories/salud_repository.dart';

sealed class SaludListEvent extends Equatable {
  const SaludListEvent();
  @override
  List<Object?> get props => [];
}

class SaludListStarted extends SaludListEvent {
  const SaludListStarted();
}

class SaludListRefreshed extends SaludListEvent {
  const SaludListRefreshed();
}

class SaludListNextPageRequested extends SaludListEvent {
  const SaludListNextPageRequested();
}

class SaludListFilterChanged extends SaludListEvent {
  final TipoIntervencion? tipo;
  const SaludListFilterChanged({this.tipo});
  @override
  List<Object?> get props => [tipo];
}

class SaludListFincaFilterChanged extends SaludListEvent {
  final String? fincaId;
  const SaludListFincaFilterChanged({this.fincaId});
  @override
  List<Object?> get props => [fincaId];
}

enum SaludListStatus { initial, loading, loaded, loadingMore, error }

class SaludListState extends Equatable {
  final SaludListStatus status;
  final List<Salud> items;
  final int page;
  final int lastPage;
  final int total;
  final TipoIntervencion? filter;
  final String? fincaIdFilter;
  final AppFailure? failure;

  const SaludListState({
    this.status = SaludListStatus.initial,
    this.items = const [],
    this.page = 1,
    this.lastPage = 1,
    this.total = 0,
    this.filter,
    this.fincaIdFilter,
    this.failure,
  });

  bool get hasMore => page < lastPage;

  SaludListState copyWith({
    SaludListStatus? status,
    List<Salud>? items,
    int? page,
    int? lastPage,
    int? total,
    Object? filter = _sentinel,
    Object? fincaIdFilter = _sentinel,
    AppFailure? failure,
  }) =>
      SaludListState(
        status: status ?? this.status,
        items: items ?? this.items,
        page: page ?? this.page,
        lastPage: lastPage ?? this.lastPage,
        total: total ?? this.total,
        filter: filter == _sentinel ? this.filter : filter as TipoIntervencion?,
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

class SaludListBloc extends Bloc<SaludListEvent, SaludListState> {
  final SaludRepository _repository;

  SaludListBloc({required SaludRepository repository})
      : _repository = repository,
        super(const SaludListState()) {
    on<SaludListStarted>((e, emit) async {
      if (state.status == SaludListStatus.loaded) return;
      await _fetch(emit, page: 1, replace: true);
    });
    on<SaludListRefreshed>((e, emit) => _fetch(emit, page: 1, replace: true));
    on<SaludListNextPageRequested>((e, emit) async {
      if (!state.hasMore || state.status == SaludListStatus.loadingMore) return;
      await _fetch(emit, page: state.page + 1, replace: false);
    });
    on<SaludListFilterChanged>((e, emit) async {
      emit(state.copyWith(filter: e.tipo));
      await _fetch(emit, page: 1, replace: true);
    });
    on<SaludListFincaFilterChanged>((e, emit) async {
      if (state.status == SaludListStatus.loaded &&
          state.fincaIdFilter == e.fincaId) {
        return;
      }
      emit(state.copyWith(fincaIdFilter: e.fincaId));
      await _fetch(emit, page: 1, replace: true);
    });
  }

  Future<void> _fetch(
    Emitter<SaludListState> emit, {
    required int page,
    required bool replace,
  }) async {
    emit(state.copyWith(
      status: replace ? SaludListStatus.loading : SaludListStatus.loadingMore,
      failure: null,
    ));
    final result = await _repository.list(
      page: page,
      limit: 20,
      tipoIntervencion: state.filter,
      fincaId: state.fincaIdFilter,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(status: SaludListStatus.error, failure: failure)),
      (response) => emit(state.copyWith(
        status: SaludListStatus.loaded,
        items: replace ? response.data : [...state.items, ...response.data],
        page: response.page,
        lastPage: response.lastPage,
        total: response.total,
      )),
    );
  }
}
