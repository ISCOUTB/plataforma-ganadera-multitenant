# Fase 10: Integracion Frontend-Backend

## Estado Actual

### Backend
Solo 5 endpoints funcionan. 6 modulos tienen services vacios y controllers faltantes o vacios. No hay JWT, no hay CORS, no hay validacion.

### Frontend
4 pantallas. Login y Registro llaman API pero descartan la respuesta. Dashboard es 100% hardcoded (729 lineas). No hay state management, no hay route guards, no hay almacenamiento de token.

---

## Prerequisitos del Backend

Antes de cualquier integracion, el backend necesita:

1. **CORS:** `app.enableCors()` en `main.ts`
2. **JWT Auth:** Modulo completo (Fase 1)
3. **Controllers:** Crear para fincas, animales, potreros (Fase 3)
4. **Services:** Llenar todos los vacios (Fase 3)
5. **Modules:** `TypeOrmModule.forFeature([Entity])` donde falta
6. **DTOs:** Validacion en cada endpoint (Fase 6)
7. **Paginacion:** `skip/take` en list endpoints
8. **Dashboard endpoint:** `GET /dashboard?fincaId=` agregado
9. **FKs faltantes:** Salud->Animal, Finanza->Finca, Alimento->Finca (Fase 2)
10. **File upload:** Multer config para fotos de animales

---

## Contrato API Completo

### Autenticacion

| Metodo | Ruta | Retorna |
|--------|------|---------|
| POST | `/usuarios/login` | `{ access_token, refresh_token, user }` |
| POST | `/usuarios/registro` | `{ access_token, refresh_token, user }` |
| POST | `/usuarios/refresh` | `{ access_token, refresh_token }` |
| GET | `/usuarios/perfil` | Usuario actual (desde JWT) |

### Fincas
| Metodo | Ruta |
|--------|------|
| GET | `/fincas` |
| GET | `/fincas/:id` |
| POST | `/fincas` |
| PATCH | `/fincas/:id` |
| DELETE | `/fincas/:id` |
| GET | `/fincas/:id/dashboard` |

### Animales
| Metodo | Ruta |
|--------|------|
| GET | `/animales?fincaId=&page=&limit=&search=&genero=&raza=` |
| GET | `/animales/:id` |
| POST | `/animales` |
| PATCH | `/animales/:id` |
| DELETE | `/animales/:id` |
| POST | `/animales/:id/foto` |

### Potreros, Salud, Reproduccion, Finanzas, Alimentos
CRUD completo (ver Fase 3) + endpoints especiales:
- `GET /salud/alertas?fincaId=` -- proximas intervenciones
- `GET /reproduccion/gestaciones?fincaId=` -- gestaciones activas
- `GET /finanzas/resumen?fincaId=&mes=&anio=` -- resumen mensual

---

## Paquetes Flutter Nuevos

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0    # JWT tokens
  flutter_riverpod: ^2.6.1          # State management
  riverpod_annotation: ^2.6.1
  go_router: ^14.0.0                # Routing declarativo
  freezed_annotation: ^2.4.1        # Data models inmutables
  json_annotation: ^4.9.0           # JSON serialization
  image_picker: ^1.1.2              # Fotos de animales
  cached_network_image: ^3.4.1      # Imagenes cacheadas
  fl_chart: ^0.70.0                 # Graficos reales
  intl: ^0.19.0                     # Formato fecha/moneda
  infinite_scroll_pagination: ^4.1.0 # Listas paginadas
  connectivity_plus: ^6.0.0         # Estado de red
  flutter_dotenv: ^5.2.1            # Variables de entorno

dev_dependencies:
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  build_runner: ^2.4.13
  riverpod_generator: ^2.6.2
```

---

## Estructura de Directorios Nueva

```
lib/
  main.dart                       (refactorizar)
  config/
    env_config.dart
    app_constants.dart
  core/
    network/
      api_client.dart             # Dio singleton con interceptores
      auth_interceptor.dart       # Bearer token automatico
      error_interceptor.dart      # Mapeo DioException → AppException
      refresh_interceptor.dart    # Auto-refresh en 401
    storage/
      secure_storage_service.dart
      token_storage.dart
    error/
      app_exception.dart
  models/
    usuario.dart                  # freezed
    finca.dart
    animal.dart
    potrero.dart
    salud.dart
    reproduccion.dart
    finanza.dart
    alimento.dart
    dashboard_stats.dart
    paginated_response.dart
    auth_response.dart
  repositories/
    auth_repository.dart
    finca_repository.dart
    animal_repository.dart
    potrero_repository.dart
    salud_repository.dart
    reproduccion_repository.dart
    finanza_repository.dart
    alimento_repository.dart
    dashboard_repository.dart
  providers/
    auth_provider.dart
    finca_provider.dart
    animal_provider.dart
    potrero_provider.dart
    salud_provider.dart
    reproduccion_provider.dart
    finanza_provider.dart
    alimento_provider.dart
    dashboard_provider.dart
  router/
    app_router.dart
    route_names.dart
  screens/
    (pantallas existentes refactorizadas)
    fincas/
      Fincas_list_screen.dart
      Finca_create_screen.dart
      Finca_detail_screen.dart
    animales/
      Animales_list_screen.dart
      Animal_create_screen.dart
      Animal_detail_screen.dart
      Animal_edit_screen.dart
    potreros/
      Potreros_list_screen.dart
      Potrero_create_screen.dart
      Potrero_detail_screen.dart
    salud/
      Salud_list_screen.dart
      Salud_create_screen.dart
    reproduccion/
      Reproduccion_list_screen.dart
      Reproduccion_create_screen.dart
    finanzas/
      Finanzas_list_screen.dart
      Finanza_create_screen.dart
      Finanzas_resumen_screen.dart
    alimentos/
      Alimentos_list_screen.dart
      Alimento_create_screen.dart
    perfil/
      Perfil_screen.dart
  components/
    (existentes + nuevos)
    loading_indicator.dart
    error_view.dart
    empty_state_view.dart
    search_bar.dart
    filter_chip_bar.dart
    paginated_list_view.dart
    stat_card.dart
    confirmation_dialog.dart
    app_drawer.dart
    bottom_nav_bar.dart
```

---

## Core: API Client + Interceptores

### `api_client.dart`
- Singleton Dio con `BaseOptions(baseUrl: EnvConfig.apiBaseUrl)`
- Timeouts: connect 10s, receive 15s
- Interceptores: auth, error, refresh, logger (dev)

### `auth_interceptor.dart`
- `onRequest`: lee token de `TokenStorage`, agrega `Authorization: Bearer`
- Tambien agrega `X-Tenant-Id` del usuario almacenado

### `error_interceptor.dart`
- Mapea `DioException` a excepciones tipadas:
  - connectionTimeout → `NetworkException`
  - 401 → `AuthException` (trigger logout)
  - 404 → `NotFoundException`
  - 400 → `ValidationException`
  - 500+ → `ServerException`

### `refresh_interceptor.dart`
- `QueuedInterceptor` (serializa 401s concurrentes)
- En 401: intenta `POST /usuarios/refresh`
- Exito: guarda nuevos tokens, reintenta request original
- Fallo: limpia tokens, redirect a login

---

## Repositories (9)

Cada repository toma `ApiClient` como dependencia via Riverpod.

### `auth_repository.dart`
- `login(email, password)` → POST → guarda tokens → retorna Usuario
- `registro(email, password, nombre, tenantId)` → POST → guarda tokens
- `refresh(refreshToken)` → POST → nuevos tokens
- `getPerfil()` → GET → Usuario
- `logout()` → limpia tokens

### `animal_repository.dart`
- `getAnimales({fincaId, page, limit, search, genero, raza})` → GET paginado
- `getAnimal(id)` → GET con relaciones
- `createAnimal(data)` → POST
- `updateAnimal(id, data)` → PATCH
- `deleteAnimal(id)` → DELETE
- `uploadFoto(id, File)` → POST multipart/FormData

### Patron identico para: finca, potrero, salud, reproduccion, finanza, alimento, dashboard

---

## Providers Riverpod (9)

### Patron por dominio:
1. `repositoryProvider` -- `Provider<XRepository>`
2. `listProvider` -- `FutureProvider.family<PaginatedResponse<X>, XFilter>`
3. `detailProvider` -- `FutureProvider.family<X, id>`
4. `mutationProvider` -- `StateNotifierProvider` con `create()`, `update()`, `delete()`

### `auth_provider.dart`
- `AuthNotifier` extiende `AsyncNotifier<AuthState>`
- keepAlive: true
- login, registro, logout

### `dashboard_provider.dart`
- `FutureProvider.autoDispose<DashboardStats>`
- Lee `currentFincaProvider`

---

## Routing (GoRouter)

### Tabla de Rutas

| Ruta | Pantalla | Auth |
|------|----------|------|
| `/` | LandingScreen | No |
| `/login` | LoginScreen | No |
| `/registro` | RegistroScreen | No |
| `/dashboard` | DashboardScreen | Si |
| `/fincas` | FincasListScreen | Si |
| `/fincas/crear` | FincaCreateScreen | Si |
| `/fincas/:id` | FincaDetailScreen | Si |
| `/animales` | AnimalesListScreen | Si |
| `/animales/crear` | AnimalCreateScreen | Si |
| `/animales/:id` | AnimalDetailScreen | Si |
| `/animales/:id/editar` | AnimalEditScreen | Si |
| `/potreros` | PotrerosListScreen | Si |
| `/salud` | SaludListScreen | Si |
| `/reproduccion` | ReproduccionListScreen | Si |
| `/finanzas` | FinanzasListScreen | Si |
| `/finanzas/resumen` | FinanzasResumenScreen | Si |
| `/alimentos` | AlimentosListScreen | Si |
| `/perfil` | PerfilScreen | Si |

### Auth Guard
- Si authenticated y ruta `/login`|`/registro` → redirect `/dashboard`
- Si not authenticated y ruta protegida → redirect `/login`

---

## Refactorizacion de Pantallas Existentes

### LoginScreen
- Convertir a `ConsumerStatefulWidget`
- `ref.read(authProvider.notifier).login(email, password)`
- GoRouter maneja redirect post-login

### RegistroScreen
- Usar `authProvider.notifier.registro()`
- Remover `tenant_id: 'finca1'` hardcoded

### DashboardScreen (REFACTORIZACION MAYOR)
- Reemplazar cada valor hardcoded:
  - "El Paraiso" → `currentFinca.nombre_finca`
  - "247" → `stats.totalAnimales`
  - "96%" → `stats.porcentajeSalud`
  - "$24,500" → `stats.balance` (formateado con intl)
  - Pie chart → `fl_chart` con `stats.distribucionGenero`
- Wrap en `AsyncValue.when(data:, loading:, error:)`
- FAB menu conectado a rutas reales

---

## Pantallas Nuevas (30+)

### Patron List Screen
1. `ConsumerStatefulWidget`
2. Lee provider de lista del dominio
3. `AsyncValue.when(data:, loading:, error:)`
4. `PaginatedListView` con infinite scroll
5. `SearchBar` + `FilterChipBar`
6. Pull-to-refresh via `RefreshIndicator`
7. FAB → navega a create screen
8. Tap item → navega a detail screen

### Patron Create/Edit Screen
1. `ConsumerStatefulWidget` con `Form` + `GlobalKey<FormState>`
2. `TextFormField` por cada campo con validators
3. Dropdowns para enums
4. DatePicker para fechas
5. Submit → mutation provider → `context.pop()` + SnackBar

### Patron Detail Screen
1. `ConsumerWidget` con detail provider
2. `AsyncValue.when()`
3. Secciones con datos relacionados
4. AppBar: Edit, Delete (con confirmation dialog)

### Especificaciones por Dominio

**Fincas:** list (cards con nombre, ubicacion, conteo animales), create (6 campos), detail (con animales y potreros)

**Animales:** list (paginado, filtros genero/raza, foto thumbnail), create (12 campos + foto upload), detail (info + salud + reproduccion + alimentacion), edit

**Potreros:** list (cards con estado badge, capacidad), create (8 campos), detail (animales actuales)

**Salud:** list (badges tipo_intervencion color-coded), create (condicional: descripcion_enfermedad solo si tipo=enfermedad)

**Reproduccion:** list (iconos de estado embarazo), create (dropdowns de padre/madre)

**Finanzas:** list (verde ingreso, rojo gasto), create (segmented control tipo), **resumen** (graficos fl_chart por mes)

**Alimentos:** list, create, detail (con animales asignados)

**Perfil:** datos usuario, logout, toggle tema

---

## Componentes Reutilizables Nuevos

| Componente | Proposito |
|------------|-----------|
| `loading_indicator.dart` | CircularProgressIndicator centrado |
| `error_view.dart` | Icono error + mensaje + boton reintentar |
| `empty_state_view.dart` | Icono + mensaje + CTA ("Agregar animal") |
| `search_bar.dart` | TextField con debounce 300ms |
| `filter_chip_bar.dart` | Row scrollable de FilterChip |
| `paginated_list_view.dart` | Wrapper de infinite_scroll_pagination |
| `stat_card.dart` | Card de metrica (extraido de Dashboard) |
| `confirmation_dialog.dart` | AlertDialog Cancelar/Eliminar |
| `app_drawer.dart` | Navigation drawer para web/desktop |
| `bottom_nav_bar.dart` | Bottom nav para mobile |

---

## Navigation Shell

GoRouter `ShellRoute` wraps todas las pantallas autenticadas con:
- **< 768px**: `BottomNavigationBar` (Dashboard, Animales, Salud, Finanzas, Mas)
- **>= 768px**: `NavigationRail` o `Drawer` con 9 secciones

---

## Flujo de Datos Completo (Login → Dashboard)

```
1. Usuario ingresa email/password en LoginScreen
2. authProvider.login() → AuthRepository.login()
3. POST /usuarios/login via Dio (sin token aun)
4. Backend retorna { access_token, refresh_token, user }
5. TokenStorage.saveTokens(access, refresh)
6. authProvider state → AsyncData(user)
7. GoRouter redirect → /dashboard
8. DashboardScreen lee dashboardStatsProvider
9. DashboardRepository.getStats(currentFinca.pk_id_finca)
10. GET /dashboard?fincaId=X via Dio
11. auth_interceptor agrega Authorization: Bearer <token>
12. Backend retorna stats JSON
13. Parse a DashboardStats model
14. Provider emite AsyncData(stats)
15. Screen renderiza datos reales
```

### Token Expirado:
```
1. GET /animales?... retorna 401
2. refresh_interceptor captura 401
3. POST /usuarios/refresh con refresh_token
4. Si 200: guarda nuevos tokens, reintenta request original
5. Si falla: limpia tokens → authProvider null → redirect /login
```

---

## Riesgos

| Riesgo | Mitigacion |
|--------|-----------|
| Backend es mayormente shell (7/8 services vacios) | Implementar backend primero (Fases 1-3-6) |
| Sin JWT en backend | Toda la cadena de interceptores depende de esto |
| Contrasenas en texto plano | Migracion necesaria al agregar bcrypt |
| FKs faltantes en entidades | Dashboard aggregado y filtros dependen de relaciones |
| `Colors.dart` case-sensitivity | DEBE corregirse antes de agregar 30+ archivos |
| Agregar Riverpod es cambio arquitectonico mayor | Cada pantalla existente requiere refactorizacion |
