import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final AppFailure? failure;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.failure,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.authenticated(User user)
      : this(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AuthState.failure(AppFailure failure)
      : this(status: AuthStatus.failure, failure: failure);

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  AuthState copyWith({AuthStatus? status, User? user, AppFailure? failure}) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        failure: failure ?? this.failure,
      );

  @override
  List<Object?> get props => [status, user, failure];
}
