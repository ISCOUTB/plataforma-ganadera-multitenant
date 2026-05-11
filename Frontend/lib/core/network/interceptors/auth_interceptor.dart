import 'package:dio/dio.dart';

import '../../config/env.dart';
import '../../routing/auth_event_bus.dart';
import '../../storage/secure_storage_service.dart';
import '../api_endpoints.dart';

/// Interceptor de autenticación.
///
/// Responsabilidades:
/// 1. Inyectar `Authorization: Bearer <access>` en cada request, salvo
///    rutas públicas (`@Public` en el backend) y la propia `/auth/refresh`.
/// 2. Detectar `401 Unauthorized` → llamar `/auth/refresh` UNA sola vez,
///    encolando requests concurrentes para que ninguna se pierda.
/// 3. Si el refresh falla → limpiar storage y emitir [AuthSignal.sessionExpired]
///    en el [AuthEventBus] para que `AuthBloc` redirija al login.
///
/// **FARMLINK_RULE**: este interceptor jamás añade `tenant_id` a headers,
/// query strings ni bodies. El backend lo extrae del JWT firmado.
class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _storage;
  final AuthEventBus _eventBus;

  /// Dio dedicado, SIN este interceptor, para evitar recursión infinita
  /// si la propia llamada a `/auth/refresh` devolviera 401.
  final Dio _refreshDio;

  bool _isRefreshing = false;
  final List<_PendingRequest> _queue = [];

  AuthInterceptor({
    required SecureStorageService storage,
    required AuthEventBus eventBus,
    required Dio refreshDio,
  })  : _storage = storage,
        _eventBus = eventBus,
        _refreshDio = refreshDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (ApiEndpoints.isPublic(options.path) ||
        ApiEndpoints.isRefresh(options.path)) {
      return handler.next(options);
    }

    final token = await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthError = err.response?.statusCode == 401;
    final isRefreshCall = ApiEndpoints.isRefresh(err.requestOptions.path);

    if (!isAuthError || isRefreshCall) {
      return handler.next(err);
    }

    // Si ya hay un refresh en curso, encolar la request original.
    if (_isRefreshing) {
      _queue.add(_PendingRequest(err.requestOptions, handler));
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _storage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw _NoRefreshTokenException();
      }

      final response = await _refreshDio.post(
        '${Env.apiBaseUrl}${ApiEndpoints.authRefresh}',
        data: {'refresh_token': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final newAccess = data['access_token'] as String;
      final newRefresh = data['refresh_token'] as String;
      await _storage.saveTokens(access: newAccess, refresh: newRefresh);

      // Reintentar la request original con el nuevo bearer.
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      final retried = await _refreshDio.fetch(err.requestOptions);
      handler.resolve(retried);

      // Liberar la cola con el mismo bearer.
      for (final pending in _queue) {
        pending.options.headers['Authorization'] = 'Bearer $newAccess';
        try {
          final r = await _refreshDio.fetch(pending.options);
          pending.handler.resolve(r);
        } catch (e) {
          if (e is DioException) {
            pending.handler.reject(e);
          } else {
            pending.handler.reject(
              DioException(requestOptions: pending.options, error: e),
            );
          }
        }
      }
      _queue.clear();
    } catch (_) {
      // Refresh falló → cerrar sesión
      await _storage.clear();
      _eventBus.emit(AuthSignal.sessionExpired);
      for (final pending in _queue) {
        pending.handler.reject(err);
      }
      _queue.clear();
      handler.reject(err);
    } finally {
      _isRefreshing = false;
    }
  }
}

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.options, this.handler);
}

class _NoRefreshTokenException implements Exception {}
