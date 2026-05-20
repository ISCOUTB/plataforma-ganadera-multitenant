import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';

sealed class AnimalesListEvent extends Equatable {
  const AnimalesListEvent();
  @override
  List<Object?> get props => [];
}

class AnimalesListStarted extends AnimalesListEvent {
  const AnimalesListStarted();
}

class AnimalesListRefreshed extends AnimalesListEvent {
  const AnimalesListRefreshed();
}

class AnimalesListNextPageRequested extends AnimalesListEvent {
  const AnimalesListNextPageRequested();
}

class AnimalesListFilterChanged extends AnimalesListEvent {
  final AnimalFilter filter;
  const AnimalesListFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class AnimalesListFincaFilterChanged extends AnimalesListEvent {
  final String? fincaId;
  const AnimalesListFincaFilterChanged({this.fincaId});
  @override
  List<Object?> get props => [fincaId];
}

enum AnimalesListStatus { initial, loading, loaded, loadingMore, error }

class AnimalesListState extends Equatable {
  final AnimalesListStatus status;
  final List<Animal> items;
  final int page;
  final int lastPage;
  final int total;
  final AnimalFilter filter;
  final String? fincaIdFilter;
  final AppFailure? failure;

  const AnimalesListState({
    this.status = AnimalesListStatus.initial,
    this.items = const [],
    this.page = 1,
    this.lastPage = 1,
    this.total = 0,
    this.filter = const AnimalFilter(),
    this.fincaIdFilter,
    this.failure,
  });

  bool get hasMore => page < lastPage;

  AnimalesListState copyWith({
    AnimalesListStatus? status,
    List<Animal>? items,
    int? page,
    int? lastPage,
    int? total,
    AnimalFilter? filter,
    Object? fincaIdFilter = _sentinel,
    AppFailure? failure,
  }) =>
      AnimalesListState(
        status: status ?? this.status,
        items: items ?? this.items,
        page: page ?? this.page,
        lastPage: lastPage ?? this.lastPage,
        total: total ?? this.total,
        filter: filter ?? this.filter,
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

class AnimalesListBloc extends Bloc<AnimalesListEvent, AnimalesListState> {
  final AnimalRepository _repository;

  AnimalesListBloc({required AnimalRepository repository})
      : _repository = repository,
        super(const AnimalesListState()) {
    on<AnimalesListStarted>((e, emit) async {
      if (state.status == AnimalesListStatus.loaded) return;
      await _fetch(emit, page: 1, replace: true);
    });
    on<AnimalesListRefreshed>((e, emit) => _fetch(emit, page: 1, replace: true));
    on<AnimalesListNextPageRequested>((e, emit) async {
      if (!state.hasMore || state.status == AnimalesListStatus.loadingMore) {
        return;
      }
      await _fetch(emit, page: state.page + 1, replace: false);
    });
    on<AnimalesListFilterChanged>((e, emit) async {
      emit(state.copyWith(filter: e.filter));
      await _fetch(emit, page: 1, replace: true);
    });
    on<AnimalesListFincaFilterChanged>((e, emit) async {
      // No-op si la finca pedida coincide con la actual y ya cargamos.
      if (state.status == AnimalesListStatus.loaded &&
          state.fincaIdFilter == e.fincaId) {
        return;
      }
      emit(state.copyWith(fincaIdFilter: e.fincaId));
      await _fetch(emit, page: 1, replace: true);
    });
  }

  Future<void> _fetch(
    Emitter<AnimalesListState> emit, {
    required int page,
    required bool replace,
  }) async {
    emit(state.copyWith(
      status: replace ? AnimalesListStatus.loading : AnimalesListStatus.loadingMore,
      failure: null,
    ));
    final result = await _repository.list(
      page: page,
      limit: 20,
      filter: state.filter,
      fincaId: state.fincaIdFilter,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: AnimalesListStatus.error, failure: failure),
      ),
      (response) => emit(state.copyWith(
        status: AnimalesListStatus.loaded,
        items: replace ? response.data : [...state.items, ...response.data],
        page: response.page,
        lastPage: response.lastPage,
        total: response.total,
      )),
    );
  }
}
