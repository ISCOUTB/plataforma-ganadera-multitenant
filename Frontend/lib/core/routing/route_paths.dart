/// Rutas de la app — fuente única de verdad para `go_router`.
class RoutePaths {
  RoutePaths._();

  // Rutas de auth (fuera del shell)
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // Rutas dentro del shell con bottom nav
  static const String home = '/home';
  static const String inventory = '/inventory';
  static const String health = '/health';
  static const String money = '/money';
  static const String settings = '/settings';

  /// Lista de rutas raíz del shell, en orden del bottom nav.
  static const List<String> shellTabs = [
    home,
    inventory,
    health,
    money,
    settings,
  ];
}
