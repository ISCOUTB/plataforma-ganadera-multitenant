/// Configuración de entorno inyectada vía `--dart-define`.
class Env {
  Env._();

  /// Base URL del backend NestJS. Por defecto apunta al host de la máquina
  /// desde el emulador Android (`10.0.2.2`). En iOS simulador o web es
  /// recomendable pasarlo explícitamente con
  /// `--dart-define=API_BASE_URL=http://localhost:3000/api`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 45);

  static const bool isDebug = !bool.fromEnvironment('dart.vm.product');
}
