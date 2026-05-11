import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/tenant_summary.dart';
import '../../domain/repositories/admin_repository.dart';

// Events
sealed class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

class AdminDataLoaded extends AdminEvent {
  const AdminDataLoaded();
}

class AdminUserCreated extends AdminEvent {
  final String email;
  final String password;
  final String nombre;
  final String tenantId;
  final String rol;

  const AdminUserCreated({
    required this.email,
    required this.password,
    required this.nombre,
    required this.tenantId,
    required this.rol,
  });

  @override
  List<Object?> get props => [email, nombre, tenantId, rol];
}

// State
enum AdminStatus { initial, loading, loaded, creating, created, error }

class AdminState extends Equatable {
  final AdminStatus status;
  final List<TenantSummary> tenants;
  final List<AdminUser> users;
  final AppFailure? failure;
  final String? successMessage;

  const AdminState({
    this.status = AdminStatus.initial,
    this.tenants = const [],
    this.users = const [],
    this.failure,
    this.successMessage,
  });

  AdminState copyWith({
    AdminStatus? status,
    List<TenantSummary>? tenants,
    List<AdminUser>? users,
    AppFailure? failure,
    String? successMessage,
  }) =>
      AdminState(
        status: status ?? this.status,
        tenants: tenants ?? this.tenants,
        users: users ?? this.users,
        failure: failure,
        successMessage: successMessage,
      );

  @override
  List<Object?> get props => [status, tenants, users, failure, successMessage];
}

// Bloc
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repository;

  AdminBloc({required AdminRepository repository})
      : _repository = repository,
        super(const AdminState()) {
    on<AdminDataLoaded>(_onLoaded);
    on<AdminUserCreated>(_onUserCreated);
  }

  Future<void> _onLoaded(
    AdminDataLoaded event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    final tenantsResult = await _repository.listTenants();
    final usersResult = await _repository.listAllUsers();

    final failure = tenantsResult.fold<AppFailure?>((f) => f, (_) => null) ??
        usersResult.fold<AppFailure?>((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(status: AdminStatus.error, failure: failure));
      return;
    }
    emit(state.copyWith(
      status: AdminStatus.loaded,
      tenants: tenantsResult.getOrElse(() => const []),
      users: usersResult.getOrElse(() => const []),
    ));
  }

  Future<void> _onUserCreated(
    AdminUserCreated event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.creating));
    final result = await _repository.createUser(
      email: event.email,
      password: event.password,
      nombre: event.nombre,
      tenantId: event.tenantId,
      rol: event.rol,
    );
    await result.fold(
      (f) async => emit(state.copyWith(
        status: AdminStatus.error,
        failure: f,
      )),
      (_) async {
        final tenantsResult = await _repository.listTenants();
        final usersResult = await _repository.listAllUsers();
        emit(state.copyWith(
          status: AdminStatus.created,
          tenants: tenantsResult.getOrElse(() => const []),
          users: usersResult.getOrElse(() => const []),
          successMessage: 'Usuario ${event.email} creado en ${event.tenantId}',
        ));
      },
    );
  }
}
