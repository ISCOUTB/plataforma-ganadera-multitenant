import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/alimento.dart';
import '../../domain/repositories/alimento_repository.dart';

sealed class AlimentosListEvent extends Equatable {
  const AlimentosListEvent();
  @override
  List<Object?> get props => [];
}

class AlimentosListStarted extends AlimentosListEvent {
  const AlimentosListStarted();
}

class AlimentosListRefreshed extends AlimentosListEvent {
  const AlimentosListRefreshed();
}

class AlimentosListNextPageRequested extends AlimentosListEvent {
  const AlimentosListNextPageRequested();
}

enum AlimentosListStatus { initial, loading, loaded, loadingMore, error }

class AlimentosListState extends Equatable {
  final AlimentosListStatus status;
  final List<Alimento> items;
  final int page;
  final int lastPage;
  final int total;
  final AppFailure? failure;

  const AlimentosListState({
    this.status = AlimentosListStatus.initial,
    this.items = const [],
    this.page = 1,
    this.lastPage = 1,
    this.total = 0,
    this.failure,
  });

  bool get hasMore => page < lastPage;

  AlimentosListState copyWith({
    AlimentosListStatus? status,
    List<Alimento>? items,
    int? page,
    int? lastPage,
    int? total,
    AppFailure? failure,
  }) =>
      AlimentosListState(
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

class AlimentosListBloc extends Bloc<AlimentosListEvent, AlimentosListState> {
  final AlimentoRepository _repository;

  AlimentosListBloc({required AlimentoRepository repository})
      : _repository = repository,
        super(const AlimentosListState()) {
    on<AlimentosListStarted>((e, emit) async {
      if (state.status == AlimentosListStatus.loaded) return;
      await _fetch(emit, page: 1, replace: true);
    });
    on<AlimentosListRefreshed>(
        (e, emit) => _fetch(emit, page: 1, replace: true));
    on<AlimentosListNextPageRequested>((e, emit) async {
      if (!state.hasMore || state.status == AlimentosListStatus.loadingMore) {
        return;
      }
      await _fetch(emit, page: state.page + 1, replace: false);
    });
  }

  Future<void> _fetch(
    Emitter<AlimentosListState> emit, {
    required int page,
    required bool replace,
  }) async {
    emit(state.copyWith(
      status: replace
          ? AlimentosListStatus.loading
          : AlimentosListStatus.loadingMore,
      failure: null,
    ));
    final r = await _repository.list(page: page, limit: 20);
    r.fold(
      (f) =>
          emit(state.copyWith(status: AlimentosListStatus.error, failure: f)),
      (res) => emit(state.copyWith(
        status: AlimentosListStatus.loaded,
        items: replace ? res.data : [...state.items, ...res.data],
        page: res.page,
        lastPage: res.lastPage,
        total: res.total,
      )),
    );
  }
}
