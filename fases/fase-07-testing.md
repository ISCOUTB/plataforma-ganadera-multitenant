# Fase 7: Testing

## Estado Actual

- `Backend/src/app.controller.spec.ts` -- 1 test unitario (Hello World). Funciona.
- `Backend/test/app.e2e-spec.ts` -- 1 test E2E que **FALLA** (requiere PostgreSQL vivo)
- `Frontend/test/widget_test.dart` -- Test default de Flutter. **ROTO** (referencia `MyApp` inexistente, la clase es `FarmLinkApp`)
- Sin CI pipeline, sin helpers, sin factories, sin mocks, sin fixtures

### Stack de testing
- Backend: Jest 30.0.0, `@nestjs/testing` 11.0.1, supertest 7.0.0, ts-jest 29.2.5
- Frontend: `flutter_test` (SDK), Dio 5.9.2

---

## Backend: Infraestructura de Testing

### Dependencias a agregar (devDependencies)

```bash
cd Backend && npm install -D @faker-js/faker
```

Opcional para E2E: `testcontainers` para PostgreSQL desechable en CI.

### Configuracion Jest (`package.json`)

Agregar:
```json
"coverageThreshold": {
  "global": { "branches": 80, "functions": 80, "lines": 80, "statements": 80 }
},
"coveragePathIgnorePatterns": ["node_modules", ".module.ts", ".entity.ts", "main.ts"]
```

### Scripts npm

```json
"test:unit": "jest --testPathPattern=\\.spec\\.ts$ --testPathIgnorePatterns=integration",
"test:integration": "jest --testPathPattern=\\.integration\\.spec\\.ts$",
"test:e2e": "jest --config ./test/jest-e2e.json",
"test:cov": "jest --coverage",
"test:ci": "jest --coverage --ci --forceExit --detectOpenHandles"
```

### Archivos Helper

| Archivo | Proposito |
|---------|-----------|
| `test/helpers/test-database.helper.ts` | Setup de BD de prueba (PostgreSQL `farmlink_test` o testcontainers) |
| `test/helpers/test-app.helper.ts` | Factory de app NestJS para E2E (con BD de test y ValidationPipe) |
| `test/helpers/fixtures/usuario.fixture.ts` | Factory de datos de prueba para Usuario |
| `test/helpers/fixtures/finca.fixture.ts` | Factory para Finca |
| `test/helpers/fixtures/animal.fixture.ts` | Factory para Animal |
| `test/helpers/fixtures/index.ts` | Barrel export |
| `test/setup.ts` | Setup global E2E (env vars, timeout) |

---

## Backend: Tests Unitarios por Modulo

### Patron: AAA (Arrange-Act-Assert)

```typescript
describe('ServiceName', () => {
  beforeEach(async () => { /* TestingModule + mock repository */ });

  describe('methodName', () => {
    it('should [comportamiento] when [condicion]', async () => {
      // Arrange: configurar mock returns
      // Act: llamar al metodo
      // Assert: verificar resultado + verificar calls al mock
    });
  });
});
```

### `usuarios.service.spec.ts` (8 test cases -- PRIORIDAD MAXIMA)

1. `registro()` -- happy path: email no existe, crea y guarda usuario
2. `registro()` -- email duplicado: lanza `ConflictException`
3. `registro()` -- pasa datos parciales correctamente a `repository.create`
4. `login()` -- happy path: usuario existe y password coincide
5. `login()` -- password incorrecto: lanza `UnauthorizedException`
6. `login()` -- usuario no encontrado: lanza `UnauthorizedException`
7. `login()` -- mensaje no revela si usuario existe o no
8. `findAll()` -- delega a `repository.find()`

**Mock:** `{ findOne: jest.fn(), create: jest.fn(), save: jest.fn(), find: jest.fn() }`

### `usuarios.controller.spec.ts` (3 test cases)

1. `registro()` -- llama `service.registro(body)`
2. `login()` -- llama `service.login(email, password)`
3. `findAll()` -- llama `service.findAll()`

### `alimentos.service.spec.ts` (2)
1. `findAll()` -- delega a `repository.find()`
2. `findAll()` -- retorna array vacio cuando no hay datos

### `alimentos.controller.spec.ts` (2)
1. `findAll()` -- delega a service
2. Retorna resultado del service

### Tests Skeleton (modulos vacios)
- `fincas.service.spec.ts` -- verifica que FincasService existe
- `animales.service.spec.ts` -- verifica instanciacion
- `potreros.service.spec.ts`
- `salud.service.spec.ts` + `salud.controller.spec.ts`
- `reproduccion.service.spec.ts` + `reproduccion.controller.spec.ts`
- `finanzas.service.spec.ts` + `finanzas.controller.spec.ts`
- `app.service.spec.ts` -- `getHello()` retorna `'Hello World!'`

---

## Backend: Tests E2E

### Estrategia de Base de Datos

**Opcion recomendada:** PostgreSQL `farmlink_test` en el mismo Docker.

```
beforeAll: crear app NestJS con BD real, synchronize: true
beforeEach: TRUNCATE TABLE ... CASCADE en todas las tablas
afterAll: cerrar app, cerrar conexion BD
```

### `test/usuarios.e2e-spec.ts` (8 test cases)

1. Registrar usuario nuevo → assert 201
2. Registrar email duplicado → assert 409
3. Login con credenciales validas → assert exito
4. Login con password incorrecto → assert 401
5. Login con email inexistente → assert 401
6. Listar usuarios → usuario registrado aparece
7. Verificar `tenant_id` almacenado correctamente
8. Verificar `creado_en` auto-generado

### `test/alimentos.e2e-spec.ts` (2)
1. `GET /alimentos` con tabla vacia retorna `[]`
2. Seed alimentos, luego `GET /alimentos` retorna datos

### Skeletons E2E (archivos vacios con test skipped)
- `test/fincas.e2e-spec.ts`
- `test/animales.e2e-spec.ts`
- `test/potreros.e2e-spec.ts`
- `test/salud.e2e-spec.ts`
- `test/reproduccion.e2e-spec.ts`
- `test/finanzas.e2e-spec.ts`

---

## Frontend: Tests

### Dependencias nuevas (`pubspec.yaml` dev_dependencies)

```yaml
mockito: ^5.4.0
build_runner: ^2.4.0
```

### Prerequisito de Refactorizacion

Las pantallas crean `ApiService()` localmente, haciendolas imposibles de testear. Solucion minima:

```dart
// Modificar constructores para aceptar ApiService opcional
class LoginScreen extends StatefulWidget {
  final ApiService? apiService;
  const LoginScreen({this.apiService});
}
// En state: _api = widget.apiService ?? ApiService();
```

### Archivos de Test Flutter

| Archivo | Tipo | Prioridad | Test Cases |
|---------|------|-----------|------------|
| `test/widget_test.dart` (reescribir) | Smoke | P0 | App renderiza sin error, LandingScreen es ruta inicial |
| `test/components/input_field_test.dart` | Widget | P0 | Renderiza hint, obscure, controller |
| `test/components/primary_button_test.dart` | Widget | P0 | Renderiza texto, onPressed, estilo |
| `test/screens/login_screen_test.dart` | Widget | P0 | Campos, botones, navegacion, API mock |
| `test/screens/registro_screen_test.dart` | Widget | P0 | Campos, validacion passwords match, terms |
| `test/screens/landing_screen_test.dart` | Widget | P1 | Titulo, hero, features, footer, navegacion |
| `test/screens/dashboard_screen_test.dart` | Widget | P1 | Metricas, pie chart, alertas, FAB |
| `test/services/api_service_test.dart` | Unit | P0 | login POST, registro POST, errores |
| `test/theme/colors_test.dart` | Unit | P2 | Constantes de color correctas |
| `test/theme/theme_test.dart` | Unit | P2 | Color primario, border radius |
| `test/helpers/test_app.dart` | Infra | P0 | Wrapper MaterialApp para tests |
| `test/helpers/mock_api_service.dart` | Infra | P0 | Mock de ApiService |
| `integration_test/app_test.dart` | Integration | P1 | Flujo completo: landing→login→dashboard |

---

## Coverage Targets

| Capa | Objetivo |
|------|----------|
| Backend services (unit) | 90% |
| Backend controllers (unit) | 85% |
| Backend E2E | 70% |
| Backend overall | 80% minimo |
| Frontend services | 90% |
| Frontend components | 85% |
| Frontend screens | 75% |
| Frontend overall | 80% target |

---

## CI Pipeline

### `.github/workflows/test.yml`

**Stage 1: Backend Unit + Integration**
- `ubuntu-latest`, Node 22
- `npm ci`, `npm run lint`, `npm run test:ci`

**Stage 2: Backend E2E**
- PostgreSQL 16 service container
- `npm run test:e2e`

**Stage 3: Frontend**
- Flutter stable
- `flutter analyze`, `flutter test --coverage`
- **PREREQUISITO:** Fix `Colors.dart` case-sensitivity antes

**Stage 4: Coverage Gate**
- Falla si cobertura < 80%

---

## Inventario Total: 43+ archivos de test

### Backend (31)
- 7 helpers/fixtures
- 13 unit tests (spec.ts)
- 2 integration tests
- 9 E2E tests (2 completos + 7 skeletons)

### Frontend (12)
- 2 helpers
- 1 smoke test
- 7 widget/unit tests
- 1 integration test
- 1 tema test

### CI (2)
- `.github/workflows/test.yml`
- `.github/workflows/pr.yml`
