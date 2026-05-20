import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/potrero.dart';
import '../../domain/repositories/potrero_repository.dart';

sealed class PotrerosListEvent extends Equatable {
  const PotrerosListEvent();
  @override
  List<Object?> get props => [];
}

class PotrerosListStarted extends PotrerosListEvent {
  const PotrerosListStarted();
}

class PotrerosListRefreshed extends PotrerosListEvent {
  const PotrerosListRefreshed();
}

class PotrerosListNextPageRequested extends PotrerosListEvent {
  const PotrerosListNextPageRequested();
}

class PotrerosListFincaFilterChanged extends PotrerosListEvent {
  final String? fincaId;
  const PotrerosListFincaFilterChanged({this.fincaId});
  @override
  List<Object?> get props => [fincaId];
}

enum PotrerosListStatus { initial, loading, loaded, loadingMore, error }

class PotrerosListState extends Equatable {
  final PotrerosListStatus status;
  final List<Potrero> items;
  final int page;
  final int lastPage;
  final int total;
  final String? fincaIdFilter;
  final AppFailure? failure;

  const PotrerosListState({
    this.status = PotrerosListStatus.initial,
    this.items = const [],
    this.page = 1,
    this.lastPage = 1,
    this.total = 0,
    this.fincaIdFilter,
    this.failure,
  });

  bool get hasMore => page < lastPage;

  PotrerosListState copyWith({
    PotrerosListStatus? status,
    List<Potrero>? items,
    int? page,
    int? lastPage,
    int? total,
    Object? fincaIdFilter = _sentinel,
    AppFailure? failure,
  }) =>
      PotrerosListState(
        status: status ?? this.status,
        items: items ?? this.items,
        page: page ?? this.page,
        lastPage: lastPage ?? this.lastPage,
        total: total ?? this.total,
        fincaIdFilter:
            fincaIdFilter == _sentinel ? this.fincaIdFilter : fincaIdFilter as String?,
        failure: failure,
      );

  @override
  List<Object?> get props =>
      [status, items, page, lastPage, total, fincaIdFilter, failure];
}

const _sentinel = Object();

class PotrerosListBloc extends Bloc<PotrerosListEvent, PotrerosListState> {
  final PotreroRepository _repository;

  PotrerosListBloc({required PotreroRepository repository})
      : _repository = repository,
        super(const PotrerosListState()) {
    on<PotrerosListStarted>((e, emit) async {
      if (state.status == PotrerosListStatus.loaded) return;
      await _fetch(emit, page: 1, replace: true);
    });
    on<PotrerosListRefreshed>((e, emit) => _fetch(emit, page: 1, replace: true));
    on<PotrerosListNextPageRequested>((e, emit) async {
      if (!state.hasMore || state.status == PotrerosListStatus.loadingMore) {
        return;
      }
      await _fetch(emit, page: state.page + 1, replace: false);
    });
    on<PotrerosListFincaFilterChanged>((e, emit) async {
      // No-op si la finca pedida coincide con la actual y ya cargamos.
      if (state.status == PotrerosListStatus.loaded &&
          state.fincaIdFilter == e.fincaId) {
        return;
      }
      emit(state.copyWith(fincaIdFilter: e.fincaId));
      await _fetch(emit, page: 1, replace: true);
    });
  }

  Future<void> _fetch(
    Emitter<PotrerosListState> emit, {
    required int page,
    required bool replace,
  }) async {
    emit(state.copyWith(
      status: replace ? PotrerosListStatus.loading : PotrerosListStatus.loadingMore,
      failure: null,
    ));
    final result = await _repository.list(
      page: page,
      limit: 20,
      fincaId: state.fincaIdFilter,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: PotrerosListStatus.error, failure: failure),
      ),
      (response) => emit(state.copyWith(
        status: PotrerosListStatus.loaded,
        items: replace ? response.data : [...state.items, ...response.data],
        page: response.page,
        lastPage: response.lastPage,
        total: response.total,
      )),
    );
  }
}
