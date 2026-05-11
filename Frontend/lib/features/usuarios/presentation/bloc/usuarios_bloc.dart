import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/usuario_tenant.dart';
import '../../domain/repositories/usuarios_repository.dart';

sealed class UsuariosEvent extends Equatable {
  const UsuariosEvent();
  @override
  List<Object?> get props => [];
}

class UsuariosStarted extends UsuariosEvent {
  const UsuariosStarted();
}

class UsuariosCreateRequested extends UsuariosEvent {
  final String email;
  final String password;
  final String nombre;
  final String? telefono;
  final String? rol;

  const UsuariosCreateRequested({
    required this.email,
    required this.password,
    required this.nombre,
    this.telefono,
    this.rol,
  });

  @override
  List<Object?> get props => [email, password, nombre, telefono, rol];
}

class UsuariosUpdateRequested extends UsuariosEvent {
  final int id;
  final String? nombre;
  final String? telefono;
  final String? rol;

  const UsuariosUpdateRequested({
    required this.id,
    this.nombre,
    this.telefono,
    this.rol,
  });

  @override
  List<Object?> get props => [id, nombre, telefono, rol];
}

class UsuariosDeleteRequested extends UsuariosEvent {
  final int id;
  const UsuariosDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

enum UsuariosStatus { initial, loading, loaded, submitting, success, error }

class UsuariosState extends Equatable {
  final UsuariosStatus status;
  final List<UsuarioTenant> items;
  final AppFailure? failure;

  const UsuariosState({
    this.status = UsuariosStatus.initial,
    this.items = const [],
    this.failure,
  });

  UsuariosState copyWith({
    UsuariosStatus? status,
    List<UsuarioTenant>? items,
    AppFailure? failure,
  }) =>
      UsuariosState(
        status: status ?? this.status,
        items: items ?? this.items,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, items, failure];
}

class UsuariosBloc extends Bloc<UsuariosEvent, UsuariosState> {
  final UsuariosRepository _repository;

  UsuariosBloc({required UsuariosRepository repository})
      : _repository = repository,
        super(const UsuariosState()) {
    on<UsuariosStarted>(_onStarted);
    on<UsuariosCreateRequested>(_onCreate);
    on<UsuariosUpdateRequested>(_onUpdate);
    on<UsuariosDeleteRequested>(_onDelete);
  }

  Future<void> _onStarted(
    UsuariosStarted event,
    Emitter<UsuariosState> emit,
  ) async {
    emit(state.copyWith(status: UsuariosStatus.loading));
    final r = await _repository.list();
    r.fold(
      (f) => emit(state.copyWith(status: UsuariosStatus.error, failure: f)),
      (list) =>
          emit(state.copyWith(status: UsuariosStatus.loaded, items: list)),
    );
  }

  Future<void> _onCreate(
    UsuariosCreateRequested event,
    Emitter<UsuariosState> emit,
  ) async {
    emit(state.copyWith(status: UsuariosStatus.submitting));
    final r = await _repository.create(
      email: event.email,
      password: event.password,
      nombre: event.nombre,
      telefono: event.telefono,
      rol: event.rol,
    );
    await r.fold(
      (f) async => emit(
        state.copyWith(status: UsuariosStatus.error, failure: f),
      ),
      (_) async {
        emit(state.copyWith(status: UsuariosStatus.success));
        add(const UsuariosStarted());
      },
    );
  }

  Future<void> _onUpdate(
    UsuariosUpdateRequested event,
    Emitter<UsuariosState> emit,
  ) async {
    emit(state.copyWith(status: UsuariosStatus.submitting));
    final r = await _repository.update(
      event.id,
      nombre: event.nombre,
      telefono: event.telefono,
      rol: event.rol,
    );
    await r.fold(
      (f) async => emit(
        state.copyWith(status: UsuariosStatus.error, failure: f),
      ),
      (_) async {
        emit(state.copyWith(status: UsuariosStatus.success));
        add(const UsuariosStarted());
      },
    );
  }

  Future<void> _onDelete(
    UsuariosDeleteRequested event,
    Emitter<UsuariosState> emit,
  ) async {
    emit(state.copyWith(status: UsuariosStatus.submitting));
    final r = await _repository.remove(event.id);
    await r.fold(
      (f) async => emit(
        state.copyWith(status: UsuariosStatus.error, failure: f),
      ),
      (_) async {
        emit(state.copyWith(status: UsuariosStatus.success));
        add(const UsuariosStarted());
      },
    );
  }
}
