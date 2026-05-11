import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/finanza.dart';
import '../../domain/repositories/finanza_repository.dart';

sealed class FinanzaFormEvent extends Equatable {
  const FinanzaFormEvent();
  @override
  List<Object?> get props => [];
}

class FinanzaFormSubmitted extends FinanzaFormEvent {
  final String? editId;
  final String id;
  final TipoMovimiento tipo;
  final String concepto;
  final String? categoria;
  final double monto;
  final DateTime? fecha;
  final String? metodoPago;
  final String? fincaId;

  const FinanzaFormSubmitted({
    this.editId,
    required this.id,
    required this.tipo,
    required this.concepto,
    required this.monto,
    this.categoria,
    this.fecha,
    this.metodoPago,
    this.fincaId,
  });

  bool get isEdit => editId != null;

  @override
  List<Object?> get props =>
      [editId, id, tipo, concepto, monto, categoria, fecha];
}

enum FinanzaFormStatus { idle, submitting, success, failure }

class FinanzaFormState extends Equatable {
  final FinanzaFormStatus status;
  final Finanza? finanza;
  final AppFailure? failure;

  const FinanzaFormState({
    this.status = FinanzaFormStatus.idle,
    this.finanza,
    this.failure,
  });

  FinanzaFormState copyWith({
    FinanzaFormStatus? status,
    Finanza? finanza,
    AppFailure? failure,
  }) =>
      FinanzaFormState(
        status: status ?? this.status,
        finanza: finanza ?? this.finanza,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, finanza, failure];
}

class FinanzaFormBloc extends Bloc<FinanzaFormEvent, FinanzaFormState> {
  final FinanzaRepository _repository;

  FinanzaFormBloc({required FinanzaRepository repository})
      : _repository = repository,
        super(const FinanzaFormState()) {
    on<FinanzaFormSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    FinanzaFormSubmitted event,
    Emitter<FinanzaFormState> emit,
  ) async {
    emit(state.copyWith(status: FinanzaFormStatus.submitting));
    final r = event.isEdit
        ? await _repository.update(
            event.editId!,
            UpdateFinanzaInput(
              tipoMovimiento: event.tipo,
              concepto: event.concepto,
              categoria: event.categoria,
              monto: event.monto,
              fecha: event.fecha,
              metodoPago: event.metodoPago,
            ),
          )
        : await _repository.create(
            CreateFinanzaInput(
              id: event.id,
              tipoMovimiento: event.tipo,
              concepto: event.concepto,
              categoria: event.categoria,
              monto: event.monto,
              fecha: event.fecha,
              metodoPago: event.metodoPago,
              fincaId: event.fincaId,
            ),
          );
    r.fold(
      (f) =>
          emit(state.copyWith(status: FinanzaFormStatus.failure, failure: f)),
      (fin) =>
          emit(state.copyWith(status: FinanzaFormStatus.success, finanza: fin)),
    );
  }
}
