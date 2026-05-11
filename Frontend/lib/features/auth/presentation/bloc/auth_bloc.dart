import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routing/auth_event_bus.dart';
import '../../../dashboard/domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/hydrate_session_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final HydrateSessionUseCase _hydrateSessionUseCase;
  final AuthEventBus _eventBus;

  late final StreamSubscription<AuthSignal> _busSub;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required HydrateSessionUseCase hydrateSessionUseCase,
    required AuthEventBus eventBus,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _hydrateSessionUseCase = hydrateSessionUseCase,
        _eventBus = eventBus,
        super(const AuthState.initial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>(_onSessionExpired);

    _busSub = _eventBus.stream.listen((signal) {
      if (signal == AuthSignal.sessionExpired) {
        add(const AuthSessionExpired());
      }
    });
  }

  Future<void> _onAppStarted(
    AuthAppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _hydrateSessionUseCase();
    result.fold(
      (_) => emit(const AuthState.unauthenticated()),
      (user) {
        if (user == null) {
          emit(const AuthState.unauthenticated());
        } else {
          emit(AuthState.authenticated(user));
        }
      },
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthState.failure(failure)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _registerUseCase(
      email: event.email,
      password: event.password,
      nombre: event.nombre,
      tenantId: event.tenantId,
      telefono: event.telefono,
    );
    result.fold(
      (failure) => emit(AuthState.failure(failure)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    // Captura el tenantId ANTES de hacer logout (después se pierde).
    final tenantId = state.user?.tenantId;
    await _logoutUseCase();
    // Limpia el cache local del dashboard del tenant que cerró sesión
    // para que si otro usuario entra en el mismo dispositivo no vea
    // datos del anterior.
    if (tenantId != null) {
      await getIt<DashboardRepository>().clearLocalCache(tenantId);
    }
    emit(const AuthState.unauthenticated());
  }

  void _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthState.unauthenticated());
  }

  @override
  Future<void> close() {
    _busSub.cancel();
    return super.close();
  }
}
