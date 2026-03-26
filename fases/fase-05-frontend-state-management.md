# Fase 5: Frontend State Management & Arquitectura

## Estado Actual

| Archivo | Rol | Problemas |
|---------|-----|-----------|
| `main.dart` | Entry, MaterialApp | Sin router, sin ProviderScope |
| `Landing_screen.dart` | Landing marketing | PascalCase, Navigator.push imperativo |
| `Login_screen.dart` | Login form (setState) | Crea `ApiService()` localmente, descarta respuesta |
| `Registro_screen.dart` | Registro (setState) | Hardcoded `tenant_id: 'finca1'` |
| `Dashboard_screen.dart` | 100% hardcoded | 729 lineas, cero llamadas API |
| `api_service.dart` | Cliente Dio | Hardcoded `localhost:3000`, sin interceptores |
| `input_field.dart` | TextField reutilizable | Sin soporte de validacion |
| `primary_button.dart` | Boton reutilizable | Importa `Colors.dart` con C mayuscula |
| `Theme.dart` | ThemeData | Importa `colors.dart` minuscula (inconsistente) |
| `Colors.dart` | Constantes de color | Nombre PascalCase: rompe en Linux CI |

### Dependencias actuales
- `flutter` SDK, `cupertino_icons`, `dio: ^5.9.2`

---

## Eleccion: Riverpod

| Libreria | Razon de descarte/eleccion |
|----------|---------------------------|
| Provider | Legacy. Su creador construyo Riverpod como sucesor |
| Bloc/Cubit | Excesivo boilerplate para proyecto academico de 4 personas |
| GetX | Anti-patron, poca testabilidad, sin seguridad en compilacion |
| **Riverpod** | Compile-safe, independiente del widget tree, `AsyncValue` built-in, auto-disposal |

---

## Paquetes a Agregar

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  go_router: ^14.8.1
  flutter_secure_storage: ^9.2.4
  pretty_dio_logger: ^1.4.0
  freezed_annotation: ^2.4.6
  json_annotation: ^4.9.0
  connectivity_plus: ^6.1.4
  shared_preferences: ^2.3.5

dev_dependencies:
  build_runner: ^2.4.14
  riverpod_generator: ^2.6.4
  freezed: ^2.5.8
  json_serializable: ^6.9.4
```

---

## Estructura de Carpetas Objetivo (Feature-First)

```
Frontend/lib/
  main.dart                          # ProviderScope + GoRouter
  app.dart                           # FarmLinkApp (MaterialApp.router)

  core/
    config/
      env_config.dart                # API base URL desde env
    network/
      dio_client.dart                # Dio singleton con interceptores
      auth_interceptor.dart          # Bearer token en cada request
      api_exceptions.dart            # Excepciones tipadas
    router/
      app_router.dart                # GoRouter con redirect logic
    storage/
      secure_storage_service.dart    # flutter_secure_storage wrapper
    theme/
      app_colors.dart                # Renombrado de Colors.dart
      app_theme.dart                 # Renombrado de Theme.dart
      app_text_styles.dart           # Estilos extraidos
    utils/
      validators.dart                # Validacion email, password

  features/
    auth/
      data/
        models/usuario_model.dart
        repositories/auth_repository.dart
        datasources/
          auth_remote_datasource.dart
          auth_local_datasource.dart
      domain/auth_state.dart         # freezed union
      presentation/
        providers/auth_provider.dart
        screens/
          login_screen.dart
          registro_screen.dart

    landing/
      presentation/
        screens/landing_screen.dart
        widgets/
          navbar_widget.dart
          hero_section_widget.dart
          features_section_widget.dart

    dashboard/
      data/
        models/dashboard_metrics_model.dart
        repositories/dashboard_repository.dart
      presentation/
        providers/dashboard_provider.dart
        screens/dashboard_screen.dart
        widgets/
          metrics_grid.dart
          herd_distribution_card.dart
          financial_summary_card.dart

    shared/
      widgets/
        primary_button.dart
        input_field.dart
        loading_overlay.dart
```

---

## Plan de Renombrado de Archivos

| Actual | Nuevo | Razon |
|--------|-------|-------|
| `screens/Dashboard_screen.dart` | `features/dashboard/presentation/screens/dashboard_screen.dart` | snake_case + feature-first |
| `screens/Landing_screen.dart` | `features/landing/presentation/screens/landing_screen.dart` | snake_case |
| `screens/Login_screen.dart` | `features/auth/presentation/screens/login_screen.dart` | snake_case |
| `screens/Registro_screen.dart` | `features/auth/presentation/screens/registro_screen.dart` | snake_case |
| `theme/Theme.dart` | `core/theme/app_theme.dart` | snake_case, evita colision con Flutter Theme |
| `theme/Colors.dart` | `core/theme/app_colors.dart` | **FIX CRITICO**: corrige bug case-sensitivity Linux |
| `services/api_service.dart` | `core/network/dio_client.dart` | Reposicionado en core |
| `components/input_field.dart` | `features/shared/widgets/input_field.dart` | Mover a shared |
| `components/primary_button.dart` | `features/shared/widgets/primary_button.dart` | Mover a shared |

---

## Arquitectura de Estado de Autenticacion

```
App inicia
  └─> ProviderScope wraps MaterialApp.router
       └─> GoRouter verifica authProvider
            ├─ authProvider lee SecureStorage
            │   ├─ Encontrado → AuthState.authenticated(usuario)
            │   │   └─> redirect a /dashboard
            │   └─ No encontrado → AuthState.unauthenticated
            │       └─> redirect a /landing
            └─ En login exitoso:
                 ├─ API retorna Usuario
                 ├─ Serializa y guarda en flutter_secure_storage
                 ├─ Actualiza authProvider → authenticated
                 └─> GoRouter redirect → /dashboard
```

### Auth Provider
- `AuthNotifier` extiende `AsyncNotifier<AuthState>`
- `build()`: lee credenciales almacenadas, retorna authenticated o unauthenticated
- `login(email, password)`: llama AuthRepository, guarda resultado
- `registro(...)`: llama AuthRepository, guarda resultado
- `logout()`: limpia SecureStorage, set unauthenticated
- `@Riverpod(keepAlive: true)` -- sobrevive todo el ciclo de vida

### Almacenamiento de Token
- Guardar JSON serializado de `Usuario` bajo key `'user_data'`
- Cuando backend agregue JWT: key `'access_token'` y `'refresh_token'`
- `AuthInterceptor` lee token y agrega `Authorization: Bearer`
- En 401: limpia storage, redirect a `/login`

---

## Route Guards con GoRouter

| Ruta | Pantalla | Auth requerida |
|------|----------|----------------|
| `/` | LandingScreen | No |
| `/login` | LoginScreen | No (redirect a dashboard si authenticated) |
| `/registro` | RegistroScreen | No (redirect a dashboard si authenticated) |
| `/dashboard` | DashboardScreen | Si (redirect a login si not authenticated) |

**GoRouter redirect:**
- Si authenticated y ruta es `/login` o `/registro` → redirect a `/dashboard`
- Si unauthenticated y ruta empieza con `/dashboard` → redirect a `/login`

---

## Patron Repository

```
Screen (ConsumerWidget)
  └─> lee Provider (Riverpod)
       └─> Provider usa Repository
            └─> Repository orquesta DataSources
                 ├─> RemoteDataSource (Dio HTTP)
                 └─> LocalDataSource (SecureStorage / SharedPreferences)
```

---

## Manejo de Errores y Estados de Carga

### AsyncValue (built-in Riverpod)

```dart
ref.watch(dashboardProvider).when(
  data: (metrics) => MetricsGrid(metrics),
  loading: () => LoadingOverlay(),
  error: (e, st) => ErrorCard(message: mapError(e)),
)
```

### Jerarquia de Excepciones
- `ApiException` (base)
  - `NetworkException` -- sin internet
  - `ServerException(statusCode, message)` -- 500+
  - `UnauthorizedException` -- 401 (trigger logout)
  - `ConflictException` -- 409
  - `ValidationException(fields)` -- 400
  - `TimeoutException` -- timeout de conexion

---

## Consideraciones Offline-First

**Estrategia: Cache-then-network con stale-while-revalidate**

1. `SharedPreferences` para respuestas API cacheadas no sensibles
2. `flutter_secure_storage` solo para credenciales
3. `connectivity_plus` para detectar estado de red
4. Repository retorna datos cacheados inmediatamente si disponibles
5. Simultaneamente dispara request de red
6. En exito: actualiza cache y notifica provider
7. En fallo: datos stale permanecen visibles
8. Banner sutil: "Offline - mostrando datos guardados"

---

## Fases de Implementacion

### Fase 1: Fundacion (sin cambios visibles en UI)
1. Renombrar archivos a snake_case, actualizar imports
2. Crear estructura `core/`
3. Agregar paquetes a `pubspec.yaml`
4. Crear `env_config.dart`, `dio_client.dart`, `api_exceptions.dart`
5. Crear `secure_storage_service.dart`
6. Actualizar `main.dart` con `ProviderScope`

### Fase 2: Data Layer + Auth
1. Crear `usuario_model.dart` con freezed
2. Crear datasources (remote + local)
3. Crear `auth_repository.dart`
4. Crear `auth_state.dart` (freezed union)
5. Crear `auth_provider.dart`

### Fase 3: Router + Route Guards
1. Crear `app_router.dart` con GoRouter
2. Implementar redirect callback
3. Actualizar `main.dart` a `MaterialApp.router`
4. Remover todos los `Navigator.push` de pantallas

### Fase 4: Migracion de Pantallas
1. Mover LandingScreen, extraer widgets
2. Convertir LoginScreen a `ConsumerStatefulWidget`
3. Convertir RegistroScreen
4. Reemplazar `InputField` con `TextFormField` + validacion
5. Dividir Dashboard (729 lineas) en 7+ widget files

### Fase 5: Integracion de Datos en Dashboard
1. Crear modelos de datos dashboard (freezed)
2. Crear DashboardRepository con cache
3. Crear DashboardProvider
4. Reemplazar valores hardcoded con datos del provider

### Fase 6: Offline + Polish
1. Agregar ConnectivityProvider
2. Implementar cache en repositories
3. Banner offline
4. Expandir tema para cubrir todas las pantallas
