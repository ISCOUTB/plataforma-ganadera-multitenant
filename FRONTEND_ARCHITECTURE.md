# FarmLink — Arquitectura Frontend Mobile (Flutter)

> Documento de diseño previo a `flutter create`. Define arquitectura, patrones, estrategia de red/auth y roadmap del cliente móvil que consume la API NestJS de FarmLink (60 endpoints, multitenant, dual-token JWT).

---

## 1. Resumen ejecutivo

| Decisión | Elección | Razón corta |
|---|---|---|
| Patrón arquitectónico | **Clean Architecture + Feature-First** | Escala bien con 14 módulos, aísla dominio de Flutter, facilita testing |
| State management | **flutter_bloc (BLoC + Cubit)** | Predecible, testeable, ideal para flujos auth/refresh y CRUD complejo |
| Cliente HTTP | **dio + interceptores** | Soporte nativo de interceptores, cancelación, FormData, retry |
| Inyección de dependencias | **get_it + injectable** | DI compile-time, sin overhead en runtime |
| Routing | **go_router** | Navegación declarativa, deep links, guards de auth |
| Modelos | **freezed + json_serializable** | Inmutabilidad, copyWith, unions, generación automática |
| Almacenamiento seguro | **flutter_secure_storage** | Keychain (iOS) / Keystore (Android) para tokens |
| Almacenamiento ligero | **shared_preferences** | Flags UI, último tenant, tema |
| Cache offline | **hive** (fase 3) | Lecturas rápidas de listados |
| i18n | **flutter_localizations + intl** | Español por defecto |
| Testing | **bloc_test, mocktail, integration_test** | Cobertura por capa |

---

## 2. Análisis del contrato API (resumen relevante)

Lo que la app móvil debe respetar:

- **Base URL**: `http://<host>:3000/api`. Configurable por `--dart-define`.
- **Auth dual-token**:
  - `access_token` (JWT, 1d) → header `Authorization: Bearer <token>` en cada request.
  - `refresh_token` (JWT, 7d) → rotación obligatoria en `/api/auth/refresh`. En móvil **no usaremos cookie HTTP-only** (es inviable fuera del navegador): mandaremos el refresh por **body** `{ "refresh_token": "..." }`, que es la 3ª opción aceptada por el backend.
- **Tenant**: viaja firmado dentro del JWT (`tenant_id` claim). El backend lo extrae y valida con `TenantGuard`. **El cliente jamás lo envía**.
- **Roles**: `admin | propietario | empleado` (claim `rol`).
- **Paginación estándar**: `?page=1&limit=10&sortBy=...&sortOrder=DESC`. Respuesta: `{ data, total, page, lastPage }`.
- **Errores estandarizados**: `{ statusCode, message, path, timestamp }`. `message` puede ser string o array (cuando ValidationPipe falla).
- **Códigos a manejar**: `400` (validación), `401` (token inválido/expirado → refresh), `403` (sin permiso o tenant cruzado), `404`, `409` (conflicto), `500`.
- **Soft delete**: el cliente no debe distinguirlo; el backend ya filtra.
- **PKs heterogéneas**: algunas entidades usan PK string manual (`FINCA001`, `POT001`, `ALI001`, `REP001`, `FIN001`), otras `int` (`Animal`, `Salud`, `MovimientoAnimal`). Los modelos Dart deben tipar correctamente.

---

## 3. Estructura de carpetas

Organización **feature-first** con tres capas internas (`domain`, `data`, `presentation`) por feature, más un núcleo compartido (`core`).

```
lib/
├── main.dart                          # Bootstrap: DI, BlocObserver, runApp
├── app.dart                           # MaterialApp.router + theme + locales
│
├── core/
│   ├── config/
│   │   ├── env.dart                   # API_BASE_URL via --dart-define
│   │   └── app_config.dart
│   ├── di/
│   │   ├── injection.dart             # get_it container
│   │   └── injection.config.dart      # generado por injectable
│   ├── network/
│   │   ├── dio_client.dart            # Factory de Dio + interceptores
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart  # inyecta Bearer + maneja 401 + refresh
│   │   │   ├── logging_interceptor.dart
│   │   │   └── error_interceptor.dart # mapea ApiError → AppFailure
│   │   ├── api_endpoints.dart         # constantes de rutas
│   │   └── api_result.dart            # Either<Failure, T> wrapper
│   ├── error/
│   │   ├── failures.dart              # AppFailure sealed class
│   │   ├── exceptions.dart            # ServerException, NetworkException...
│   │   └── error_mapper.dart
│   ├── storage/
│   │   ├── secure_storage_service.dart # tokens (flutter_secure_storage)
│   │   └── prefs_service.dart          # UI prefs (shared_preferences)
│   ├── routing/
│   │   ├── app_router.dart            # go_router config + guards
│   │   └── route_paths.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── widgets/                       # AppButton, AppTextField, EmptyState, ErrorView
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart            # fechas, moneda COP
│   │   └── extensions.dart
│   └── models/
│       ├── paginated_response.dart    # PaginatedResponse<T> genérico
│       └── api_error.dart
│
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/              # User, AuthTokens
│   │   │   ├── repositories/auth_repository.dart       # interfaz
│   │   │   └── usecases/              # LoginUseCase, RefreshTokenUseCase, LogoutUseCase, GetMeUseCase
│   │   ├── data/
│   │   │   ├── models/                # UserModel, LoginRequestDto, AuthResponseDto (freezed)
│   │   │   ├── datasources/auth_remote_datasource.dart # llama dio
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/auth_bloc.dart    # estado global de sesión
│   │       ├── pages/login_page.dart
│   │       ├── pages/register_page.dart
│   │       ├── pages/splash_page.dart
│   │       └── widgets/
│   │
│   ├── fincas/
│   │   ├── domain/{entities,repositories,usecases}/
│   │   ├── data/{models,datasources,repositories}/
│   │   └── presentation/{bloc,pages,widgets}/
│   │
│   ├── animales/         # idem
│   ├── potreros/         # idem
│   ├── alimentos/        # idem
│   ├── bovino_alimento/  # idem
│   ├── salud/            # idem (incluye alertas de salud)
│   ├── reproduccion/     # idem (incluye alertas reproductivas)
│   ├── finanzas/         # idem (incluye resumen)
│   ├── movimientos/      # idem
│   ├── dashboard/        # solo presentation + remote datasource (read-only)
│   └── alertas/          # vista consolidada
│
└── l10n/
    ├── app_es.arb
    └── app_en.arb (futuro)

test/
├── core/
└── features/<feature>/{domain,data,presentation}/
```

### Reglas de capa

1. **`domain`** no importa nada de `data` ni de Flutter. Solo Dart puro + `dartz`/`freezed`.
2. **`data`** implementa interfaces de `domain` y conoce `dio`, DTOs JSON, mappers DTO→Entity.
3. **`presentation`** consume **usecases** vía BLoC, jamás llama datasources directamente.
4. Comunicación entre features: a través de `AuthBloc` (sesión global) o eventos en el router. **No hay imports cruzados** entre `features/x` y `features/y`.

---

## 4. Patrón de manejo de estado: **flutter_bloc**

### ¿Por qué BLoC y no Riverpod?

| Criterio | BLoC | Riverpod |
|---|---|---|
| Curva de aprendizaje del equipo | Más estructurado, menos "magia" | Más flexible pero requiere disciplina |
| Adecuación a CRUD multi-módulo | Excelente: cada feature un Bloc/Cubit | Igual de bueno |
| Testing | `bloc_test` maduro, snapshots de estados | `ProviderContainer` |
| Ecosistema oficial Flutter | Recomendado por `flutter.dev` | Comunitario, muy popular |
| Manejo de eventos imperativos (login, refresh) | Natural (events) | Posible pero menos idiomático |

**Decisión**: usamos **flutter_bloc** porque el equipo está aprendiendo Flutter y la separación explícita `Event → Bloc → State` reduce errores en flujos críticos como autenticación y refresh de tokens. Para estados muy simples (toggles, formularios pequeños) usaremos **Cubit**.

### Convenciones BLoC

- Un BLoC por feature (`AnimalesBloc`, `FincasBloc`, etc.) + `AuthBloc` global.
- Estados modelados con **freezed** como union types:
  ```dart
  @freezed
  class AnimalesState with _$AnimalesState {
    const factory AnimalesState.initial() = _Initial;
    const factory AnimalesState.loading() = _Loading;
    const factory AnimalesState.loaded(List<Animal> animales, int page, int lastPage) = _Loaded;
    const factory AnimalesState.error(AppFailure failure) = _Error;
  }
  ```
- Eventos también en freezed (`AnimalesEvent.fetch()`, `AnimalesEvent.create(dto)`...).
- Los BLoCs reciben **usecases** por constructor (no repositorios), para mantener la regla de dependencia.

---

## 5. Estrategia de red y autenticación (CRÍTICO)

### 5.1 Cliente HTTP — `dio_client.dart`

```dart
@lazySingleton
class DioClient {
  late final Dio dio;

  DioClient(SecureStorageService storage, AuthInterceptor authInterceptor) {
    dio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,                 // p. ej. http://10.0.2.2:3000/api
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));

    dio.interceptors.addAll([
      authInterceptor,                          // Bearer + 401 → refresh
      LoggingInterceptor(),                     // solo en debug
      ErrorInterceptor(),                       // mapea a AppFailure
    ]);
  }
}
```

### 5.2 `AuthInterceptor` — el corazón del sistema

Responsable de:

1. **Inyectar `Authorization: Bearer <access_token>`** en cada request, salvo:
   - Endpoints `@Public`: `/auth/login`, `/auth/registro`, `/` (health).
   - El propio `/auth/refresh` (lleva su propio bearer del refresh).
2. **Detectar `401 Unauthorized`** → intentar refresh **una sola vez** → reintentar la request original.
3. **Si el refresh falla** → emitir evento `AuthBloc.add(SessionExpired())` y limpiar el storage.
4. **Encolar requests concurrentes** mientras el refresh está en vuelo (evitar tormenta de refreshes).

```dart
@injectable
class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService storage;
  final Dio _refreshDio;            // Dio "limpio" sin este interceptor para evitar recursión
  final AuthEventBus eventBus;       // canal para notificar AuthBloc

  bool _isRefreshing = false;
  final List<_PendingRequest> _queue = [];

  AuthInterceptor(this.storage, this._refreshDio, this.eventBus);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_isPublic(options.path) || options.path.contains('/auth/refresh')) {
      return handler.next(options);
    }
    final token = await storage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isAuthError = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path.contains('/auth/refresh');

    if (!isAuthError || isRefreshCall) {
      return handler.next(err);
    }

    // Evitar refrescos paralelos: encolar
    if (_isRefreshing) {
      _queue.add(_PendingRequest(err.requestOptions, handler));
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await storage.readRefreshToken();
      if (refreshToken == null) throw _NoRefreshToken();

      final response = await _refreshDio.post(
        '${Env.apiBaseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccess = response.data['access_token'] as String;
      final newRefresh = response.data['refresh_token'] as String;
      await storage.saveTokens(access: newAccess, refresh: newRefresh);

      // Reintentar la request original
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      final retried = await _refreshDio.fetch(err.requestOptions);
      handler.resolve(retried);

      // Liberar la cola
      for (final pending in _queue) {
        pending.options.headers['Authorization'] = 'Bearer $newAccess';
        try {
          final r = await _refreshDio.fetch(pending.options);
          pending.handler.resolve(r);
        } catch (e) {
          pending.handler.reject(e as DioException);
        }
      }
      _queue.clear();
    } catch (_) {
      // Refresh falló → cerrar sesión
      await storage.clear();
      eventBus.emit(const AuthEvent.sessionExpired());
      for (final p in _queue) p.handler.reject(err);
      _queue.clear();
      handler.reject(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
```

> **Detalle clave**: el refresh se hace con un `Dio` separado (`_refreshDio`) sin este interceptor, para evitar recursión infinita si la propia llamada de refresh devuelve 401/403.

### 5.3 Almacenamiento de tokens — `SecureStorageService`

```dart
@lazySingleton
class SecureStorageService {
  static const _kAccess = 'farmlink.access_token';
  static const _kRefresh = 'farmlink.refresh_token';

  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  Future<String?> readAccessToken() => _storage.read(key: _kAccess);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);
  Future<void> clear() => _storage.deleteAll();
}
```

- **Ambos** tokens en `flutter_secure_storage` (Keychain iOS, EncryptedSharedPrefs Android).
- **Nunca** en `shared_preferences` ni en memoria volátil sola.
- En logout, `clear()` + llamada a `POST /auth/logout` para invalidar el hash en backend.

### 5.4 Regla inquebrantable: **el `tenant_id` JAMÁS se envía manualmente**

> ⚠️ **PROHIBIDO en todo el código del cliente**:
> - No agregar headers `X-Tenant-ID`, `Tenant`, ni similares.
> - No incluir `tenant_id` en query strings (`?tenant_id=...`).
> - No incluir `tenant_id` en bodies de request (excepto en `POST /auth/registro`, único endpoint público que lo necesita para crear el usuario).
>
> **Razón**: el backend extrae el `tenant_id` del JWT firmado en `TenantGuard`. Cualquier `tenant_id` adicional que no coincida con el del token devuelve **403 Forbidden** (escalada horizontal bloqueada). Mandar el tenant manualmente es:
> 1. Inseguro (intento de cross-tenant detectado).
> 2. Innecesario (ya viaja firmado).
> 3. Causa de bugs sutiles si el usuario cambia de tenant.
>
> **Cambio de tenant**: si un usuario pertenece a varios, el flujo es **logout → login con credenciales del otro tenant**. No existe endpoint de switch.

Para hacer cumplir la regla añadiremos un **lint/test** que escanee `lib/features/**/data/datasources/*.dart` y falle si encuentra los strings `tenant_id`, `tenantId`, `X-Tenant`. El único allowlist será `auth_remote_datasource.dart` en el método `register()`.

### 5.5 Manejo de errores estandarizado

`ErrorInterceptor` mapea la respuesta del backend a `AppFailure`:

```dart
sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}
class ValidationFailure extends AppFailure { final List<String> fieldErrors; ... }
class UnauthorizedFailure extends AppFailure { ... }   // 401 tras refresh fallido
class ForbiddenFailure extends AppFailure { ... }      // 403 (rol o tenant)
class NotFoundFailure extends AppFailure { ... }
class ConflictFailure extends AppFailure { ... }       // 409 (email duplicado, PKs)
class ServerFailure extends AppFailure { ... }         // 500
class NetworkFailure extends AppFailure { ... }        // sin conexión / timeout
```

Las páginas muestran mensajes amigables vía un widget `ErrorView` + `SnackBar`.

---

## 6. Generación de modelos: **freezed + json_serializable**

Cada DTO del backend tendrá su contraparte Dart inmutable:

```dart
// features/animales/data/models/animal_model.dart
@freezed
class AnimalModel with _$AnimalModel {
  const factory AnimalModel({
    required int id,
    required String numero_identificacion,
    String? metodo_identificacion,
    required DateTime fecha_nacimiento,
    int? edad_actual,
    required String genero,                  // 'm' | 'h' | 'n'
    required double peso,
    double? altura,
    required String raza,
    String? origen,
    DateTime? fecha_ingreso,
    DateTime? fecha_salida,
    String? fincaId,
    String? potreroId,
    required String estado,                  // 'activo' | 'vendido'
    DateTime? created_at,
    DateTime? updated_at,
  }) = _AnimalModel;

  factory AnimalModel.fromJson(Map<String, dynamic> json) =>
      _$AnimalModelFromJson(json);
}
```

Razones:
- **Inmutables**: evita bugs de mutación accidental dentro de los Bloc.
- **`copyWith`** generado: ideal para actualizar estados parciales.
- **Union types** para estados (`@freezed` con factories múltiples).
- **`fromJson/toJson`** generados automáticamente con `json_serializable`.
- **Igualdad por valor**: `bloc` los compara correctamente para evitar rebuilds innecesarios.

### Wrapper genérico de paginación

```dart
@Freezed(genericArgumentFactories: true)
class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    required List<T> data,
    required int total,
    required int page,
    required int lastPage,
  }) = _PaginatedResponse<T>;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);
}
```

### Convención: Model vs Entity

- `AnimalModel` (data layer) → refleja el JSON 1:1, usa snake_case si el backend lo usa.
- `Animal` (domain layer) → entity limpia para el dominio (camelCase, sin nullables innecesarios).
- Mapper estático en `AnimalModel.toEntity()` y `Animal.toCreateDto()`.

---

## 7. Roadmap por fases

Las fases son **incrementales y demostrables**. Cada fase produce una build que se puede mostrar.

### **Fase 0 — Cimientos (sin UI funcional)**
- `flutter create`, configuración de linter (`very_good_analysis`).
- Setup de `dio`, `flutter_bloc`, `freezed`, `json_serializable`, `get_it`/`injectable`, `go_router`, `flutter_secure_storage`.
- `core/` completo: `DioClient`, `AuthInterceptor`, `SecureStorageService`, `ErrorInterceptor`, `AppFailure`, `PaginatedResponse<T>`.
- Tema base + i18n español + splash.
- Tests unitarios del `AuthInterceptor` (mock de 401 → refresh → retry).

### **Fase 1 — Auth y bootstrap de sesión**
**Endpoints**: `POST /auth/registro`, `POST /auth/login`, `GET /auth/me`, `POST /auth/refresh`, `POST /auth/logout`.
- `features/auth/` completo (domain + data + presentation).
- `AuthBloc` global expuesto en el árbol con `BlocProvider`.
- `SplashPage`: lee tokens → llama `/auth/me` → decide ruta (`/login` o `/home`).
- `LoginPage`, `RegisterPage` (en registro pedimos `tenant_id` al usuario, único caso).
- Guards de `go_router` que redirigen a `/login` si `AuthBloc` está en estado `unauthenticated`.
- Logout completo (POST + clear storage + navegación).

### **Fase 2 — Núcleo ganadero (CRUD core)**
**Endpoints**: Fincas (7), Potreros (7), Animales (7).
- Listados paginados con `infinite_scroll_pagination` o BLoC custom (`onScroll → fetchNextPage`).
- Filtros (raza, género, estado para animales; nombre/ubicación para fincas; fincaId para potreros).
- Pantalla de detalle de finca con sub-listas (animales, potreros) usando los endpoints `/fincas/:id/animales` y `/fincas/:id/potreros`.
- Formularios de creación/edición con validación cliente espejando los DTOs del backend.
- Acción especial: `POST /animales/:id/vender` (modal con precio, comprador, fecha).
- Pantalla de ocupación de potrero (`GET /potreros/:id/ocupacion`).

### **Fase 3 — Operaciones del día a día**
**Endpoints**: Alimentos (5), Bovino-Alimento (4), Salud (6), Movimientos (3).
- CRUD de alimentos.
- Asignación N:N alimento↔animal con historial por animal.
- Registros de salud + listado de alertas (`GET /salud/alertas`).
- Movimientos entre potreros con validación de capacidad (el backend ya valida; el cliente muestra error 400 amigable).
- Historial de movimientos por animal.

### **Fase 4 — Reproducción y finanzas**
**Endpoints**: Reproducción (6), Finanzas (6).
- Eventos reproductivos + alertas (`partos_proximos`, `partos_vencidos`, `en_celo`).
- CRUD de movimientos financieros con filtros por tipo y categoría.
- Pantalla de resumen financiero (`GET /finanzas/resumen`).

### **Fase 5 — Inteligencia: Dashboard y Alertas**
**Endpoints**: `GET /dashboard`, `GET /alertas`.
- Dashboard con tarjetas: inventario, finanzas, alertas pendientes, top costos, estimación de ganancia.
- Centro de alertas consolidado con priorización por severidad (HIGH/MEDIUM/LOW), agrupando salud + reproducción.
- Pull-to-refresh global y deep links a la entidad afectada por la alerta.

### **Fase 6 — Pulido y producción**
- Cache offline con Hive para listados clave (animales, fincas) — modo solo-lectura sin red.
- Animaciones, skeleton loaders, empty states.
- Tests de integración (`integration_test`) de los flujos críticos: login, crear animal, vender animal, ver dashboard.
- CI: `flutter analyze`, `flutter test`, build de APK/IPA.
- Configuración multi-entorno (`dev`, `staging`, `prod`) con `--dart-define`.

---

## 8. Decisiones pendientes (a confirmar contigo)

1. **Versión mínima**: ¿Android 7+ (API 24) y iOS 13+? Define el target de `flutter_secure_storage`.
2. **Modo offline**: ¿es requerimiento de la fase 1 o lo dejamos para fase 6 como propongo?
3. **Multi-tenant en un mismo dispositivo**: ¿permitimos múltiples sesiones guardadas (un usuario por tenant) o solo una a la vez? Mi propuesta: una sola, simplificamos.
4. **Notificaciones push**: las alertas del dashboard sugieren push notifications (FCM). ¿Dentro del scope inicial o post-MVP?
5. **Idiomas**: ¿solo español o también inglés desde el día 1?
6. **Versionado de API**: el backend hoy expone `/api` sin versión. Si en el futuro hay `/api/v2`, ¿cómo se manejará? Propuesta: constante `Env.apiBaseUrl` ya lo absorbe.

---

## 9. Próximo paso

Una vez revises y aprobemos este documento, ejecutaremos:

```bash
flutter create --org com.farmlink --project-name farmlink_mobile mobile
cd mobile
# Añadir dependencias del pubspec según fase 0
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Y arrancaremos la **Fase 0** (cimientos + interceptores + tests del flujo de refresh) antes de tocar UI.
