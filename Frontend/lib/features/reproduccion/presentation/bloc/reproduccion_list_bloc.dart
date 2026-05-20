import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/reproduccion.dart';
import '../../domain/repositories/reproduccion_repository.dart';

sealed class ReproduccionListEvent extends Equatable {
  const ReproduccionListEvent();
  @override
  List<Object?> get props => [];
}

class ReproduccionListStarted extends ReproduccionListEvent {
  const ReproduccionListStarted();
}

class ReproduccionListRefreshed extends ReproduccionListEvent {
  const ReproduccionListRefreshed();
}

class ReproduccionListNextPageRequested extends ReproduccionListEvent {
  const ReproduccionListNextPageRequested();
}

class ReproduccionListFincaFilterChanged extends ReproduccionListEvent {
  final String? fincaId;
  const ReproduccionListFincaFilterChanged({this.fincaId});
  @override
  List<Object?> get props => [fincaId];
}

enum ReproduccionListStatus { initial, loading, loaded, loadingMore, error }

class ReproduccionListState extends Equatable {
  final ReproduccionListStatus status;
  final List<Reproduccion> items;
  final int page;
  final int lastPage;
  final int total;
  final String? fincaIdFilter;
  final AppFailure? failure;

  const ReproduccionListState({
    this.status = ReproduccionListStatus.initial,
    this.items = const [],
    this.page = 1,
    this.lastPage = 1,
    this.total = 0,
    this.fincaIdFilter,
    this.failure,
  });

  bool get hasMore => page < lastPage;

  ReproduccionListState copyWith({
    ReproduccionListStatus? status,
    List<Reproduccion>? items,
    int? page,
    int? lastPage,
    int? total,
    Object? fincaIdFilter = _sentinel,
    AppFailure? failure,
  }) =>
      ReproduccionListState(
        status: status ?? this.status,
        items: items ?? this.items,
        page: page ?? this.page,
        lastPage: lastPage ?? this.lastPage,
        total: total ?? this.total,
        fincaIdFilter: fincaIdFilter == _sentinel
            ? this.fincaIdFilter
            : fincaIdFilter as String?,
        failure: failure,
      );

  @override
  List<Object?> get props =>
      [status, items, page, lastPage, total, fincaIdFilter, failure];
}

const _sentinel = Object();

class ReproduccionListBloc
    extends Bloc<ReproduccionListEvent, ReproduccionListState> {
  final ReproduccionRepository _repository;

  ReproduccionListBloc({required ReproduccionRepository repository})
      : _repository = repository,
        super(const ReproduccionListState()) {
    on<ReproduccionListStarted>((e, emit) async {
      if (state.status == ReproduccionListStatus.loaded) return;
      await _fetch(emit, page: 1, replace: true);
    });
    on<ReproduccionListRefreshed>(
        (e, emit) => _fetch(emit, page: 1, replace: true));
    on<ReproduccionListNextPageRequested>((e, emit) async {
      if (!state.hasMore ||
          state.status == ReproduccionListStatus.loadingMore) return;
      await _fetch(emit, page: state.page + 1, replace: false);
    });
    on<ReproduccionListFincaFilterChanged>((e, emit) async {
      if (state.status == ReproduccionListStatus.loaded &&
          state.fincaIdFilter == e.fincaId) {
        return;
      }
      emit(state.copyWith(fincaIdFilter: e.fincaId));
      await _fetch(emit, page: 1, replace: true);
    });
  }

  Future<void> _fetch(
    Emitter<ReproduccionListState> emit, {
    required int page,
    required bool replace,
  }) async {
    emit(state.copyWith(
      status: replace
          ? ReproduccionListStatus.loading
          : ReproduccionListStatus.loadingMore,
      failure: null,
    ));
    final result = await _repository.list(
      page: page,
      limit: 20,
      fincaId: state.fincaIdFilter,
    );
    result.fold(
      (f) => emit(
          state.copyWith(status: ReproduccionListStatus.error, failure: f)),
      (r) => emit(state.copyWith(
        status: ReproduccionListStatus.loaded,
        items: replace ? r.data : [...state.items, ...r.data],
        page: r.page,
        lastPage: r.lastPage,
        total: r.total,
      )),
    );
  }
}
