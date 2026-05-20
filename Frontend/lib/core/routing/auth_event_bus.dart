import 'dart:async';

/// Señales de sesión emitidas por la capa data (e.g. interceptor de auth)
/// y consumidas por la capa presentation (`AuthBloc`) sin acoplar capas.
enum AuthSignal { sessionExpired }

class AuthEventBus {
  final StreamController<AuthSignal> _controller =
      StreamController<AuthSignal>.broadcast();

  Stream<AuthSignal> get stream => _controller.stream;

  void emit(AuthSignal signal) => _controller.add(signal);

  void dispose() => _controller.close();
}
