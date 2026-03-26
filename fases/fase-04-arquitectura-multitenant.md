# Fase 4: Arquitectura Multi-tenant

## Estado Actual

- `Usuario.tenant_id` es un string plano sin FK
- Ninguna otra entidad tiene `tenant_id`
- Frontend hardcodea `'finca1'` en `api_service.dart`
- No existe aislamiento de datos a ningun nivel
- `findAll()` retorna TODOS los registros de TODOS los tenants

---

## Estrategia: Row-Level Isolation con `tenant_id` FK a Finca

**Finca = Tenant.** Cada finca ES un tenant. `pk_id_finca` se convierte en `tenant_id` FK en cada tabla.

Razones para elegir row-level sobre schema-per-tenant:
- Schema-per-tenant es excesivo para proyecto academico con un solo PostgreSQL
- Row-level es el patron estandar para SaaS con cantidad moderada de tenants
- Una sola BD, un solo schema, un solo connection pool
- Simple query scoping con TypeORM

---

## Plan de Implementacion

### Fase 1: Clase Base Tenant-Aware

**Crear:** `Backend/src/common/entities/tenant-base.entity.ts`

Clase abstracta con:
- `@Column({ name: 'tenant_id' }) tenant_id: string`
- `@ManyToOne(() => Finca)` relation usando `tenant_id` como join column
- `@Index()` en `tenant_id`

**Entidades que extienden esta clase (8):**
1. Animal
2. Potrero
3. Alimento
4. Salud
5. Finanza
6. Reproduccion
7. BovinoAlimento
8. Usuario (ya tiene `tenant_id`, convertir a FK)

**Finca NO extiende** -- ella ES el tenant.

### Fase 2: Middleware de Resolucion de Tenant

**Flujo:** `Request -> JWT Guard -> TenantGuard -> extrae tenant_id del JWT -> CLS context -> Controller`

**Archivos nuevos:**

1. `Backend/src/common/middleware/tenant.middleware.ts`
   - Lee `req.user.tenant_id` (establecido por Passport JWT)
   - Establece `req.tenantId` en el request
   - Lanza `ForbiddenException` si no hay `tenant_id`

2. `Backend/src/common/interfaces/tenant-request.interface.ts`
   - Extiende Express `Request` con `tenantId: string` y `user`

3. `Backend/src/common/decorators/tenant-id.decorator.ts`
   - `@TenantId()` parameter decorator via `createParamDecorator`
   - Uso: `@Get() findAll(@TenantId() tenantId: string)`

### Fase 3: Propagacion de Contexto con `@nestjs/cls`

**Instalar:** `npm install nestjs-cls`

**Por que CLS en vez de pasar parametro?** Pasar `tenantId` a cada metodo de servicio es fragil y facil de olvidar. CLS proporciona un almacen de contexto async que se propaga automaticamente.

**Archivos nuevos:**

4. `Backend/src/common/tenant/tenant-cls.module.ts`
   - Configura `ClsModule.forRoot()` con middleware

5. `Backend/src/common/tenant/tenant-cls.service.ts`
   - Servicio inyectable wrapping `ClsService`
   - Metodos: `getTenantId(): string`, `setTenantId(id): void`

6. `Backend/src/common/tenant/tenant.module.ts`
   - Exporta `TenantClsService`

### Fase 4: Scoping Automatico de Queries TypeORM

**Mecanismo A: TypeORM Subscriber**

7. `Backend/src/common/tenant/tenant.subscriber.ts`
   - `afterLoad`: valida que entidad cargada coincide con tenant actual
   - `beforeInsert`: estampa `tenant_id` automaticamente
   - `beforeUpdate`: previene cambio de `tenant_id`

**Mecanismo B: TenantScopedRepository**

8. `Backend/src/common/tenant/tenant-scoped.repository.ts`
   - Extiende `Repository<T>` donde T extiende `TenantBaseEntity`
   - Override de `find`, `findOne`, `findAndCount`, `save`, `update`, `delete`
   - Automaticamente inyecta condicion `tenant_id` en cada query
   - Automaticamente estampa `tenant_id` antes de `save`

9. `Backend/src/common/tenant/tenant-scoped-repository.provider.ts`
   - Factory: `provideTenantRepository(entity)` que crea custom provider
   - Los modulos usan esto en vez de `TypeOrmModule.forFeature()`

### Fase 5: Modulo Auth (Prerequisito)

10-18. Archivos del modulo auth (ver Fase 1 de Seguridad)

**Payload JWT:**
```json
{ "sub": "userId", "email": "string", "tenant_id": "string", "rol": "string" }
```

### Fase 6: Flujo de Aprovisionamiento de Tenant

19. `Backend/src/tenant/tenant.module.ts`
20. `Backend/src/tenant/tenant.service.ts`
21. `Backend/src/tenant/tenant.controller.ts`
22. `Backend/src/tenant/dto/create-tenant.dto.ts`

**Flujo `POST /tenant/provision`:**
1. Validar input: nombre finca, email admin, password, ubicacion
2. Iniciar transaccion de BD
3. Crear registro `Finca` con `pk_id_finca` generado
4. Crear registro `Usuario` con `rol: 'owner'`, `tenant_id` = nueva finca PK
5. Hash password con bcrypt
6. Commit transaccion
7. Retornar JWT token para el nuevo admin

Este endpoint es `@Public()` (sin contexto de tenant necesario).

### Fase 7: Validacion de Aislamiento de Datos

23. `Backend/src/common/guards/cross-tenant.guard.ts`
   - Valida que parametros de URL pertenecen al tenant actual
   - Previene ataques IDOR

24. `Backend/src/common/interceptors/tenant-response.interceptor.ts`
   - Strip de `tenant_id` de payloads de respuesta

25. `Backend/src/common/pipes/tenant-validation.pipe.ts`
   - Valida que `tenant_id` en body del request coincide con usuario autenticado

**PostgreSQL RLS (defensa secundaria):**

26. `Backend/src/migrations/add-rls-policies.ts`
   - `CREATE POLICY tenant_isolation ON <tabla> USING (tenant_id = current_setting('app.current_tenant'))`

---

## Cambios en Frontend

### Token Storage y Header

**Modificar:** `Frontend/lib/services/api_service.dart`
- Almacenar JWT del login/registro
- Agregar `Authorization: Bearer <token>` via Dio interceptor
- Remover hardcoded `'tenant_id': 'finca1'`

**Crear:** `Frontend/lib/services/auth_service.dart`
- Singleton de estado auth
- Parsea JWT payload para extraer `tenant_id`

**Crear:** `Frontend/lib/providers/tenant_provider.dart`
- Mantiene info del tenant actual (nombre finca, id)

---

## Resumen de Archivos

### Backend Nuevos (26)
```
common/entities/tenant-base.entity.ts
common/middleware/tenant.middleware.ts
common/interfaces/tenant-request.interface.ts
common/decorators/tenant-id.decorator.ts
common/decorators/public.decorator.ts
common/guards/cross-tenant.guard.ts
common/interceptors/tenant-response.interceptor.ts
common/pipes/tenant-validation.pipe.ts
common/tenant/tenant-cls.module.ts
common/tenant/tenant-cls.service.ts
common/tenant/tenant.module.ts
common/tenant/tenant.subscriber.ts
common/tenant/tenant-scoped.repository.ts
common/tenant/tenant-scoped-repository.provider.ts
auth/auth.module.ts
auth/auth.service.ts
auth/auth.controller.ts
auth/strategies/jwt.strategy.ts
auth/guards/jwt-auth.guard.ts
auth/guards/tenant.guard.ts
auth/dto/login.dto.ts
auth/dto/register.dto.ts
tenant/tenant.module.ts
tenant/tenant.service.ts
tenant/tenant.controller.ts
tenant/dto/create-tenant.dto.ts
```

### Backend Modificar (12)
```
app.module.ts -- ClsModule, AuthModule, TenantModule, guards globales
main.ts -- CORS, ValidationPipe
usuarios/entities/usuario.entity.ts -- FK a Finca
animales/entities/animal.entity.ts -- extend TenantBaseEntity
potreros/entities/potrero.entity.ts
alimentos/entities/alimento.entity.ts
salud/entities/salud.entity.ts
finanzas/entities/finanza.entity.ts
reproduccion/entities/reproduccion.entity.ts
bovino-alimento/entities/bovino-alimento.entity.ts
fincas/entities/finca.entity.ts -- agregar activo, OneToMany Usuario
usuarios/usuarios.service.ts -- usar TenantScopedRepository
```

### Frontend Nuevos (3)
```
services/auth_service.dart
providers/tenant_provider.dart
screens/Finca_setup_screen.dart
```

### Frontend Modificar (4)
```
services/api_service.dart
screens/Login_screen.dart
screens/Registro_screen.dart
screens/Dashboard_screen.dart
```

---

## Orden de Implementacion

1. Instalar dependencias npm
2. Crear `TenantBaseEntity`
3. Modificar 8 archivos de entidades
4. Modificar entidad `Finca`
5. Crear modulo CLS/Tenant context
6. Crear `TenantScopedRepository`
7. Crear modulo Auth (JWT, guards)
8. Crear Tenant middleware y decoradores
9. Crear `TenantGuard`
10. Crear modulo de aprovisionamiento
11. Actualizar `app.module.ts`
12. Actualizar `main.ts`
13. Frontend: `auth_service.dart`
14. Frontend: `api_service.dart` con Bearer header
15. Frontend: Login/Registro manejan JWT
16. Frontend: Dashboard con datos reales del tenant
