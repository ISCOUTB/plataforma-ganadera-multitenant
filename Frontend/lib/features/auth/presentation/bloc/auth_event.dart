import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String nombre;
  final String tenantId;
  final String? telefono;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.nombre,
    required this.tenantId,
    this.telefono,
  });

  @override
  List<Object?> get props => [email, password, nombre, tenantId, telefono];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}
