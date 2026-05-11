/// Catálogo de rutas relativas al `baseUrl` (`/api`).
///
/// El `baseUrl` ya incluye el prefijo `/api`, por lo que aquí
/// las rutas empiezan con `/auth/...`, `/dashboard`, etc.
class ApiEndpoints {
  ApiEndpoints._();

  // Health
  static const String health = '/';

  // Auth
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/registro';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  // Dashboard
  static const String dashboard = '/dashboard';
  static const String dashboardSummary = '/dashboard/summary';
  static const String dashboardInteligencia = '/dashboard/inteligencia';

  /// Rutas que NO requieren `Authorization` header.
  static const Set<String> publicPaths = {
    health,
    authLogin,
    authRegister,
  };

  static bool isPublic(String path) {
    return publicPaths.any((p) => path.endsWith(p));
  }

  static bool isRefresh(String path) => path.endsWith(authRefresh);
}
