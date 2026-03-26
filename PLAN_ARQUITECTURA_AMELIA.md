# PLAN DE ARQUITECTURA — Proyecto (FarmLink)

**Documento**: Plan de Reestructuración Arquitectónica
**Versión**: 1.0
**Fecha**: 2026-03-26
**Autor**: Arquitecto de Software Senior / Lead de Ciberseguridad
**Clasificación**: Interno — Equipo de Desarrollo

---

## TABLA DE CONTENIDOS

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Diagnóstico Crítico — Hallazgo Fundacional](#2-diagnóstico-crítico--hallazgo-fundacional)
3. [Inventario de Riesgos y Vulnerabilidades](#3-inventario-de-riesgos-y-vulnerabilidades)
4. [Inventario de Bugs y Defectos Estructurales](#4-inventario-de-bugs-y-defectos-estructurales)
5. [Análisis de Discrepancias Frontend-Backend](#5-análisis-de-discrepancias-frontend-backend)
6. [Mapa de la Nueva Arquitectura Propuesta](#6-mapa-de-la-nueva-arquitectura-propuesta)
7. [Plan del Panel de Inspector y Detalle de Fincas](#7-plan-del-panel-de-inspector-y-detalle-de-fincas)
8. [Cronograma de Fases de Implementación](#8-cronograma-de-fases-de-implementación)
9. [Matriz de Dependencias entre Fases](#9-matriz-de-dependencias-entre-fases)
10. [Criterios de Aceptación por Fase](#10-criterios-de-aceptación-por-fase)
11. [Apéndice — Archivos Auditados](#11-apéndice--archivos-auditados)

---

## 1. RESUMEN EJECUTIVO

El proyecto Amelia (FarmLink) presenta una **crisis de identidad arquitectónica**: coexisten dos diseños mutuamente excluyentes en el mismo repositorio. Uno basado en Prisma/JWT que fue documentado pero nunca construido, y otro basado en TypeORM que es el código real pero está severamente incompleto. De 9 módulos de dominio, solo 1 tiene lógica de negocio funcional. El frontend tiene 4 pantallas, de las cuales el Dashboard (la más importante) opera con datos 100% hardcodeados.

Se identificaron **3 vulnerabilidades de severidad CRÍTICA**, **4 de severidad ALTA**, **8 de severidad MEDIA** y **6 de severidad BAJA**. Las críticas incluyen contraseñas almacenadas en texto plano, ausencia total de autenticación/autorización, y falta de aislamiento multitenant que permitiría a cualquier usuario acceder a datos de cualquier finca.

Este documento presenta la hoja de ruta para remediar estos hallazgos en **6 fases secuenciales** con dependencias claras, criterios de éxito verificables y un enfoque especial en el Panel de Inspector y la vista de detalle de Fincas.

---

## 2. DIAGNÓSTICO CRÍTICO — HALLAZGO FUNDACIONAL

### 2.1 Dos Arquitecturas en Conflicto

El repositorio contiene dos diseños que no pueden coexistir:

| Aspecto | Arq. A (Fantasma — Prisma) | Arq. B (Real — TypeORM) |
|---------|---------------------------|------------------------|
| **ORM** | Prisma 5.8.0 | TypeORM 0.3.28 |
| **Ubicación** | `root/package.json`, `Backend/prisma/schema.prisma` | `Backend/package.json`, `Backend/src/**/*.entity.ts` |
| **Rutas API** | `/api/v1/auth/login`, `/api/v1/tenants` | `/usuarios/login`, `/usuarios/registro` |
| **Autenticación** | JWT + bcrypt + refresh tokens | Comparación de texto plano |
| **Modelo Tenant** | Tabla `Tenant` con UUID, cascada en FK | String `tenant_id` sin FK |
| **Swagger** | Configurado con `@nestjs/swagger` | No configurado |
| **Estado** | Documentado (TESTING.md, TROUBLESHOOTING.md) pero **código inexistente** | Código parcial, **la implementación real** |
| **NestJS version** | ^10.3.0 | ^11.0.1 |

**Archivo raíz `package.json`** (`name: "farmlink-backend"`) declara dependencias que nunca se instalaron en `Backend/`: `@nestjs/jwt`, `@nestjs/passport`, `bcrypt`, `@prisma/client`, `class-validator`, `@nestjs/swagger`. El verdadero `Backend/package.json` (`name: "vac-app"`) no incluye ninguna de estas.

**Veredicto**: La Arquitectura A es código muerto documental. Todo el trabajo debe partir de la Arquitectura B. Los artefactos de la Arq. A deben eliminarse para evitar confusión futura.

### 2.2 Estado Real de Completitud del Backend

```
Módulos con lógica de negocio:  1 de 9  (11%)
Módulos con controller vacío:   3 de 9  (33%)
Módulos sin controller:         4 de 9  (44%)
Módulos solo con entidad:       1 de 9  (11%)
Endpoints funcionales:          5 total
```

| Módulo | Entity | Controller | Service | CRUD | Estado |
|--------|--------|------------|---------|------|--------|
| `usuarios` | `usuario.entity.ts` | 3 endpoints | registro/login/findAll | Parcial | **Solo módulo funcional** |
| `alimentos` | `alimento.entity.ts` | 1 endpoint GET | findAll | Solo lectura | Mínimo |
| `fincas` | `finca.entity.ts` | **NO EXISTE** | Clase vacía | Ninguno | Cascarón |
| `animales` | `animal.entity.ts` | **NO EXISTE** | Clase vacía | Ninguno | Cascarón |
| `potreros` | `potrero.entity.ts` | **NO EXISTE** | Clase vacía | Ninguno | Cascarón |
| `salud` | `salud.entity.ts` | Clase vacía | Clase vacía | Ninguno | Cascarón |
| `reproduccion` | `reproduccion.entity.ts` | Clase vacía | Clase vacía | Ninguno | Cascarón |
| `finanzas` | `finanza.entity.ts` | Clase vacía | Clase vacía | Ninguno | Cascarón |
| `bovino-alimento` | `bovino-alimento.entity.ts` | **NO EXISTE** | **NO EXISTE** | Ninguno | Solo entidad |

### 2.3 Estado Real del Frontend

```
Pantallas totales:         4
Conectadas al backend:     2 (Login, Registro)
Con datos reales:          0
Con datos hardcodeados:    1 (Dashboard — 100% mock)
Sin funcionalidad:         1 (Landing — solo navegación)
```

---

## 3. INVENTARIO DE RIESGOS Y VULNERABILIDADES

### SEVERIDAD CRÍTICA (Explotables inmediatamente)

#### CVE-INT-001: Contraseñas en Texto Plano
- **Archivo**: `Backend/src/usuarios/usuarios.service.ts`, línea 22
- **Código vulnerable**:
  ```
  if (!usuario || usuario.password !== password)
  ```
- **Impacto**: Compromiso total de cuentas en caso de breach de base de datos. Violación de OWASP A02:2021 (Cryptographic Failures).
- **Vector de ataque**: Acceso a la BD (backup, SQL injection, acceso físico) expone TODAS las contraseñas de TODOS los usuarios.
- **Dato agravante**: La entidad `Usuario` retorna el campo `password` en las respuestas JSON. `GET /usuarios` expone las contraseñas de todos los usuarios a cualquiera.
- **Remediación**: Implementar bcrypt con salt factor >= 12. Excluir campo password de todas las respuestas con `@Exclude()` de class-transformer.

#### CVE-INT-002: Ausencia Total de Autenticación/Autorización
- **Archivos afectados**: Todos los controllers (`*/*.controller.ts`)
- **Impacto**: Cualquier actor puede ejecutar cualquier operación en cualquier endpoint sin credenciales.
- **Detalle**: No existe:
  - Ningún guard (`@UseGuards`)
  - Ninguna estrategia JWT/Passport
  - Ningún middleware de autenticación
  - Ningún decorador de roles (`@Roles`)
  - Ningún interceptor de autorización
- **Vector de ataque**: `curl http://host:3000/usuarios` retorna toda la tabla de usuarios incluyendo contraseñas.
- **Remediación**: Implementar módulo Auth completo (JWT + Passport + Guards + Role decorators).

#### CVE-INT-003: Ausencia de Aislamiento Multitenant
- **Archivos afectados**: Todas las entidades y servicios
- **Impacto**: Fuga de datos entre tenants. Usuario de Finca A puede ver/modificar datos de Finca B.
- **Detalle**:
  - `Usuario.tenant_id` es un string sin FK (no apunta a ninguna tabla)
  - Ningún service filtra queries por tenant
  - Ningún guard valida pertenencia a tenant
  - Frontend hardcodea `tenant_id: 'finca1'` para todos los registros
  - Las entidades `Salud`, `Finanza`, `Alimento` no tienen columna de tenant
- **Vector de ataque**: Cualquier request sin filtro de tenant retorna datos de todas las fincas.
- **Remediación**: FK real a Finca, TenantGuard middleware, filtrado automático en todas las queries.

---

### SEVERIDAD ALTA

#### RISK-001: Secrets Hardcodeados en Docker Compose
- **Archivo**: `docker-compose.yml`, líneas 7-8, 35-36
- **Detalle**: Credenciales de PostgreSQL (`postgres/postgres`) y JWT secrets con defaults débiles en texto plano, commiteados al repositorio.
- **Agravante**: El `.gitignore` raíz NO excluye archivos `.env` — solo el `Backend/.gitignore` lo hace.
- **Remediación**: Variables de entorno externalizadas, `.env.example` sin valores reales, validar que `.gitignore` raíz excluya `.env*`.

#### RISK-002: Sin Validación de Entrada (Input Validation)
- **Archivo**: `Backend/src/usuarios/usuarios.controller.ts`, línea 9
- **Código**: `registro(@Body() body: any)` — acepta cualquier payload sin validación.
- **Impacto**: Mass assignment, inyección de campos no esperados, datos corruptos.
- **Detalle adicional**: No hay `ValidationPipe` global configurado. No existen DTOs con decoradores `class-validator`. Un atacante podría enviar `{ "rol": "superadmin", "tenant_id": "otroTenant" }` y escalar privilegios.
- **Remediación**: DTOs con class-validator + ValidationPipe global con `whitelist: true`.

#### RISK-003: CORS No Configurado
- **Archivo**: `Backend/src/main.ts`
- **Impacto**: En producción, el navegador bloquearía peticiones cross-origin del frontend Flutter Web. En desarrollo sin CORS, cualquier origen puede hacer requests al backend.
- **Remediación**: `app.enableCors({ origin: [allowedOrigins] })` con whitelist explícita.

#### RISK-004: `synchronize: true` en TypeORM
- **Archivo**: `Backend/src/app.module.ts`, línea 41
- **Impacto**: TypeORM modifica el schema de la BD automáticamente al iniciar. En producción, un cambio accidental en una entidad puede borrar columnas, alterar tipos de dato, o destruir datos.
- **Remediación**: Desactivar synchronize, implementar sistema de migraciones con `typeorm migration:generate`.

---

### SEVERIDAD MEDIA

| ID | Hallazgo | Archivo | Impacto |
|----|----------|---------|---------|
| MED-001 | `Animal.reproducciones: any` sin decorador TypeORM | `animal.entity.ts:58` | Propiedad flotante que causa errores silenciosos en relaciones |
| MED-002 | Sin paginación en queries | `alimentos.service.ts`, `usuarios.service.ts` | DoS por memory exhaustion con tablas grandes |
| MED-003 | Sin rate limiting | `main.ts` | Ataques de fuerza bruta contra login |
| MED-004 | Sin logging ni audit trail | Todo el backend | Imposibilidad de detectar o investigar ataques |
| MED-005 | Sin headers de seguridad | `main.ts` | Missing CSP, X-Frame-Options, HSTS |
| MED-006 | Inconsistencia case en filename | `Frontend/lib/theme/Colors.dart` vs `colors.dart` | Fallo en Linux/CI (case-sensitive FS) |
| MED-007 | Rol default `'admin'` en Usuario | `usuario.entity.ts:21` | Cada usuario nuevo obtiene privilegios de admin por defecto |
| MED-008 | PKs manuales tipo string (length 15) | Finca, Potrero, Alimento, Finanza, Reproduccion | Colisiones, no auto-generados, impredecibles |

---

### SEVERIDAD BAJA

| ID | Hallazgo | Detalle |
|----|----------|---------|
| LOW-001 | Tests inexistentes | Solo 2 archivos de test con "Hello World" |
| LOW-002 | `Backend/package.json` name: `"vac-app"` | Nombre no coincide con el proyecto |
| LOW-003 | `TypeOrmModule.forFeature()` duplicado en AppModule | Línea 46-49 registra entidades que ya están en `forRoot()` |
| LOW-004 | Import de `flutter/services.dart` no utilizado | `Dashboard_screen.dart:2` |
| LOW-005 | Dockerfile eliminado pero referenciado | `docker-compose.yml:24` — servicio backend no puede construirse |
| LOW-006 | `setup.sh` ejecuta Prisma en vez de TypeORM | Script huérfano de la arquitectura fantasma |

---

## 4. INVENTARIO DE BUGS Y DEFECTOS ESTRUCTURALES

### 4.1 Bugs en Backend

| # | Bug | Ubicación | Tipo | Efecto |
|---|-----|-----------|------|--------|
| B-01 | `reproducciones: any` sin decorador `@OneToMany` | `animal.entity.ts:58` | Runtime | TypeORM ignora la propiedad; `Reproduccion.bovino` apunta a una relación unidireccional rota |
| B-02 | `GET /usuarios` retorna campo `password` en respuesta JSON | `usuarios.service.ts:28` | Seguridad + Lógica | Fuga directa de contraseñas |
| B-03 | `POST /usuarios/registro` acepta `body: any` | `usuarios.controller.ts:9` | Validación | Mass assignment — puede inyectar `rol`, `tenant_id`, `id` |
| B-04 | `TypeOrmModule.forFeature()` en `AppModule` sin consumer | `app.module.ts:46-49` | Configuración | Repositories inyectados globalmente sin propósito |
| B-05 | `Reproduccion.fk_id_padre` y `fk_id_madre` son strings, no FKs reales | `reproduccion.entity.ts:9-12` | Integridad | No hay constraint referencial — pueden apuntar a IDs que no existen |
| B-06 | Salud no tiene FK a Animal | `salud.entity.ts` | Integridad | Un registro de salud no está vinculado a ningún animal |
| B-07 | Finanza no tiene FK a Finca | `finanza.entity.ts` | Integridad | Un registro financiero flota sin asociación a una finca |
| B-08 | Alimento no tiene FK a Finca | `alimento.entity.ts` | Integridad | Un alimento no pertenece a ninguna finca |
| B-09 | Dashboard referencia `"assets/logo.png"` (minúscula) pero archivo es `"assets/Logo.png"` | `Dashboard_screen.dart:90` | Runtime | Falla en Linux/Android (case-sensitive) |
| B-10 | Login no retorna token ni sesión | `usuarios.service.ts:20-25` | Lógica | Login exitoso retorna el objeto Usuario completo (con password) pero sin mecanismo de sesión |

### 4.2 Bugs en Frontend

| # | Bug | Ubicación | Tipo | Efecto |
|---|-----|-----------|------|--------|
| BF-01 | Respuesta de login descartada | `Login_screen.dart:24` | Lógica | `await _api.login(...)` se ejecuta pero el resultado no se almacena |
| BF-02 | Tenant hardcodeado `'finca1'` | `api_service.dart:20` | Lógica | Todos los usuarios se registran bajo la misma finca |
| BF-03 | Dashboard accesible sin autenticación | `Dashboard_screen.dart` | Seguridad | Navegación directa sin verificar estado de auth |
| BF-04 | FAB menu items sin funcionalidad | `Dashboard_screen.dart:647-651` | UX | "Agregar animal", "Nuevo tratamiento", "Registrar transacción" no hacen nada |
| BF-05 | LayoutBuilder en Landing nunca recibe `maxWidth > 700` | `Landing_screen.dart:44` | Layout | El `LayoutBuilder` está dentro de un `Row` hijo, su constraint es siempre el del padre, no la pantalla |
| BF-06 | No hay manejo de estado offline | Todo el frontend | UX | Sin conexión la app muestra pantalla blanca |
| BF-07 | Sin dispose de TextEditingControllers | `Login_screen.dart`, `Registro_screen.dart` | Memory | Memory leak por controllers no disposed |

---

## 5. ANÁLISIS DE DISCREPANCIAS FRONTEND-BACKEND

### 5.1 Contrato API Roto

| Frontend espera | Backend provee | Estado |
|-----------------|---------------|--------|
| `POST /usuarios/login` retorne token JWT | Retorna objeto `Usuario` con `password` visible | **ROTO** |
| Token almacenado para requests autenticados | No genera tokens | **INEXISTENTE** |
| Dashboard reciba métricas reales | No hay endpoints de métricas | **INEXISTENTE** |
| Lista de animales por finca | No hay endpoint `/animales` | **INEXISTENTE** |
| Datos de salud | No hay endpoint `/salud` funcional | **INEXISTENTE** |
| Resumen financiero | No hay endpoint `/finanzas` funcional | **INEXISTENTE** |
| Eventos próximos | No hay endpoint de eventos | **INEXISTENTE** |
| Distribución del hato | No hay endpoint de estadísticas | **INEXISTENTE** |

### 5.2 Modelo de Datos Incompatible

El frontend Dashboard maneja conceptos que no existen en las entidades del backend:

- **"Estado de salud: 96%"** — No hay campo calculado de salud porcentual
- **"Nacimientos recientes: 8"** — No hay query de reproducciones recientes
- **"Balance mensual: $24,500"** — No hay agregación de finanzas por período
- **"3 animales con control sanitario pendiente"** — No hay concepto de "pendiente" en la entidad Salud
- **"Vacunación lote B"** — No hay concepto de "lote" en ninguna entidad

### 5.3 Flujo de Autenticación Desconectado

```
ACTUAL (roto):
  Flutter Login → POST /usuarios/login → Backend retorna {id, email, password, ...}
  Flutter ignora respuesta → pushReplacement a Dashboard → Dashboard muestra datos fake

REQUERIDO:
  Flutter Login → POST /auth/login → Backend valida bcrypt, genera JWT
  Flutter almacena token → Dashboard carga datos con Authorization header
  Backend valida JWT en cada request → filtra datos por tenant del token
```

---

## 6. MAPA DE LA NUEVA ARQUITECTURA PROPUESTA

### 6.1 Arquitectura de Capas (Backend)

```
┌──────────────────────────────────────────────────────────────────┐
│                         CAPA DE TRANSPORTE                       │
│  main.ts: CORS + ValidationPipe + GlobalPrefix(/api/v1)         │
│  + Helmet (headers) + Throttler (rate limit) + Swagger           │
├──────────────────────────────────────────────────────────────────┤
│                       CAPA DE AUTENTICACIÓN                      │
│  AuthModule: JwtStrategy + LocalStrategy + JwtAuthGuard          │
│  + RefreshTokenGuard + RolesGuard + TenantGuard                  │
├──────────────────────────────────────────────────────────────────┤
│                     CAPA DE CONTROLADORES                        │
│  AuthController | FincasController | AnimalesController          │
│  PotrerosController | SaludController | ReproduccionController   │
│  FinanzasController | AlimentosController | UsuariosController    │
│  (Todos protegidos por JwtAuthGuard + TenantGuard)               │
├──────────────────────────────────────────────────────────────────┤
│                       CAPA DE VALIDACIÓN                         │
│  DTOs con class-validator para cada operación CRUD               │
│  CreateAnimalDto | UpdateAnimalDto | QueryAnimalDto | etc.       │
│  ValidationPipe(whitelist:true, transform:true, forbidNonWhitelisted:true) │
├──────────────────────────────────────────────────────────────────┤
│                     CAPA DE SERVICIOS                            │
│  Lógica de negocio + filtrado automático por tenant_id           │
│  Paginación (skip/take) + ordenamiento + búsqueda               │
├──────────────────────────────────────────────────────────────────┤
│                     CAPA DE PERSISTENCIA                         │
│  TypeORM Repositories + Migraciones (NO synchronize)             │
│  Entidades con FKs completas + Indices + Constraints             │
├──────────────────────────────────────────────────────────────────┤
│                       BASE DE DATOS                              │
│  PostgreSQL 16 — Schema único, aislamiento por FK a Finca        │
└──────────────────────────────────────────────────────────────────┘
```

### 6.2 Nuevo Grafo de Entidades (con FKs corregidas)

```
                        ┌──────────┐
                        │  FINCA   │  (Tenant raíz)
                        │ pk_id    │
                        └────┬─────┘
              ┌──────────────┼──────────────┬──────────────┐
              │              │              │              │
         ┌────▼────┐   ┌────▼────┐   ┌────▼────┐   ┌────▼────┐
         │ USUARIO │   │ POTRERO │   │ALIMENTO │   │ FINANZA │
         │tenant_id│   │fk_finca │   │fk_finca │   │fk_finca │
         └─────────┘   └────┬────┘   └────┬────┘   └─────────┘
                            │              │
                       ┌────▼────┐         │
                       │ ANIMAL  │         │
                       │fk_finca │         │
                       │fk_potrero│        │
                       └──┬───┬──┘         │
                          │   │            │
              ┌───────────┘   └──────┐     │
              │                      │     │
         ┌────▼────┐          ┌─────▼─────▼──┐
         │  SALUD  │          │BOVINO_ALIMENTO│
         │fk_animal│          │fk_animal      │
         │fk_finca │          │fk_alimento    │
         └─────────┘          └───────────────┘
              │
         ┌────▼────────┐
         │REPRODUCCION │
         │fk_bovino    │
         │fk_padre(FK) │
         │fk_madre(FK) │
         └─────────────┘
```

**Cambios respecto al estado actual**:
- `Salud` gana FK a `Animal` y FK a `Finca` (actualmente isla sin relaciones)
- `Finanza` gana FK a `Finca` (actualmente isla)
- `Alimento` gana FK a `Finca` (actualmente isla)
- `Usuario.tenant_id` se convierte en FK real a `Finca.pk_id_finca`
- `Reproduccion.fk_id_padre` y `fk_id_madre` se convierten en FKs reales a `Animal`
- `Animal.reproducciones: any` se reemplaza con `@OneToMany` tipado

### 6.3 Arquitectura Frontend Propuesta

```
┌──────────────────────────────────────────────────────────────┐
│                        ENTRY POINT                            │
│  main.dart → MultiProvider → GoRouter → MaterialApp           │
├──────────────────────────────────────────────────────────────┤
│                     CAPA DE ROUTING                           │
│  GoRouter con redirect guards:                                │
│  /  → LandingScreen (público)                                 │
│  /login → LoginScreen (público)                               │
│  /registro → RegistroScreen (público)                         │
│  /dashboard → DashboardScreen (requiere auth)                 │
│  /animales → AnimalesListScreen (requiere auth)               │
│  /animales/:id → AnimalDetailScreen (requiere auth)           │
│  /potreros → PotrerosScreen (requiere auth)                   │
│  /salud → SaludScreen (requiere auth)                         │
│  /finanzas → FinanzasScreen (requiere auth)                   │
│  /finca/inspector → InspectorPanel (requiere auth + rol)      │
├──────────────────────────────────────────────────────────────┤
│                  CAPA DE ESTADO (Provider)                     │
│  AuthProvider → token, usuario actual, estado de sesión        │
│  FincaProvider → finca activa, cambio de contexto              │
│  AnimalesProvider → lista, filtros, paginación                 │
│  DashboardProvider → métricas agregadas                        │
├──────────────────────────────────────────────────────────────┤
│                  CAPA DE SERVICIOS                             │
│  ApiService + Dio Interceptors:                                │
│    → AuthInterceptor (inyecta Bearer token)                   │
│    → TenantInterceptor (inyecta X-Tenant-Id header)           │
│    → RetryInterceptor (refresh token on 401)                  │
│    → ErrorInterceptor (mapea errores a mensajes legibles)     │
│  AuthService → login, register, refresh, logout, isLogged     │
│  SecureStorage → almacenamiento cifrado de tokens              │
├──────────────────────────────────────────────────────────────┤
│                  CAPA DE MODELOS                               │
│  User, Finca, Animal, Potrero, Alimento, Salud,               │
│  Reproduccion, Finanza, AuthResponse, PaginatedResponse        │
│  (con fromJson/toJson factories)                               │
├──────────────────────────────────────────────────────────────┤
│                  CAPA DE COMPONENTES UI                        │
│  Componentes atómicos: InputField, PrimaryButton, MetricCard   │
│  Componentes compuestos: AnimalCard, EventItem, FinanceChart   │
│  Layouts: InspectorLayout, CompactDataTable, FilterBar         │
└──────────────────────────────────────────────────────────────┘
```

---

## 7. PLAN DEL PANEL DE INSPECTOR Y DETALLE DE FINCAS

### 7.1 Concepto del Panel de Inspector

El Panel de Inspector es una vista de administración avanzada que permite al usuario gestionar su finca con una UI compacta, densa en información y eficiente para uso profesional.

**Principios de diseño**:
- **Densidad informativa**: Más datos visibles sin scroll, tablas compactas con filas condensadas
- **Split-panel layout**: Panel lateral izquierdo (lista/navegación) + Panel derecho (detalle)
- **Acciones contextuales**: Botones de acción visibles según el contexto seleccionado
- **Filtros persistentes**: Barra de filtros que no desaparece al hacer scroll
- **Responsive**: En mobile, colapsar a navegación por tabs; en desktop/tablet, mantener split-panel

### 7.2 Layout del Inspector — Detalle de Fincas

```
┌─────────────────────────────────────────────────────────────────────┐
│ [Logo] FarmLink    Finca: El Paraíso ▼    [Notif] [Config] [User] │
├───────────────┬─────────────────────────────────────────────────────┤
│               │                                                     │
│  NAVEGACIÓN   │              ÁREA DE CONTENIDO                      │
│               │                                                     │
│  ▸ Dashboard  │  ┌─ RESUMEN DE FINCA ──────────────────────────┐   │
│  ▸ Animales   │  │                                              │   │
│  ▸ Potreros   │  │  Nombre: El Paraíso    Propietario: J.López │   │
│  ▸ Salud      │  │  Ubicación: Turbaco    Área: 150 ha         │   │
│  ▸ Alimentación│ │  Animales: 247         Potreros: 8          │   │
│  ▸ Reproducción│ │                                              │   │
│  ▸ Finanzas   │  └─────────────────────────────────────────────┘   │
│               │                                                     │
│  ─────────    │  ┌─ MÉTRICAS RÁPIDAS ──────────────────────────┐   │
│  ACCIONES     │  │  [247 Total] [8 Nacim.] [96% Salud] [$24K] │   │
│  + Animal     │  └─────────────────────────────────────────────┘   │
│  + Tratamiento│                                                     │
│  + Transacción│  ┌─ TABS ──────────────────────────────────────┐   │
│               │  │ [Animales] [Potreros] [Eventos] [Finanzas]  │   │
│  ─────────    │  ├─────────────────────────────────────────────┤   │
│  FILTROS      │  │  DataTable compacta con datos del tab       │   │
│  Estado: ▼    │  │  activo, paginación, búsqueda, y acciones   │   │
│  Potrero: ▼   │  │  inline por fila.                           │   │
│  Raza: ▼      │  │                                              │   │
│               │  │  [< 1 2 3 ... 12 >]  Mostrando 1-20 de 247 │   │
│               │  └─────────────────────────────────────────────┘   │
├───────────────┴─────────────────────────────────────────────────────┤
│  Status: Conectado | Última sync: hace 2 min | v1.0.0              │
└─────────────────────────────────────────────────────────────────────┘
```

### 7.3 Componentes Requeridos para el Inspector

| Componente | Función | Prioridad |
|------------|---------|-----------|
| `InspectorLayout` | Shell con sidebar + content area + status bar | Alta |
| `CompactDataTable` | Tabla con filas densas, sort por columna, selección | Alta |
| `FilterBar` | Dropdowns de filtro que se aplican a la tabla activa | Alta |
| `MetricStrip` | Fila horizontal de 4 métricas con iconos | Alta |
| `FincaHeader` | Resumen compacto de la finca activa | Alta |
| `QuickActionMenu` | Lista de acciones rápidas en sidebar | Media |
| `TabSection` | Tabs que cambian el contenido de la tabla | Media |
| `InlineRowActions` | Botones edit/delete/view dentro de cada fila | Media |
| `SearchBar` | Búsqueda dentro de la tabla activa | Media |
| `PaginationBar` | Controles prev/next/page con contador | Media |
| `StatusFooter` | Barra de estado con conexión y sync info | Baja |

### 7.4 Vista de Detalle de Finca (Piles/Hincas)

Al seleccionar una finca desde el inspector, se muestra una vista expandida:

```
┌─ DETALLE: EL PARAÍSO ─────────────────────────────────────────┐
│                                                                 │
│  INFORMACIÓN GENERAL                     MAPA DE POTREROS      │
│  ┌─────────────────────┐                ┌──────────────────┐   │
│  │ Nombre: El Paraíso  │                │                  │   │
│  │ ID: FNC-001         │                │  [Potrero A: 12] │   │
│  │ Propietario: López  │                │  [Potrero B: 28] │   │
│  │ Ubicación: Turbaco  │                │  [Potrero C: 15] │   │
│  │ Área: 150 ha        │                │  [Rotación: -->] │   │
│  │ Registro: 2024-01   │                │                  │   │
│  └─────────────────────┘                └──────────────────┘   │
│                                                                 │
│  DISTRIBUCIÓN DEL HATO          ALERTAS ACTIVAS                │
│  ┌──────────────────┐          ┌────────────────────────────┐  │
│  │  Vacas:    142    │          │ ! 3 controles pendientes   │  │
│  │  Terneros:  68    │          │ ! Rotación Potrero B vence │  │
│  │  Toros:     37    │          │ ! Vacunación lote C        │  │
│  │  [====  donut  ]  │          └────────────────────────────┘  │
│  └──────────────────┘                                           │
│                                                                 │
│  RESUMEN FINANCIERO (Mes actual)                                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Ingresos: $87,340   Egresos: $62,840   Balance: +$24,500│  │
│  │  [████████████████░░░░░░░░]  72% del presupuesto          │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  [Editar Finca]  [Exportar Reporte]  [Ver Historial]           │
└─────────────────────────────────────────────────────────────────┘
```

### 7.5 Requisitos de Backend para el Inspector

Los endpoints requeridos que no existen actualmente:

| Endpoint | Propósito | Datos |
|----------|-----------|-------|
| `GET /api/v1/fincas/:id/resumen` | Métricas agregadas de la finca | Total animales, nacimientos mes, % salud, balance |
| `GET /api/v1/fincas/:id/distribucion` | Distribución del hato | Conteo por tipo (vaca/ternero/toro) |
| `GET /api/v1/fincas/:id/alertas` | Alertas activas | Controles pendientes, rotaciones vencidas |
| `GET /api/v1/fincas/:id/finanzas/resumen` | Resumen financiero mensual | Ingresos, egresos, balance, % presupuesto |
| `GET /api/v1/animales?page=1&limit=20&potrero=X` | Lista paginada con filtros | Animales con paginación y filtrado |
| `GET /api/v1/potreros?finca=X` | Potreros con conteo de animales | Lista con ocupación actual |

---

## 8. CRONOGRAMA DE FASES DE IMPLEMENTACIÓN

### FASE 0 — Saneamiento del Repositorio

**Objetivo**: Eliminar la Arquitectura Fantasma y establecer una base limpia.
**Duración estimada**: 2-3 horas
**Dependencias**: Ninguna (primera fase)
**Riesgo**: Bajo

**Tareas**:

| # | Tarea | Archivos | Acción |
|---|-------|----------|--------|
| 0.1 | Eliminar schema Prisma | `Backend/prisma/schema.prisma`, `Backend/prisma/schema.prisma.bak` | DELETE |
| 0.2 | Eliminar directorio prisma | `Backend/prisma/` | DELETE |
| 0.3 | Eliminar package.json raíz | `/package.json` | DELETE |
| 0.4 | Eliminar tsconfig.json raíz | `/tsconfig.json` | DELETE |
| 0.5 | Eliminar nest-cli.json raíz | `/nest-cli.json` | DELETE |
| 0.6 | Eliminar setup.sh | `/setup.sh` | DELETE |
| 0.7 | Marcar TESTING.md como aspiracional | `/TESTING.md` | EDIT: agregar banner de advertencia |
| 0.8 | Marcar TROUBLESHOOTING.md como aspiracional | `/TROUBLESHOOTING.md` | EDIT: agregar banner de advertencia |
| 0.9 | Corregir docker-compose.yml | `/docker-compose.yml` | EDIT: eliminar servicio `backend` (sin Dockerfile) |
| 0.10 | Corregir .gitignore raíz | `/.gitignore` | EDIT: agregar `.env*`, `node_modules/`, `dist/`, `*.log` |
| 0.11 | Corregir nombre en package.json | `Backend/package.json` | EDIT: `"vac-app"` → `"farmlink-backend"` |
| 0.12 | Crear .env.example | `Backend/.env.example` | CREATE |
| 0.13 | Habilitar CORS | `Backend/src/main.ts` | EDIT: agregar `app.enableCors()` |
| 0.14 | Renombrar Colors.dart | `Frontend/lib/theme/Colors.dart` → `colors.dart` | RENAME |
| 0.15 | Eliminar TypeOrmModule.forFeature duplicado | `Backend/src/app.module.ts:46-49` | EDIT: remover bloque |
| 0.16 | Eliminar import no usado | `Frontend/lib/screens/Dashboard_screen.dart:2` | EDIT: remover `flutter/services.dart` |

**Criterio de éxito**: `npm run start:dev` arranca sin warnings por archivos fantasma. `flutter analyze` pasa sin errores.

---

### FASE 1 — Fortificación de Seguridad

**Objetivo**: Cerrar las 3 vulnerabilidades CRÍTICAS y las 4 de severidad ALTA.
**Duración estimada**: 5-6 horas
**Dependencias**: FASE 0 completada
**Riesgo**: Alto (cambios en schema de auth)

**Tareas**:

| # | Tarea | Tipo |
|---|-------|------|
| 1.1 | Instalar deps de seguridad en Backend/ (`bcrypt`, `@nestjs/jwt`, `@nestjs/passport`, `passport`, `passport-jwt`, `class-validator`, `class-transformer`, `@nestjs/throttler`, `helmet`) | Dependencias |
| 1.2 | Crear módulo `Backend/src/auth/` completo: `auth.module.ts`, `auth.controller.ts`, `auth.service.ts`, `jwt.strategy.ts`, `jwt-auth.guard.ts`, `roles.guard.ts`, `roles.decorator.ts` | Archivos nuevos (7) |
| 1.3 | Crear DTOs de auth: `login.dto.ts`, `register.dto.ts` con class-validator | Archivos nuevos (2) |
| 1.4 | Refactorizar `usuario.entity.ts`: renombrar `password` a `password_hash`, agregar `@Exclude()`, convertir `tenant_id` a FK real a Finca | Modificación |
| 1.5 | Refactorizar `usuarios.service.ts`: eliminar login (mover a AuthService), agregar `findByEmail()`, `findById()` | Modificación |
| 1.6 | Refactorizar `usuarios.controller.ts`: eliminar endpoints de login/registro, agregar guards, usar DTOs | Modificación |
| 1.7 | Configurar `main.ts`: ValidationPipe global, Helmet, ThrottlerGuard, prefijo global `/api/v1` | Modificación |
| 1.8 | Agregar variables JWT a `.env.example` | Modificación |
| 1.9 | Configurar Swagger en `main.ts` | Modificación |

**Criterio de éxito**:
- `POST /api/v1/auth/register` hashea password con bcrypt y retorna JWT
- `POST /api/v1/auth/login` compara hash y retorna JWT
- `GET /api/v1/usuarios` requiere Bearer token (401 sin él)
- `GET /api/v1/usuarios` NO retorna campo `password_hash`
- Rate limiting activo (429 tras exceso de requests)

---

### FASE 2 — Integridad Relacional y Multitenant

**Objetivo**: Corregir todas las FKs rotas e implementar aislamiento por tenant.
**Duración estimada**: 4-5 horas
**Dependencias**: FASE 1 completada (necesita JWT para extraer tenant del token)
**Riesgo**: Medio (cambios en schema de BD)

**Tareas**:

| # | Tarea | Entidad/Archivo |
|---|-------|-----------------|
| 2.1 | Agregar FK `fk_id_finca` a entidad `Salud` + FK `fk_id_bovino` a Animal | `salud.entity.ts` |
| 2.2 | Agregar FK `fk_id_finca` a entidad `Finanza` | `finanza.entity.ts` |
| 2.3 | Agregar FK `fk_id_finca` a entidad `Alimento` | `alimento.entity.ts` |
| 2.4 | Convertir `Reproduccion.fk_id_padre` y `fk_id_madre` en FKs reales a Animal | `reproduccion.entity.ts` |
| 2.5 | Corregir `Animal.reproducciones: any` → `@OneToMany(() => Reproduccion, r => r.bovino) reproducciones: Reproduccion[]` | `animal.entity.ts` |
| 2.6 | Crear `Backend/src/common/guards/tenant.guard.ts` — extrae `tenant_id` del JWT payload y lo inyecta en el request | Archivo nuevo |
| 2.7 | Crear `Backend/src/common/decorators/current-tenant.decorator.ts` — `@CurrentTenant()` parameter decorator | Archivo nuevo |
| 2.8 | Crear `Backend/src/common/decorators/current-user.decorator.ts` — `@CurrentUser()` parameter decorator | Archivo nuevo |
| 2.9 | Crear `Backend/src/common/common.module.ts` — exporta guards y decorators | Archivo nuevo |
| 2.10 | Implementar CRUD completo para `FincasModule` (controller + service + DTOs) — es el tenant raíz | 4 archivos |
| 2.11 | Migrar `synchronize: true` a sistema de migraciones TypeORM | `app.module.ts` + scripts |

**Criterio de éxito**:
- Un usuario de Finca A NO puede acceder a datos de Finca B
- Todas las entidades tienen FKs válidas con constraints
- `synchronize: false` en configuración
- CRUD de Fincas funcional con aislamiento

---

### FASE 3 — Backend CRUD Completo

**Objetivo**: Implementar lógica de negocio para los 7 módulos restantes.
**Duración estimada**: 8-10 horas
**Dependencias**: FASE 2 completada (necesita FKs y TenantGuard)
**Riesgo**: Bajo (trabajo incremental)

**Orden de implementación** (por cadena de dependencias):

```
1. potreros   (depende de: finca)
2. animales   (depende de: finca, potrero)
3. alimentos  (depende de: finca)
4. bovino-alimento (depende de: animal, alimento)
5. salud      (depende de: animal, finca)
6. reproduccion (depende de: animal)
7. finanzas   (depende de: finca)
```

**Por cada módulo**:

| Entregable | Descripción |
|------------|-------------|
| `create-<entity>.dto.ts` | DTO con class-validator para creación |
| `update-<entity>.dto.ts` | DTO parcial (PartialType) para actualización |
| `query-<entity>.dto.ts` | DTO para filtros y paginación |
| `<entity>.controller.ts` | GET /, GET /:id, POST /, PATCH /:id, DELETE /:id — todos con `@UseGuards(JwtAuthGuard, TenantGuard)` |
| `<entity>.service.ts` | CRUD con filtrado por tenant, paginación, búsqueda |
| `<entity>.module.ts` | Registro de TypeOrmModule.forFeature, controller, service |

**Endpoints agregados especiales** (para Dashboard e Inspector):

| Endpoint | Módulo | Propósito |
|----------|--------|-----------|
| `GET /api/v1/fincas/:id/resumen` | fincas | Métricas agregadas |
| `GET /api/v1/fincas/:id/distribucion` | animales | Conteo por tipo/género |
| `GET /api/v1/fincas/:id/alertas` | salud | Controles pendientes |
| `GET /api/v1/fincas/:id/finanzas/resumen` | finanzas | Balance mensual |
| `GET /api/v1/fincas/:id/eventos` | salud + reproduccion | Próximos eventos |

**Criterio de éxito**:
- 45+ endpoints funcionales (5 CRUD x 8 módulos + 5 agregados)
- Todos protegidos con JWT
- Todos filtrados por tenant
- Todos con paginación
- Swagger documenta todos los endpoints

---

### FASE 4 — Frontend: Auth, Estado y Conectividad

**Objetivo**: Conectar el frontend al backend autenticado con manejo de estado robusto.
**Duración estimada**: 6-7 horas
**Dependencias**: FASE 1 completada (necesita JWT del backend)
**Nota**: Puede ejecutarse en paralelo con FASE 3 si FASE 1 ya está lista.
**Riesgo**: Medio (cambios estructurales en el frontend)

**Tareas**:

| # | Tarea | Detalle |
|---|-------|---------|
| 4.1 | Agregar dependencias: `provider`, `go_router`, `flutter_secure_storage` | `pubspec.yaml` |
| 4.2 | Crear modelos Dart con factories `fromJson`/`toJson` | `lib/models/`: user.dart, finca.dart, animal.dart, potrero.dart, salud.dart, reproduccion.dart, finanza.dart, auth_response.dart, paginated_response.dart |
| 4.3 | Reescribir `api_service.dart` con interceptors de auth, tenant, retry, error | `lib/services/api_service.dart` |
| 4.4 | Crear `auth_service.dart` con login, register, logout, refreshToken, isAuthenticated | `lib/services/auth_service.dart` |
| 4.5 | Crear providers: `AuthProvider`, `FincaProvider`, `DashboardProvider` | `lib/providers/` |
| 4.6 | Crear configuración de router con guards | `lib/router.dart` |
| 4.7 | Actualizar `main.dart` con MultiProvider y GoRouter | `lib/main.dart` |
| 4.8 | Refactorizar LoginScreen para usar AuthProvider y guardar token | `lib/screens/Login_screen.dart` |
| 4.9 | Refactorizar RegistroScreen para seleccionar/crear finca | `lib/screens/Registro_screen.dart` |
| 4.10 | Agregar dispose() a todos los TextEditingControllers | Screens con controllers |
| 4.11 | Crear pantalla de selección de finca (post-registro) | `lib/screens/Finca_selector_screen.dart` |
| 4.12 | Configurar base URL desde env/config | `lib/config.dart` |

**Criterio de éxito**:
- Login almacena token y redirige a Dashboard
- Dashboard es inaccesible sin token (redirect a Login)
- Refresh token automático al expirar access token
- Logout limpia tokens y redirige a Landing
- Tenant se extrae del usuario logueado, no hardcodeado

---

### FASE 5 — Panel de Inspector y Pantallas de Dominio

**Objetivo**: Construir el panel de Inspector, reemplazar datos hardcodeados del Dashboard, crear pantallas CRUD para cada dominio.
**Duración estimada**: 10-12 horas
**Dependencias**: FASE 3 + FASE 4 completadas
**Riesgo**: Bajo (trabajo incremental de UI)

**Tareas**:

| # | Tarea | Pantalla/Componente |
|---|-------|---------------------|
| 5.1 | Reescribir Dashboard con datos de API (FutureBuilder + Provider) | `Dashboard_screen.dart` |
| 5.2 | Crear `InspectorLayout` (sidebar + content + status bar) | `lib/layouts/inspector_layout.dart` |
| 5.3 | Crear `CompactDataTable` (filas densas, sort, selección) | `lib/components/compact_data_table.dart` |
| 5.4 | Crear `FilterBar` (dropdowns de filtro) | `lib/components/filter_bar.dart` |
| 5.5 | Crear `MetricStrip` (fila de métricas compactas) | `lib/components/metric_strip.dart` |
| 5.6 | Crear `FincaHeader` (resumen compacto de finca) | `lib/components/finca_header.dart` |
| 5.7 | Crear `PaginationBar` | `lib/components/pagination_bar.dart` |
| 5.8 | Crear pantalla de Inspector con todas las tabs | `lib/screens/Inspector_screen.dart` |
| 5.9 | Crear pantalla detalle de Finca | `lib/screens/Finca_detail_screen.dart` |
| 5.10 | Crear pantalla lista de Animales (con filtros y paginación) | `lib/screens/Animales_list_screen.dart` |
| 5.11 | Crear pantalla detalle/edición de Animal | `lib/screens/Animal_detail_screen.dart` |
| 5.12 | Crear pantalla de Potreros | `lib/screens/Potreros_screen.dart` |
| 5.13 | Crear pantalla de Salud (lista + formulario) | `lib/screens/Salud_screen.dart` |
| 5.14 | Crear pantalla de Reproducción | `lib/screens/Reproduccion_screen.dart` |
| 5.15 | Crear pantalla de Finanzas (resumen + transacciones) | `lib/screens/Finanzas_screen.dart` |
| 5.16 | Crear pantalla de Alimentos | `lib/screens/Alimentos_screen.dart` |
| 5.17 | Conectar items del FAB a formularios de creación | `Dashboard_screen.dart` |
| 5.18 | Agregar BottomNavigationBar o Drawer para nav entre secciones | `lib/layouts/` |

**Criterio de éxito**:
- Dashboard muestra datos reales de la API
- Panel de Inspector funcional con split-panel layout
- Todas las pantallas CRUD operativas con paginación
- FAB del dashboard navega a formularios reales
- Filtros aplicados correctamente a tablas

---

### FASE 6 — Testing, Hardening y Preparación para Demo

**Objetivo**: Cobertura de tests, seed data para demo, documentación actualizada.
**Duración estimada**: 5-6 horas
**Dependencias**: FASE 5 completada
**Riesgo**: Bajo

**Tareas**:

| # | Tarea | Tipo |
|---|-------|------|
| 6.1 | Tests unitarios para AuthService (login, register, token generation, bcrypt) | Backend test |
| 6.2 | Tests unitarios para cada Service CRUD (mock repositories) | Backend test |
| 6.3 | Tests unitarios para TenantGuard (aislamiento verificado) | Backend test |
| 6.4 | Tests E2E: flujo completo register → login → CRUD → logout | Backend test |
| 6.5 | Widget tests para LoginScreen y RegistroScreen | Frontend test |
| 6.6 | Crear Dockerfile multi-stage para Backend | `Backend/Dockerfile` |
| 6.7 | Actualizar docker-compose.yml con nuevo Dockerfile | `/docker-compose.yml` |
| 6.8 | Crear script de seed data para demo | `Backend/src/seeds/seed.ts` |
| 6.9 | Actualizar README.md reflejando arquitectura real | `/README.md` |
| 6.10 | Reescribir TESTING.md con endpoints reales | `/TESTING.md` |
| 6.11 | Ejecutar `flutter analyze` y corregir warnings | Frontend |
| 6.12 | Ejecutar `npm run lint` y corregir warnings | Backend |
| 6.13 | Agregar logging con NestJS Logger en servicios críticos | Backend |

**Criterio de éxito**:
- `npm run test` pasa con >= 70% cobertura en servicios
- `npm run test:e2e` pasa flujo completo de auth + CRUD
- `flutter test` pasa widget tests
- `docker compose up --build` levanta la aplicación completa
- Seed data puebla la BD con datos de demo realistas
- `flutter analyze` y `npm run lint` sin errores

---

## 9. MATRIZ DE DEPENDENCIAS ENTRE FASES

```
FASE 0 ──────► FASE 1 ──────► FASE 2 ──────► FASE 3 ──────┐
(Saneamiento)  (Seguridad)    (Multitenant)   (CRUD Backend) │
                    │                                         │
                    │                                         ▼
                    └──────► FASE 4 ──────────────────► FASE 5 ──► FASE 6
                             (Frontend Auth)           (Inspector) (Testing)
```

**Paralelismo posible**:
- FASE 3 y FASE 4 pueden ejecutarse en paralelo (una vez FASE 1 completada para FASE 4, y FASE 2 completada para FASE 3)
- FASE 5 requiere que AMBAS (FASE 3 + FASE 4) estén completadas
- FASE 6 es secuencial después de FASE 5

**Camino crítico**: FASE 0 → FASE 1 → FASE 2 → FASE 3 → FASE 5 → FASE 6

---

## 10. CRITERIOS DE ACEPTACIÓN POR FASE

### Verificación Automatizada

| Fase | Comando de verificación | Resultado esperado |
|------|------------------------|-------------------|
| 0 | `cd Backend && npm run start:dev` | Arranca sin errors ni warnings por artefactos fantasma |
| 0 | `cd Frontend && flutter analyze` | 0 errores |
| 1 | `curl -X POST localhost:3000/api/v1/auth/register -d '...'` | 201 con JWT |
| 1 | `curl localhost:3000/api/v1/usuarios` (sin token) | 401 Unauthorized |
| 1 | `curl localhost:3000/api/v1/usuarios` (con token) | 200, sin campo password_hash |
| 2 | Request con token de Finca A a datos de Finca B | 403 Forbidden |
| 2 | `npm run migration:run` | Migraciones ejecutadas |
| 3 | Swagger UI muestra 45+ endpoints | Documentación completa |
| 3 | CRUD completo en cada módulo vía curl | 200/201/204 según operación |
| 4 | Login en Flutter → Dashboard con datos reales | Navegación funcional |
| 4 | Cerrar app y reabrir → sesión persistida | Token en SecureStorage |
| 5 | Panel Inspector navega entre tabs con datos reales | UI funcional |
| 5 | Dashboard sin datos hardcodeados | Todos los valores de API |
| 6 | `npm run test` | >= 70% cobertura |
| 6 | `docker compose up --build` | Stack completo arranca |

### Checklist de Seguridad (Post-FASE 1)

- [ ] Contraseñas hasheadas con bcrypt (factor >= 12)
- [ ] JWT con secreto fuerte (>= 256 bits)
- [ ] Access token expira en <= 15 minutos
- [ ] Refresh token expira en <= 7 días
- [ ] Rate limiting activo en endpoints de auth
- [ ] Helmet headers configurados
- [ ] CORS con whitelist explícita
- [ ] Campo password excluido de TODAS las respuestas
- [ ] ValidationPipe con `whitelist: true` y `forbidNonWhitelisted: true`
- [ ] Swagger protegido o deshabilitado en producción

### Checklist de Integridad (Post-FASE 2)

- [ ] Salud tiene FK a Animal y Finca
- [ ] Finanza tiene FK a Finca
- [ ] Alimento tiene FK a Finca
- [ ] Reproduccion.fk_id_padre y fk_id_madre son FKs reales
- [ ] Animal.reproducciones tiene @OneToMany tipado
- [ ] Usuario.tenant_id es FK a Finca
- [ ] Todas las queries filtran por tenant_id
- [ ] synchronize: false en config

---

## 11. APÉNDICE — ARCHIVOS AUDITADOS

### Backend (35 archivos)

**Configuración**: `package.json`, `tsconfig.json`, `tsconfig.build.json`, `nest-cli.json`, `eslint.config.mjs`, `.prettierrc`, `.gitignore`

**Core**: `main.ts`, `app.module.ts`, `app.controller.ts`, `app.service.ts`

**Entidades (9)**: `usuario.entity.ts`, `finca.entity.ts`, `animal.entity.ts`, `potrero.entity.ts`, `alimento.entity.ts`, `salud.entity.ts`, `reproduccion.entity.ts`, `finanza.entity.ts`, `bovino-alimento.entity.ts`

**Controllers (6)**: `usuarios.controller.ts`, `alimentos.controller.ts`, `salud.controller.ts`, `reproduccion.controller.ts`, `finanzas.controller.ts`, `app.controller.ts`

**Services (8)**: `usuarios.service.ts`, `alimentos.service.ts`, `fincas.service.ts`, `animales.service.ts`, `potreros.service.ts`, `salud.service.ts`, `reproduccion.service.ts`, `finanzas.service.ts`

**Modules (8)**: Uno por cada dominio

**Tests (2)**: `app.controller.spec.ts`, `test/app.e2e-spec.ts`

### Frontend (12 archivos)

**Core**: `main.dart`, `pubspec.yaml`, `analysis_options.yaml`

**Screens (4)**: `Landing_screen.dart`, `Login_screen.dart`, `Registro_screen.dart`, `Dashboard_screen.dart`

**Components (2)**: `input_field.dart`, `primary_button.dart`

**Services (1)**: `api_service.dart`

**Theme (2)**: `Colors.dart`, `Theme.dart`

### Root (8 archivos)

`README.md`, `TESTING.md`, `TROUBLESHOOTING.md`, `docker-compose.yml`, `package.json`, `tsconfig.json`, `nest-cli.json`, `setup.sh`, `.gitignore`

---

## RESUMEN CUANTITATIVO

| Métrica | Valor actual | Valor objetivo (post-FASE 6) |
|---------|-------------|------------------------------|
| Vulnerabilidades CRÍTICAS | 3 | 0 |
| Vulnerabilidades ALTAS | 4 | 0 |
| Endpoints funcionales | 5 | 50+ |
| Módulos con lógica completa | 1/9 (11%) | 9/9 (100%) |
| Pantallas frontend | 4 | 14+ |
| Pantallas con datos reales | 0 | 14+ |
| Cobertura de tests | 0% | >= 70% |
| FKs faltantes | 6 | 0 |
| Horas estimadas totales | — | 36-44 horas |

---

**FIN DEL DOCUMENTO**

*Este plan fue generado mediante auditoría estática del código fuente. No se ejecutó ni modificó ninguna línea de código durante su elaboración. Todas las recomendaciones deben ser validadas por el equipo antes de su implementación.*
