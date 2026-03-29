# PLAN DE TRABAJO — FarmLink
> Universidad Tecnológica de Bolívar · Proyecto de Ingeniería 1
> Stack: NestJS 11 + TypeORM 0.3.28 + PostgreSQL 16 + Flutter (Dart 3.10+)
> Última actualización: 2026-03-29

---

## Estado General

| Métrica | Valor |
|---------|-------|
| Fases completadas | 1, 2, 3, 4, 5 |
| Endpoints activos | 14 (auth×4, fincas×5, animales×5) |
| Módulos completos | `auth`, `fincas`, `animales`, `alimentos` (read-only) |
| Módulos pendientes | `potreros`, `salud`, `reproduccion`, `finanzas`, `bovino-alimento`, `usuarios` (write) |
| Documentación | Swagger UI en `/api/docs` |
| Cobertura de tests | Manual (6 suites PowerShell) |

---

## ✅ FASE 1 — Autenticación y Seguridad Base

- [x] Registro de usuario con bcrypt (hash en DB, nunca plain-text)
- [x] Login → `access_token` (15 min) + `refresh_token` (7 días)
- [x] Refresh token rotation con cookie HTTP-only (`/auth/refresh`)
- [x] Logout con invalidación del hash en DB
- [x] `JwtStrategy` + `JwtRefreshStrategy` (Passport)
- [x] `@Public()` decorator para rutas sin auth
- [x] Helmet, CORS configurados

---

## ✅ FASE 2 — Guards Globales y Common

- [x] `src/common/guards/` — `JwtAuthGuard`, `RolesGuard`, `TenantGuard`
- [x] `src/common/decorators/` — `@CurrentUser`, `@Roles`, `@Tenant`, `@Public`
- [x] `src/common/interfaces/` — `RequestWithUser`, `JwtUserPayload`
- [x] `APP_GUARD` registrados en `AppModule` (orden: Jwt → Roles → Tenant)
- [x] `JwtStrategy.validate()` retorna `{ sub, email, tenant_id, rol }` (bug corregido)

---

## ✅ FASE 3 — Capa de Datos Profesional

- [x] `BaseEntity` abstract — `id`, `tenant_id`, `created_at`, `updated_at`, `deleted_at`, `created_by`, `updated_by`
- [x] `BaseRepository<T>` — `findAll`, `findOneById`, `createWithTenant`, `updateWithTenant`, `softDelete`
- [x] Detección dinámica de PK: `repo.metadata.primaryColumns[0].propertyName`
- [x] `tenant_id` + audit columns en las 9 entidades (Grupos A/B/C/D)
- [x] `TypeOrmModule.forFeature([Entity])` en todos los módulos
- [x] Violaciones corregidas: `AlimentosService.findAll`, `UsuariosService.findAll`

---

## ✅ FASE 4 — CRUD Módulos Principales

- [x] `fincas`: POST / GET / GET:id / PATCH / DELETE (PK string manual `pk_id_finca`)
- [x] `animales`: POST / GET / GET:id / PATCH / DELETE (PK `id` auto-gen)
- [x] DTOs con `class-validator`: `CreateFincaDto`, `UpdateFincaDto`, `CreateAnimalDto`, `UpdateAnimalDto`
- [x] `tenant_id` y `created_by`/`updated_by` auto-seteados desde JWT — nunca del cliente
- [x] Soft delete (`deleted_at = NOW()`) en todos los DELETE
- [x] Validado en runtime: aislamiento cross-tenant, auditoría, 401 sin token

---

## ✅ FASE 5 — Observabilidad, Documentación y Calidad

- [x] `GlobalHttpExceptionFilter` — respuestas normalizadas `{ statusCode, message, path, timestamp }`
- [x] `LoggingInterceptor` — logs `[METHOD] /path → statusCode (Xms)` por request
- [x] Swagger/OpenAPI en `/api/docs` con Bearer JWT (`persistAuthorization: true`)
- [x] `@ApiProperty` / `@ApiPropertyOptional` en todos los DTOs existentes
- [x] `@ApiTags` + `@ApiBearerAuth('access-token')` en todos los controllers
- [x] Helmet ajustado: `contentSecurityPolicy: false` para Swagger UI
- [x] Suite de pruebas manual completa (6 suites PowerShell)

---

## 🔲 FASE 6 — CRUD Módulos Restantes + Relaciones

### Objetivo
Completar CRUD para los 7 módulos sin endpoints y exponer relaciones entre entidades.

### Tareas pendientes
- [ ] `potreros`: `CreatePotreroDto`, `UpdatePotreroDto`, 5 endpoints CRUD
- [ ] `alimentos`: `CreateAlimentoDto`, `UpdateAlimentoDto`, agregar POST/PATCH/DELETE (GET ya existe)
- [ ] `salud`: `CreateSaludDto`, `UpdateSaludDto`, 5 endpoints CRUD
- [ ] `reproduccion`: `CreateReproduccionDto`, `UpdateReproduccionDto`, 5 endpoints CRUD
- [ ] `finanzas`: `CreateFinanzaDto`, `UpdateFinanzaDto`, 5 endpoints CRUD
- [ ] `bovino-alimento`: `CreateBovinoAlimentoDto`, controller con asignación/desasignación
- [ ] `usuarios`: `UpdateUsuarioDto`, PATCH `/usuarios/:id` (solo self o rol admin)
- [ ] Cargar relaciones en `findOne`: `Animal → Finca`, `Animal → Potrero` (TypeORM `relations: []`)
- [ ] `GET /fincas/:id/animales` — animales de una finca específica
- [ ] `GET /potreros/:id/animales` — animales de un potrero específico

### Criterio de éxito
- 54+ endpoints activos
- Todos los módulos con CRUD completo y DTOs validados
- Relaciones cargadas donde sea relevante para el frontend

---

## 🔲 FASE 7 — Paginación, Filtrado y Ordenación

### Objetivo
Las listas (`findAll`) soportan paginación, filtros de campo y ordenación.

### Tareas pendientes
- [ ] `PaginationDto`: `page`, `limit`, `sortBy`, `sortOrder` (con class-validator)
- [ ] Extender `BaseRepository.findAll()` para opciones opcionales de paginación/filtro
- [ ] `GET /animales?page=1&limit=10&raza=Brahman&sortBy=created_at&sortOrder=DESC`
- [ ] Respuesta paginada: `{ data: T[], total, page, lastPage }`
- [ ] `@ApiQuery` en controllers para documentar filtros en Swagger

---

## 🔲 FASE 8 — Auth Extendida (Opcional)

### Objetivo
OAuth2 con Google para login sin contraseña (requerimiento académico opcional).

### Tareas pendientes
- [ ] `passport-google-oauth20` + `GoogleStrategy`
- [ ] `POST /auth/google` — intercambia Google ID token por JWT FarmLink
- [ ] Vincular cuenta Google a usuario existente (`PATCH /auth/link-google`)

---

## 🔲 FASE 9 — Production Readiness

### Objetivo
Preparar el backend para deployment en ambiente real.

### Tareas pendientes
- [ ] Eliminar `synchronize: true` → migración TypeORM controlada (`typeorm migration:generate`)
- [ ] Validación de variables de entorno con Joi en `ConfigModule`
- [ ] Rate limiting: `@nestjs/throttler` (100 req/min global, 5 req/min en `/auth/login`)
- [ ] CSP explícita en Helmet para Swagger (reemplazar `contentSecurityPolicy: false`)
- [ ] Logging a archivo/servicio externo (Winston o Pino)
- [ ] Health check: `GET /health` con estado de DB
- [ ] Docker: reparar `docker-compose.yml` + crear `Dockerfile` para backend
- [ ] CI/CD: GitHub Actions — build + lint en cada PR
- [ ] CORS: restringir `origin` al dominio de producción

---

## Reglas de Seguridad Permanentes

1. `tenant_id` **NUNCA** se acepta del cliente — siempre de `@Tenant()` (JWT validado)
2. Todas las queries de dominio incluyen `tenant_id = X AND deleted_at IS NULL`
3. **Prohibido** `delete()` / `remove()` directo — solo `BaseRepository.softDelete()`
4. Métodos auth-específicos (`findByEmail`, `updateRefreshHash`) están exentos del filtro tenant
5. Passwords **nunca** en logs ni respuestas — `@Exclude()` en entidad + `ClassSerializerInterceptor`
