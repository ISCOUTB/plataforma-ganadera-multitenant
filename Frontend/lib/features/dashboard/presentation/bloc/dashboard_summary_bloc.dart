import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

// ---------- Events ----------
sealed class DashboardSummaryEvent extends Equatable {
  const DashboardSummaryEvent();
  @override
  List<Object?> get props => [];
}

class DashboardSummaryStarted extends DashboardSummaryEvent {
  final String tenantId;
  final String? fincaId;
  const DashboardSummaryStarted(this.tenantId, {this.fincaId});
  @override
  List<Object?> get props => [tenantId, fincaId];
}

class DashboardSummaryRefreshed extends DashboardSummaryEvent {
  final String tenantId;
  final String? fincaId;
  const DashboardSummaryRefreshed(this.tenantId, {this.fincaId});
  @override
  List<Object?> get props => [tenantId, fincaId];
}

// ---------- State ----------
enum DashboardSummaryStatus { initial, loading, loaded, error }

class DashboardSummaryState extends Equatable {
  final DashboardSummaryStatus status;
  final DashboardSummary? data;
  final AppFailure? failure;

  /// true si el dato mostrado proviene del cache local (no refrescado aún).
  /// Útil para mostrar un pequeño indicador "actualizando..." en la UI.
  final bool fromCache;

  const DashboardSummaryState({
    this.status = DashboardSummaryStatus.initial,
    this.data,
    this.failure,
    this.fromCache = false,
  });

  DashboardSummaryState copyWith({
    DashboardSummaryStatus? status,
    DashboardSummary? data,
    AppFailure? failure,
    bool? fromCache,
  }) =>
      DashboardSummaryState(
        status: status ?? this.status,
        data: data ?? this.data,
        failure: failure,
        fromCache: fromCache ?? this.fromCache,
      );

  @override
  List<Object?> get props => [status, data, failure, fromCache];
}

// ---------- Bloc ----------
class DashboardSummaryBloc
    extends Bloc<DashboardSummaryEvent, DashboardSummaryState> {
  final DashboardRepository _repository;

  DashboardSummaryBloc({required DashboardRepository repository})
      : _repository = repository,
        super(const DashboardSummaryState()) {
    on<DashboardSummaryStarted>(_onStarted);
    on<DashboardSummaryRefreshed>(_onRefreshed);
  }

  Future<void> _onStarted(
    DashboardSummaryStarted event,
    Emitter<DashboardSummaryState> emit,
  ) async {
    emit(state.copyWith(status: DashboardSummaryStatus.loading));
    await _consume(event.tenantId, event.fincaId, emit);
  }

  Future<void> _onRefreshed(
    DashboardSummaryRefreshed event,
    Emitter<DashboardSummaryState> emit,
  ) async {
    // Al cambiar de finca queremos pasar a "loading" para que la UI
    // muestre el spinner del Bento mientras llega el nuevo payload.
    emit(state.copyWith(status: DashboardSummaryStatus.loading));
    await _consume(event.tenantId, event.fincaId, emit);
  }

  /// Consume el stream cache-then-network del repository.
  /// Cada emisión del stream se traduce a un estado del bloc:
  ///   - primera emisión (cache) → loaded + fromCache:true
  ///   - segunda emisión (red)   → loaded + fromCache:false
  ///   - error (sin cache)       → error
  ///
  /// Usamos `await for` explícito en lugar de `emit.forEach` para tener
  /// control total del tipado y manejar excepciones del stream.
  Future<void> _consume(
    String tenantId,
    String? fincaId,
    Emitter<DashboardSummaryState> emit,
  ) async {
    bool gotAny = false;
    try {
      final stream = _repository.watchSummary(tenantId, fincaId: fincaId);
      await for (final Either<AppFailure, DashboardSummary> either in stream) {
        if (emit.isDone) break;
        gotAny = true;
        either.fold(
          (failure) {
            // Si ya teníamos data del cache, no pisamos con error.
            if (state.data == null) {
              emit(state.copyWith(
                status: DashboardSummaryStatus.error,
                failure: failure,
              ));
            }
          },
          (summary) {
            final isFirst = state.status != DashboardSummaryStatus.loaded;
            emit(DashboardSummaryState(
              status: DashboardSummaryStatus.loaded,
              data: summary,
              fromCache: isFirst,
            ));
          },
        );
      }
    } catch (e) {
      if (!emit.isDone && state.data == null) {
        emit(state.copyWith(
          status: DashboardSummaryStatus.error,
          failure: UnknownFailure('Error cargando dashboard: $e'),
        ));
      }
    }

    // Si el stream cerró sin emitir nada, forzamos error.
    if (!gotAny &&
        !emit.isDone &&
        state.status == DashboardSummaryStatus.loading) {
      emit(state.copyWith(
        status: DashboardSummaryStatus.error,
        failure: const UnknownFailure('No se pudo cargar el dashboard'),
      ));
    }
  }
}
