# FarmLink Backend — API Reference

> Plataforma ganadera multitenant. Documento de referencia para el equipo de frontend.

---

## 1. Descripción

**FarmLink** es una plataforma SaaS multitenant para la gestión de fincas ganaderas: inventario de bovinos, potreros, alimentación, salud, reproducción, finanzas y movimientos. Cada cliente (tenant) opera de forma aislada — los datos de un tenant nunca son visibles para otro.

Este backend expone una API REST sobre `/api` y un Swagger UI navegable en `/api/docs`.

---

## 2. Stack técnico

| Capa | Tecnología |
|---|---|
| Runtime | Node.js (TypeScript 5.7) |
| Framework | NestJS 11 sobre Express |
| ORM | TypeORM 0.3 |
| Base de datos | PostgreSQL |
| Auth | Passport-JWT (dual token: access + refresh) |
| Validación | class-validator + class-transformer |
| Seguridad | helmet, cookie-parser, bcrypt |
| Documentación | Swagger (OpenAPI 3) |

> ⚠️ **Nota**: el archivo `prisma/schema.prisma` es un diseño inicial **abandonado**. El ORM real es TypeORM. Ignorar Prisma.

---

## 3. Cómo correr el backend

### Variables de entorno (`.env`)

```env
PORT=3000

# PostgreSQL
DB_HOST=localhost
DB_PORT=5433
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE=farmlink

# JWT
JWT_SECRET=cambia_esto_en_prod
JWT_EXPIRES_IN=1d
JWT_REFRESH_SECRET=cambia_esto_tambien
JWT_REFRESH_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=http://localhost:5173
```

### Comandos

```bash
cd Backend
npm install
npm run start:dev          # desarrollo con watch
npm run build && npm run start:prod
```

API disponible en `http://localhost:3000/api` y Swagger en `http://localhost:3000/api/docs`.

---

## 4. Arquitectura

### Estructura de carpetas

```
Backend/src/
├── main.ts                      # bootstrap, prefijo /api, CORS, pipes, Swagger
├── app.module.ts                # módulo raíz, registra guards globales
├── app.controller.ts            # GET /api (health check, @Public)
│
├── auth/                        # JWT login, registro, refresh, logout
├── usuarios/                    # listado de usuarios del tenant
├── fincas/                      # CRUD fincas
├── animales/                    # CRUD bovinos + venta + costos
├── potreros/                    # CRUD potreros + ocupación
├── alimentos/                   # CRUD alimentos
├── bovino-alimento/             # asignación N:N bovino ↔ alimento
├── salud/                       # registros sanitarios + alertas
├── reproduccion/                # eventos reproductivos + alertas
├── finanzas/                    # movimientos financieros + resumen
├── movimientos/                 # historial de traslados entre potreros
├── dashboard/                   # métricas agregadas
├── alertas/                     # alertas centralizadas (salud + reproducción)
│
└── common/
    ├── entities/base.entity.ts  # PK numérica + tenant_id + auditoría + soft delete
    ├── guards/                  # JwtAuthGuard, RolesGuard, TenantGuard (todos globales)
    ├── decorators/              # @Public, @CurrentUser, @Tenant, @Roles
    ├── filters/                 # GlobalHttpExceptionFilter
    ├── interceptors/            # LoggingInterceptor
    └── dto/pagination.dto.ts    # PaginationDto base
```

### Guards globales (orden de ejecución)

Registrados en `app.module.ts` con `APP_GUARD`. Se ejecutan **en este orden** para cada request:

1. **`JwtAuthGuard`** — verifica firma del access token (`Authorization: Bearer <token>`). Rutas marcadas con `@Public()` lo saltan.
2. **`RolesGuard`** — si la ruta tiene `@Roles('admin', ...)`, valida que `request.user.rol` esté permitido. Sin `@Roles()` cualquier autenticado pasa.
3. **`TenantGuard`** — extrae `tenant_id` del JWT validado, lo asigna a `req.tenantId`, y bloquea escalada horizontal verificando que cualquier `tenant_id` que aparezca en params/query/body coincida con el del JWT.

### Decoradores

| Decorador | Uso |
|---|---|
| `@Public()` | Exime una ruta del JWT + tenant guard (login, registro, health) |
| `@CurrentUser()` | Inyecta el `JwtUserPayload` (`{ sub, email, tenant_id, rol }`) |
| `@Tenant()` | Inyecta el `tenantId` (string) ya validado |
| `@Roles('admin', 'propietario')` | Restringe por rol |

### Soft delete

Toda entidad que extiende `BaseEntity` (o lo declara inline) incluye `deleted_at: Date | null`. Los services siempre filtran `WHERE deleted_at IS NULL`. `DELETE` nunca borra físicamente — solo setea `deleted_at = NOW()`.

### Validación

`ValidationPipe` global con:
- `whitelist: true` — descarta campos no declarados en el DTO
- `forbidNonWhitelisted: true` — devuelve 400 si el body tiene campos extra
- `transform: true` — convierte tipos automáticamente

---

## 5. Autenticación

### Flujo dual-token

| Token | Header/storage | Secreto | Expiración (default) | Uso |
|---|---|---|---|---|
| **Access** | `Authorization: Bearer <token>` | `JWT_SECRET` | `1d` | Cada request protegido |
| **Refresh** | Cookie HTTP-only `refresh_token` *o* header *o* body | `JWT_REFRESH_SECRET` | `7d` | Renovar el access token |

El refresh token se hashea con bcrypt y se guarda en `usuario.refresh_token_hash`. **Rotación obligatoria**: cada llamada a `/api/auth/refresh` invalida el refresh anterior y emite uno nuevo.

### Claims del JWT

```json
{
  "sub": 1,
  "email": "maria@finca.com",
  "tenant_id": "tenant-a",
  "rol": "admin"
}
```

Roles válidos: `admin | propietario | empleado`.

### Cómo usarlo desde el frontend

```ts
// 1. Login
const { access_token, refresh_token, user } = await fetch('/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password }),
  credentials: 'include',  // necesario para que el navegador guarde la cookie de refresh
}).then(r => r.json());

// 2. Guardar access token (memoria, NO localStorage si es posible)
localStorage.setItem('access_token', access_token);

// 3. Adjuntar en cada request
fetch('/api/dashboard', {
  headers: { Authorization: `Bearer ${access_token}` },
});

// 4. Cuando el access expira (401), refrescar
await fetch('/api/auth/refresh', { method: 'POST', credentials: 'include' });
```

> El frontend **no necesita** enviar `tenant_id` en headers ni body — viaja firmado dentro del JWT.

---

## 6. Multitenancy

El `tenant_id` está embebido en el claim `tenant_id` del JWT firmado. El backend lo lee del token, lo asigna a `req.tenantId` y lo usa internamente para filtrar todas las queries (`WHERE tenant_id = :tenantId`).

**Implicaciones para el frontend:**

- ✅ **Solo guardar el access token.** El tenant viaja con él.
- ✅ Usar el mismo access token para todos los recursos del usuario.
- ❌ **No** mandar `X-Tenant-ID`, ni query `?tenant_id=...`, ni body con `tenant_id`. Si lo hacen y no coincide con el JWT, el `TenantGuard` responderá 403.
- ⚠️ Para cambiar de tenant (si un usuario pertenece a varios) hay que **re-loguear**. No hay endpoint de switch en este momento.

---

## 7. Modelo de datos

### Diagrama ER (simplificado)

```
Finca (1) ──< (N) Potrero
Finca (1) ──< (N) Animal
Potrero (1) ──< (N) Animal
Animal (1) ──< (N) Salud
Animal (N) ──< (N) Alimento  [vía BovinoAlimento]
Animal (1) ──< (N) MovimientoAnimal  [origen/destino = Potrero]
Animal (1) ──< (N) Reproduccion
Animal (1) ──< (N) Finanza
Finca  (1) ──< (N) Finanza
```

### Entidades principales

| Entidad | Tabla | PK | Notas |
|---|---|---|---|
| `Usuario` | `usuarios` | `id` (number) | Email único, password bcrypt, rol enum |
| `Finca` | `finca` | `pk_id_finca` (string) | PK manual ej. `FINCA001` |
| `Potrero` | `potreros` | `pk_id_potrero` (string) | PK manual ej. `POT001`, FK a finca |
| `Animal` | `bovinos` | `id` (number) | Auto, FK opcional a finca/potrero |
| `Alimento` | `alimento` | `pk_id_alimento` (string) | PK manual ej. `ALI001` |
| `BovinoAlimento` | `bovino_alimento` | compuesta | N:N + cantidad + fecha |
| `Salud` | `salud` | `id` (number) | Auto, FK opcional a animal |
| `Reproduccion` | `reproduccion` | `pk_id_reproduccion` (string) | PK manual ej. `REP001` |
| `Finanza` | `finanzas` | `pk_id_finanza` (string) | PK manual ej. `FIN001` |
| `MovimientoAnimal` | `movimientos_animal` | `id` (number) | Auto |

### Enums

| Campo | Valores |
|---|---|
| `Usuario.rol` | `admin` \| `propietario` \| `empleado` |
| `Animal.genero` | `m` \| `h` \| `n` |
| `Animal.estado` | `activo` \| `vendido` |
| `Finanza.tipo_movimiento` | `ingreso` \| `gasto` |
| `Salud.tipo_intervencion` | `vacunacion` \| `vitaminas` \| `desparasitacion` \| `enfermedad` |

### Campos comunes (auditoría)

Todas las entidades incluyen:

```
tenant_id    string       # aislamiento multitenant
created_at   timestamp    # automático
updated_at   timestamp    # automático
deleted_at   timestamp?   # soft delete
created_by   number?      # id del usuario
updated_by   number?      # id del usuario
```

---

## 8. Convenciones globales

### Paginación

Cualquier endpoint `GET` que liste recursos acepta:

| Query param | Tipo | Default | Notas |
|---|---|---|---|
| `page` | number | `1` | |
| `limit` | number | `10` | máx `100` |
| `sortBy` | string | varía | Solo columnas permitidas por DTO |
| `sortOrder` | `ASC` \| `DESC` | `DESC` | |

**Forma de respuesta:**

```json
{
  "data": [ /* registros */ ],
  "total": 142,
  "page": 1,
  "lastPage": 15
}
```

### Errores estandarizados

`GlobalHttpExceptionFilter` envuelve todos los errores en este formato:

```json
{
  "statusCode": 404,
  "message": "Finca FINCA999 no encontrada",
  "path": "/api/fincas/FINCA999",
  "timestamp": "2026-04-07T14:30:00.000Z"
}
```

Si la validación falla (`ValidationPipe`), `message` puede ser un array con detalle por campo.

### Códigos HTTP comunes

| Código | Significado |
|---|---|
| `200` | OK |
| `201` | Recurso creado |
| `400` | Body/query inválido (ValidationPipe) |
| `401` | Sin token o token inválido/expirado |
| `403` | Token válido pero sin permiso (rol o tenant cruzado) |
| `404` | Recurso no encontrado en el tenant |
| `409` | Conflicto (ej. email duplicado) |
| `500` | Error interno |

---

## 9. Catálogo de endpoints

> **Convenciones**: Todos los endpoints requieren `Authorization: Bearer <access_token>` salvo los marcados como `@Public`. El `tenant_id` se infiere del JWT — **no se envía**.

### Índice

| Módulo | Endpoints | Sección |
|---|---|---|
| Health | 1 | [9.0](#90-health) |
| Auth | 5 | [9.1](#91-auth) |
| Usuarios | 1 | [9.2](#92-usuarios) |
| Fincas | 7 | [9.3](#93-fincas) |
| Animales | 7 | [9.4](#94-animales) |
| Potreros | 7 | [9.5](#95-potreros) |
| Alimentos | 5 | [9.6](#96-alimentos) |
| Bovino-Alimento | 4 | [9.7](#97-bovino-alimento) |
| Salud | 6 | [9.8](#98-salud) |
| Reproducción | 6 | [9.9](#99-reproducción) |
| Finanzas | 6 | [9.10](#910-finanzas) |
| Movimientos | 3 | [9.11](#911-movimientos) |
| Dashboard | 1 | [9.12](#912-dashboard) |
| Alertas | 1 | [9.13](#913-alertas) |
| **Total** | **60** | |

---

### 9.0 Health

| # | Método | Ruta | Auth |
|---|---|---|---|
| 1 | `GET` | `/api` | `@Public` |

**`GET /api`** — Health check. Retorna string de bienvenida.

---

### 9.1 Auth

| # | Método | Ruta | Auth |
|---|---|---|---|
| 2 | `POST` | `/api/auth/registro` | `@Public` |
| 3 | `POST` | `/api/auth/login` | `@Public` |
| 4 | `GET`  | `/api/auth/me` | JWT |
| 5 | `POST` | `/api/auth/refresh` | JwtRefreshGuard |
| 6 | `POST` | `/api/auth/logout` | JWT |

#### `POST /api/auth/registro`

Registra un nuevo usuario en un tenant.

**Request body** (`RegistroDto`):
```json
{
  "email": "maria@finca.com",
  "password": "secreto123",
  "nombre": "María García",
  "telefono": "+573001234567",
  "tenant_id": "tenant-a"
}
```

| Campo | Tipo | Obligatorio | Reglas |
|---|---|---|---|
| `email` | string | sí | formato email |
| `password` | string | sí | mín 6 chars |
| `nombre` | string | sí | |
| `telefono` | string | no | |
| `tenant_id` | string | sí | |

**Response 201** — usuario creado (sin `password` ni `refresh_token_hash`).

**Errores**: `409` email ya registrado.

---

#### `POST /api/auth/login`

**Request body** (`LoginDto`):
```json
{ "email": "maria@finca.com", "password": "secreto123" }
```

**Response 200**:
```json
{
  "access_token": "eyJhbGciOi...",
  "refresh_token": "eyJhbGciOi...",
  "user": {
    "id": 1,
    "nombre": "María García",
    "email": "maria@finca.com",
    "rol": "admin",
    "tenant_id": "tenant-a"
  }
}
```

Además setea cookie HTTP-only `refresh_token` con `path=/api/auth/refresh`.

**Errores**: `401` credenciales inválidas.

---

#### `GET /api/auth/me`

Devuelve el perfil del usuario autenticado.

**Headers**: `Authorization: Bearer <access_token>`

**Response 200**:
```json
{
  "id": 1,
  "nombre": "María García",
  "email": "maria@finca.com",
  "rol": "admin",
  "tenant_id": "tenant-a",
  "telefono": null
}
```

---

#### `POST /api/auth/refresh`

Rota tokens. Acepta el refresh en (en orden de prioridad):
1. Cookie `refresh_token`
2. Header `Authorization: Bearer <refresh_token>`
3. Body `{ "refresh_token": "..." }`

**Response 200**:
```json
{ "access_token": "eyJ...", "refresh_token": "eyJ..." }
```

**Errores**: `403` refresh inválido / expirado / sin sesión activa.

---

#### `POST /api/auth/logout`

Limpia el `refresh_token_hash` del usuario y borra la cookie.

**Headers**: `Authorization: Bearer <access_token>`

**Response 200**: `{ "message": "Sesión cerrada correctamente" }`

---

### 9.2 Usuarios

| # | Método | Ruta | Auth |
|---|---|---|---|
| 7 | `GET` | `/api/usuarios` | JWT + tenant |

#### `GET /api/usuarios`

Lista los usuarios del tenant autenticado.

**Response 200**: array de usuarios.

---

### 9.3 Fincas

| # | Método | Ruta | Auth |
|---|---|---|---|
| 8  | `POST`   | `/api/fincas` | JWT + tenant |
| 9  | `GET`    | `/api/fincas` | JWT + tenant |
| 10 | `GET`    | `/api/fincas/:id/animales` | JWT + tenant |
| 11 | `GET`    | `/api/fincas/:id/potreros` | JWT + tenant |
| 12 | `GET`    | `/api/fincas/:id` | JWT + tenant |
| 13 | `PATCH`  | `/api/fincas/:id` | JWT + tenant |
| 14 | `DELETE` | `/api/fincas/:id` | JWT + tenant |

> `:id` = `pk_id_finca` (string, ej. `FINCA001`).

#### `POST /api/fincas`

**Request body** (`CreateFincaDto`):
```json
{
  "pk_id_finca": "FINCA001",
  "nombre_finca": "Hacienda El Paraíso",
  "ubicacion": "Córdoba, Colombia",
  "propietario": "Juan Pérez",
  "area_total": 250.5,
  "fecha_registro": "2024-01-15"
}
```

| Campo | Tipo | Obligatorio | Reglas |
|---|---|---|---|
| `pk_id_finca` | string | sí | máx 15 |
| `nombre_finca` | string | sí | máx 100 |
| `ubicacion` | string | no | máx 150 |
| `propietario` | string | no | máx 100 |
| `area_total` | number | no | ≥ 0 |
| `fecha_registro` | string (ISO) | no | |

#### `GET /api/fincas`

**Query** (`FilterFincasDto`):
- Paginación estándar (`page`, `limit`, `sortOrder`)
- `sortBy`: `pk_id_finca | nombre_finca | ubicacion | area_total | fecha_registro | creado_en | updated_at`
- `nombre_finca`: filtro parcial (LIKE)
- `ubicacion`: filtro parcial

#### `GET /api/fincas/:id/animales`

Lista animales activos asignados a la finca.

#### `GET /api/fincas/:id/potreros`

Lista potreros de la finca.

#### `GET /api/fincas/:id`

Detalle de la finca con relaciones (animales, potreros).

#### `PATCH /api/fincas/:id`

**Body**: `UpdateFincaDto` — todos los campos de `CreateFincaDto` opcionales (excepto `pk_id_finca`, no modificable).

#### `DELETE /api/fincas/:id`

Soft delete. **Response 200**: `{ "message": "..." }`.

---

### 9.4 Animales

| # | Método | Ruta | Auth |
|---|---|---|---|
| 15 | `POST`   | `/api/animales` | JWT + tenant |
| 16 | `GET`    | `/api/animales` | JWT + tenant |
| 17 | `GET`    | `/api/animales/:id/costos` | JWT + tenant |
| 18 | `POST`   | `/api/animales/:id/vender` | JWT + tenant |
| 19 | `GET`    | `/api/animales/:id` | JWT + tenant |
| 20 | `PATCH`  | `/api/animales/:id` | JWT + tenant |
| 21 | `DELETE` | `/api/animales/:id` | JWT + tenant |

> `:id` = número entero (`ParseIntPipe`).

#### `POST /api/animales`

**Request body** (`CreateAnimalDto`):
```json
{
  "numero_identificacion": "BOV-2024-001",
  "metodo_identificacion": "arete_electronico",
  "fecha_nacimiento": "2022-03-15",
  "edad_actual": 24,
  "genero": "m",
  "peso": 450.5,
  "altura": 1.35,
  "raza": "Brahman",
  "origen": "compra",
  "fecha_ingreso": "2023-06-01",
  "fincaId": "FINCA001",
  "potreroId": "POT001"
}
```

| Campo | Tipo | Obligatorio |
|---|---|---|
| `numero_identificacion` | string | sí |
| `fecha_nacimiento` | ISO date | sí |
| `genero` | `m` \| `h` \| `n` | sí |
| `peso` | number ≥ 0 | sí |
| `raza` | string | sí |
| `metodo_identificacion`, `edad_actual`, `altura`, `origen`, `fecha_ingreso`, `fecha_salida`, `relacion_genealogica`, `fincaId`, `potreroId` | varios | no |

#### `GET /api/animales`

**Query** (`FilterAnimalesDto`):
- Paginación + `sortBy`: `id | numero_identificacion | fecha_nacimiento | genero | peso | raza | created_at | updated_at`
- `raza`: filtro exacto
- `genero`: `m | h | n`
- `estado`: `activo | vendido`

#### `GET /api/animales/:id/costos`

**Response**:
```json
{ "costo_salud": 125000, "costo_alimentacion": 480000, "costo_total": 605000 }
```

#### `POST /api/animales/:id/vender`

**Request body** (`VenderAnimalDto`):
```json
{
  "precio_venta": 2500000,
  "comprador": "Juan Pérez",
  "fecha_venta": "2025-03-15",
  "fincaId": "FINCA001"
}
```

Cambia `estado → vendido`, registra precio/comprador y crea automáticamente un registro en `finanzas` de tipo `ingreso`.

#### `PATCH /api/animales/:id`

`UpdateAnimalDto` — todos los campos opcionales.

#### `DELETE /api/animales/:id`

Soft delete.

---

### 9.5 Potreros

| # | Método | Ruta | Auth |
|---|---|---|---|
| 22 | `POST`   | `/api/potreros` | JWT + tenant |
| 23 | `GET`    | `/api/potreros` | JWT + tenant |
| 24 | `GET`    | `/api/potreros/:id/ocupacion` | JWT + tenant |
| 25 | `GET`    | `/api/potreros/:id/animales` | JWT + tenant |
| 26 | `GET`    | `/api/potreros/:id` | JWT + tenant |
| 27 | `PATCH`  | `/api/potreros/:id` | JWT + tenant |
| 28 | `DELETE` | `/api/potreros/:id` | JWT + tenant |

> `:id` = `pk_id_potrero` (string, ej. `POT001`).

#### `POST /api/potreros`

**Request body** (`CreatePotreroDto`):
```json
{
  "pk_id_potrero": "POT001",
  "nombre_potrero": "Potrero Norte",
  "area": 12.5,
  "capacidad_animales": 50,
  "estado": "activo",
  "fecha_rotacion": "2024-06-01",
  "fecha_proxima_rotacion": "2024-09-01",
  "fincaId": "FINCA001"
}
```

| Campo | Tipo | Obligatorio |
|---|---|---|
| `pk_id_potrero` | string máx 15 | sí |
| `nombre_potrero` | string máx 100 | sí |
| `capacidad_animales` | int ≥ 1 | sí |
| `area`, `estado`, `fecha_rotacion`, `fecha_proxima_rotacion`, `fincaId` | varios | no |

#### `GET /api/potreros`

**Query**: paginación + `fincaId` (filtrar por finca).

#### `GET /api/potreros/:id/ocupacion`

**Response**:
```json
{ "actual": 32, "capacidad": 50, "porcentaje": 64, "estado": "disponible" }
```

#### `GET /api/potreros/:id/animales`

Lista animales activos del potrero.

---

### 9.6 Alimentos

| # | Método | Ruta | Auth |
|---|---|---|---|
| 29 | `POST`   | `/api/alimentos` | JWT + tenant |
| 30 | `GET`    | `/api/alimentos` | JWT + tenant |
| 31 | `GET`    | `/api/alimentos/:id` | JWT + tenant |
| 32 | `PATCH`  | `/api/alimentos/:id` | JWT + tenant |
| 33 | `DELETE` | `/api/alimentos/:id` | JWT + tenant |

> `:id` = `pk_id_alimento` (string, ej. `ALI001`).

#### `POST /api/alimentos`

**Request body** (`CreateAlimentoDto`):
```json
{
  "pk_id_alimento": "ALI001",
  "tipo_alimento": "Pasto kikuyo",
  "cantidad_total": 500.0,
  "frecuencia": "diario",
  "fecha_inicio": "2024-01-01",
  "fecha_fin_estimada": "2024-06-30",
  "costo": 150000
}
```

| Campo | Tipo | Obligatorio |
|---|---|---|
| `pk_id_alimento` | string máx 15 | sí |
| `tipo_alimento` | string máx 100 | sí |
| Resto | varios | no |

---

### 9.7 Bovino-Alimento

Asignación N:N de alimentos a bovinos con cantidad y fecha.

| # | Método | Ruta | Auth |
|---|---|---|---|
| 34 | `POST`   | `/api/bovino-alimento` | JWT + tenant |
| 35 | `GET`    | `/api/bovino-alimento` | JWT + tenant |
| 36 | `GET`    | `/api/bovino-alimento/animal/:animalId` | JWT + tenant |
| 37 | `DELETE` | `/api/bovino-alimento/:animalId/:alimentoId` | JWT + tenant |

#### `POST /api/bovino-alimento`

**Request body** (`AsignarAlimentoDto`):
```json
{
  "animalId": 1,
  "alimentoId": "ALI001",
  "cantidad": 5.5,
  "fecha": "2024-06-15"
}
```

#### `GET /api/bovino-alimento`

Paginación + `sortBy`: `fecha | cantidad`. Filtro `animalId`.

#### `GET /api/bovino-alimento/animal/:animalId`

Historial de consumo del animal.

#### `DELETE /api/bovino-alimento/:animalId/:alimentoId`

Elimina la asignación específica.

---

### 9.8 Salud

| # | Método | Ruta | Auth |
|---|---|---|---|
| 38 | `POST`   | `/api/salud` | JWT + tenant |
| 39 | `GET`    | `/api/salud` | JWT + tenant |
| 40 | `GET`    | `/api/salud/alertas` | JWT + tenant |
| 41 | `GET`    | `/api/salud/:id` | JWT + tenant |
| 42 | `PATCH`  | `/api/salud/:id` | JWT + tenant |
| 43 | `DELETE` | `/api/salud/:id` | JWT + tenant |

> `:id` = número entero.

#### `POST /api/salud`

**Request body** (`CreateSaludDto`):
```json
{
  "tipo_intervencion": "vacunacion",
  "descripcion_enfermedad": null,
  "producto_aplicado": "Ivermectina",
  "dosis": "5ml",
  "fecha_aplicacion": "2024-06-15",
  "fecha_proxima_aplicacion": "2024-12-15",
  "costo": 25000,
  "animalId": 1
}
```

`tipo_intervencion`: `vacunacion | vitaminas | desparasitacion | enfermedad`.

#### `GET /api/salud`

Paginación + filtros: `tipo_intervencion`.

#### `GET /api/salud/alertas`

**Response**:
```json
{
  "proximas": [ /* fecha_proxima_aplicacion ≤ hoy + 7 días */ ],
  "vencidas": [ /* fecha_proxima_aplicacion < hoy */ ]
}
```

---

### 9.9 Reproducción

| # | Método | Ruta | Auth |
|---|---|---|---|
| 44 | `POST`   | `/api/reproduccion` | JWT + tenant |
| 45 | `GET`    | `/api/reproduccion` | JWT + tenant |
| 46 | `GET`    | `/api/reproduccion/alertas` | JWT + tenant |
| 47 | `GET`    | `/api/reproduccion/:id` | JWT + tenant |
| 48 | `PATCH`  | `/api/reproduccion/:id` | JWT + tenant |
| 49 | `DELETE` | `/api/reproduccion/:id` | JWT + tenant |

> `:id` = `pk_id_reproduccion` (string, ej. `REP001`).

#### `POST /api/reproduccion`

**Request body** (`CreateReproduccionDto`):
```json
{
  "pk_id_reproduccion": "REP001",
  "fk_id_padre": "BOV001",
  "fk_id_madre": "BOV002",
  "metodo_reproduccion": "monta_natural",
  "en_celo": false,
  "preñada": true,
  "numero_crias": 1,
  "fecha_estimado_parto": "2024-12-01"
}
```

#### `GET /api/reproduccion/alertas`

**Response**:
```json
{
  "partos_proximos": [ /* parto en próximos 30 días */ ],
  "partos_vencidos": [ /* parto vencido y aún preñada */ ],
  "en_celo":         [ /* en_celo = true */ ]
}
```

---

### 9.10 Finanzas

| # | Método | Ruta | Auth |
|---|---|---|---|
| 50 | `POST`   | `/api/finanzas` | JWT + tenant |
| 51 | `GET`    | `/api/finanzas` | JWT + tenant |
| 52 | `GET`    | `/api/finanzas/resumen` | JWT + tenant |
| 53 | `GET`    | `/api/finanzas/:id` | JWT + tenant |
| 54 | `PATCH`  | `/api/finanzas/:id` | JWT + tenant |
| 55 | `DELETE` | `/api/finanzas/:id` | JWT + tenant |

> `:id` = `pk_id_finanza` (string, ej. `FIN001`).

#### `POST /api/finanzas`

**Request body** (`CreateFinanzaDto`):
```json
{
  "pk_id_finanza": "FIN001",
  "tipo_movimiento": "ingreso",
  "concepto": "Venta de 5 novillos",
  "categoria": "venta_ganado",
  "monto": 5000000,
  "fecha": "2024-06-15",
  "factura": "FAC-00123",
  "metodo_pago": "transferencia",
  "fincaId": "FINCA001",
  "animalId": 1
}
```

`tipo_movimiento`: `ingreso | gasto`.

#### `GET /api/finanzas`

Paginación + filtros `tipo_movimiento`, `categoria`.

#### `GET /api/finanzas/resumen`

**Response**:
```json
{ "total_ingresos": 8500000, "total_gastos": 3200000, "balance": 5300000 }
```

---

### 9.11 Movimientos

Historial de traslados de animales entre potreros.

| # | Método | Ruta | Auth |
|---|---|---|---|
| 56 | `POST` | `/api/movimientos` | JWT + tenant |
| 57 | `GET`  | `/api/movimientos` | JWT + tenant |
| 58 | `GET`  | `/api/movimientos/animal/:animalId` | JWT + tenant |

#### `POST /api/movimientos`

**Request body** (`CreateMovimientoDto`):
```json
{
  "animalId": 1,
  "potreroOrigenId": "POT001",
  "potreroDestinoId": "POT002",
  "fecha": "2024-06-15",
  "motivo": "Rotación de pastoreo"
}
```

Valida capacidad del potrero destino y actualiza `animal.potreroId`.

#### `GET /api/movimientos`

Paginación + filtro `motivo`.

#### `GET /api/movimientos/animal/:animalId`

Historial completo del animal.

---

### 9.12 Dashboard

| # | Método | Ruta | Auth |
|---|---|---|---|
| 59 | `GET` | `/api/dashboard` | JWT + tenant |

#### `GET /api/dashboard`

**Response 200**:
```json
{
  "inventario": {
    "total_animales": 245,
    "machos": 120,
    "hembras": 125,
    "total_fincas": 3,
    "total_potreros": 18
  },
  "finanzas": {
    "total_ingresos": 8500000,
    "total_gastos": 3200000,
    "balance": 5300000
  },
  "alertas_pendientes": {
    "salud_proxima_7_dias": 4,
    "vacas_preñadas": 12
  },
  "inteligencia": {
    "costo_total_animales": {
      "costo_salud": 1200000,
      "costo_alimentacion": 4500000,
      "costo_total": 5700000
    },
    "top_5_animales_costosos": [ /* ... */ ],
    "top_5_potreros_activos":  [ /* ... */ ],
    "animales_sin_potrero": 7,
    "estimacion_ganancia": {
      "total_ventas": 6000000,
      "costos_vendidos": 2100000,
      "ganancia_neta": 3900000,
      "animales_vendidos": 3
    }
  }
}
```

---

### 9.13 Alertas

| # | Método | Ruta | Auth |
|---|---|---|---|
| 60 | `GET` | `/api/alertas` | JWT + tenant |

#### `GET /api/alertas`

Consolida alertas de salud + reproducción con priorización por severidad.

**Response 200**:
```json
{
  "salud": {
    "proximas": 4,
    "vencidas": 1,
    "detalle_proximas": [ /* ... */ ],
    "detalle_vencidas": [ /* ... */ ]
  },
  "reproduccion": {
    "partos_proximos": 2,
    "partos_vencidos": 0,
    "en_celo": 5
  },
  "resumen": {
    "total_alertas": 12,
    "requiere_atencion_urgente": 1,
    "por_severidad": { "HIGH": 1, "MEDIUM": 6, "LOW": 5 }
  },
  "alertas_priorizadas": [
    {
      "tipo": "salud_vencida",
      "severity": "HIGH",
      "detalle": { /* registro de salud */ }
    }
  ]
}
```

Tipos de alerta: `salud_vencida | parto_vencido | salud_proxima | parto_proximo | en_celo`.

---

## 10. Recursos adicionales

- **Swagger UI navegable**: `http://localhost:3000/api/docs`
- **Health check**: `http://localhost:3000/api`

Para cualquier discrepancia entre este README y el comportamiento real del backend, **el código fuente en `Backend/src/**/*.controller.ts` es la fuente de verdad**.
