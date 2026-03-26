# Fase 1: Seguridad & Autenticacion

## Estado Actual

### Vulnerabilidades Criticas

1. **Contrasenas en texto plano**: `usuarios.service.ts` linea 22 compara `usuario.password !== password` directamente
2. **Sin autenticacion**: No hay JWT, sesiones ni tokens. El login retorna el objeto Usuario completo (incluyendo la contrasena)
3. **Sin guards de autorizacion**: Todos los endpoints son publicos. `GET /usuarios` retorna todos los usuarios con sus contrasenas
4. **Sin CORS**: `main.ts` no tiene `app.enableCors()`
5. **Sin headers de seguridad**: No hay Helmet ni CSP
6. **Sin rate limiting**: Endpoint de login vulnerable a fuerza bruta
7. **Sin validacion de input**: Controllers aceptan `@Body() body: any`
8. **Sin aislamiento de tenant**: `findAll()` retorna todos los usuarios de todos los tenants
9. **Frontend sin almacenamiento de token**: `api_service.dart` no guarda ningun token
10. **Contrasena expuesta en respuestas API**: `registro()` y `login()` retornan el objeto completo con `password`

### Infraestructura Existente Aprovechable

- `@nestjs/config` con `ConfigModule.forRoot({ isGlobal: true })` ya configurado
- Entidad `Usuario` tiene `rol: string` (default `'admin'`) y `tenant_id: string`
- `docker-compose.yml` ya referencia `JWT_SECRET` y `JWT_REFRESH_SECRET`
- NestJS 11 soporta todos los patrones modernos de guard/strategy

---

## Dependencias a Instalar

```bash
cd Backend
npm install bcrypt @nestjs/jwt @nestjs/passport passport passport-jwt class-validator class-transformer helmet @nestjs/throttler
npm install -D @types/bcrypt @types/passport-jwt
```

| Paquete | Proposito |
|---------|-----------|
| `bcrypt` + `@types/bcrypt` | Hash de contrasenas (10-12 salt rounds) |
| `@nestjs/jwt` | Wrapper NestJS sobre `jsonwebtoken` |
| `@nestjs/passport` + `passport` + `passport-jwt` | Integracion Passport con JWT strategy |
| `class-validator` + `class-transformer` | Validacion de DTOs con decoradores |
| `helmet` | Headers HTTP de seguridad |
| `@nestjs/throttler` | Rate limiting nativo de NestJS |

---

## Plan de Implementacion

### Paso 1: Variables de Entorno

**Modificar:** `Backend/.env`

```env
# Agregar a las variables DB existentes:
JWT_SECRET=<string-aleatorio-minimo-32-caracteres>
JWT_REFRESH_SECRET=<otro-string-aleatorio-diferente>
JWT_EXPIRATION=15m
JWT_REFRESH_EXPIRATION=7d
```

### Paso 2: Configuracion de `main.ts`

**Modificar:** `Backend/src/main.ts`

Agregar entre `NestFactory.create()` y `app.listen()`:

- `app.enableCors({ origin: ['http://localhost:3000', 'http://localhost:8080'], credentials: true })`
- `app.use(helmet())`
- `app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }))`

### Paso 3: Configuracion de `app.module.ts`

**Modificar:** `Backend/src/app.module.ts`

- Importar `ThrottlerModule.forRoot([{ ttl: 60000, limit: 10 }])`
- Importar el nuevo `AuthModule`
- Registrar guards globales: `{ provide: APP_GUARD, useClass: JwtAuthGuard }` y `{ provide: APP_GUARD, useClass: ThrottlerGuard }`
- Remover `TypeOrmModule.forFeature([...])` de lineas 46-49 (error existente)

---

## Archivos Nuevos a Crear (14 archivos)

### Estructura de Directorios

```
Backend/src/auth/
  auth.module.ts
  auth.service.ts
  auth.controller.ts
  strategies/
    jwt.strategy.ts
    jwt-refresh.strategy.ts
  guards/
    jwt-auth.guard.ts
    jwt-refresh.guard.ts
    roles.guard.ts
    tenant.guard.ts
  decorators/
    roles.decorator.ts
    current-user.decorator.ts
    public.decorator.ts
  dto/
    login.dto.ts
    registro.dto.ts
    refresh-token.dto.ts
Backend/src/scripts/
  migrate-passwords.ts
```

### Detalle de Cada Archivo

#### `auth.module.ts`
- Importa `JwtModule.registerAsync()` usando `ConfigService` para inyectar `JWT_SECRET`
- Importa `PassportModule.register({ defaultStrategy: 'jwt' })`
- Importa `UsuariosModule` (debe exportar `UsuariosService`)
- Providers: `AuthService`, `JwtStrategy`, `JwtRefreshStrategy`
- Controllers: `AuthController`
- Exports: `AuthService`, `JwtModule`, `PassportModule`

#### `auth.service.ts`
- Inyecta `UsuariosService`, `JwtService`, `ConfigService`
- `registro(dto)`: Hash con `bcrypt.hash(dto.password, 10)`, crea usuario, genera tokens
- `login(dto)`: Busca por email, compara con `bcrypt.compare()`, genera tokens
- `refreshTokens(userId, refreshToken)`: Valida refresh token, genera nuevo par
- `generateTokens(usuario)`: Payload JWT = `{ sub: id, email, rol, tenant_id }`
- `logout(userId)`: Anula el `refresh_token_hash` almacenado

#### `auth.controller.ts`
- `@Controller('auth')`
- `POST /auth/registro` -> `{ access_token, refresh_token, usuario }`
- `POST /auth/login` -> tokens
- `POST /auth/refresh` -> protegido por refresh guard
- `POST /auth/logout` -> protegido por JWT guard
- `@Throttle({ default: { limit: 5, ttl: 60000 } })` en login y registro

#### `jwt.strategy.ts`
- Extiende `PassportStrategy(Strategy, 'jwt')`
- Lee `JWT_SECRET` de `ConfigService`
- `jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken()`
- `validate(payload)`: Retorna `{ userId: payload.sub, email, rol, tenant_id }`

#### `jwt-refresh.strategy.ts`
- Usa `JWT_REFRESH_SECRET`
- `passReqToCallback: true` para acceder al raw refresh token

#### `jwt-auth.guard.ts`
- Extiende `AuthGuard('jwt')`
- Verifica metadata `IS_PUBLIC_KEY` via `Reflector` para rutas publicas

#### `roles.guard.ts`
- Implementa `CanActivate`
- Lee metadata `roles` del handler via `Reflector`
- Compara `request.user.rol` contra los roles requeridos

#### `tenant.guard.ts`
- Verifica que `request.user.tenant_id === request.params.tenantId`
- Previene acceso cross-tenant

#### Decoradores
- `@Roles(...roles)`: `SetMetadata('roles', roles)`
- `@CurrentUser()`: `createParamDecorator` que extrae `req.user`
- `@Public()`: `SetMetadata('isPublic', true)` para rutas sin auth

#### DTOs
- `RegistroDto`: `@IsEmail()` email, `@MinLength(8)` password, `@IsNotEmpty()` nombre, `@IsOptional()` telefono, `@IsNotEmpty()` tenant_id
- `LoginDto`: `@IsEmail()` email, `@IsString()` password
- `RefreshTokenDto`: `@IsString() @IsNotEmpty()` refresh_token

---

## Archivos Existentes a Modificar (8 archivos)

| Archivo | Cambios |
|---------|---------|
| `Backend/package.json` | Agregar 9 dependencias |
| `Backend/.env` | Agregar JWT_SECRET, JWT_REFRESH_SECRET, etc. |
| `Backend/src/main.ts` | CORS, Helmet, ValidationPipe, ClassSerializerInterceptor |
| `Backend/src/app.module.ts` | Importar AuthModule, ThrottlerModule, guards globales |
| `Backend/src/app.controller.ts` | Agregar `@Public()` al health check |
| `Backend/src/usuarios/entities/usuario.entity.ts` | Enum Rol, refresh_token_hash, `@Exclude` en campos sensibles |
| `Backend/src/usuarios/usuarios.service.ts` | Refactorizar a metodos de data-access |
| `Backend/src/usuarios/usuarios.module.ts` | Agregar `exports: [UsuariosService]` |
| `Backend/src/usuarios/usuarios.controller.ts` | Remover rutas auth, agregar guards |

---

## Cambios en Entidad Usuario

```
// Agregar enum
enum Rol { ADMIN = 'admin', VETERINARIO = 'veterinario', TRABAJADOR = 'trabajador' }

// Modificar columna rol
@Column({ type: 'enum', enum: Rol, default: Rol.ADMIN })

// Agregar columna
@Column({ nullable: true })
refresh_token_hash: string;

// Decoradores de exclusion
@Exclude() password
@Exclude() refresh_token_hash
```

---

## Refactorizacion de UsuariosService

Remover `login()` y `registro()` (se mueven a `AuthService`). Convertir a metodos de data-access:

- `findByEmail(email): Promise<Usuario | null>`
- `crear(data: Partial<Usuario>): Promise<Usuario>`
- `findAll(tenantId): Promise<Usuario[]>` -- filtrar por tenant_id
- `findById(id): Promise<Usuario | null>`
- `updateRefreshToken(userId, hash | null): Promise<void>`

---

## Orden de Implementacion

| # | Accion | Archivos |
|---|--------|----------|
| 1 | Instalar paquetes npm | `package.json` |
| 2 | Agregar variables de entorno | `.env` |
| 3 | Crear Enum Rol | `usuario.entity.ts` |
| 4 | Actualizar entidad Usuario | `usuario.entity.ts` |
| 5 | Refactorizar UsuariosService | `usuarios.service.ts` |
| 6 | Exportar UsuariosService | `usuarios.module.ts` |
| 7 | Crear DTOs | `auth/dto/*.ts` |
| 8 | Crear JWT strategy | `auth/strategies/jwt.strategy.ts` |
| 9 | Crear JWT refresh strategy | `auth/strategies/jwt-refresh.strategy.ts` |
| 10 | Crear guards | `auth/guards/*.ts` |
| 11 | Crear decoradores | `auth/decorators/*.ts` |
| 12 | Crear AuthService | `auth/auth.service.ts` |
| 13 | Crear AuthController | `auth/auth.controller.ts` |
| 14 | Crear AuthModule | `auth/auth.module.ts` |
| 15 | Actualizar AppModule | `app.module.ts` |
| 16 | Actualizar main.ts | `main.ts` |
| 17 | Actualizar UsuariosController | `usuarios.controller.ts` |
| 18 | Marcar health check como `@Public()` | `app.controller.ts` |
| 19 | Crear script de migracion | `scripts/migrate-passwords.ts` |
| 20 | Ejecutar migracion de contrasenas | CLI |

---

## Decisiones Arquitectonicas

| Decision | Justificacion |
|----------|--------------|
| Passport + Strategy pattern | Abstraccion estandar de NestJS. `JwtStrategy.validate()` puebla `request.user` automaticamente |
| Guard global con `@Public()` opt-out | "Seguro por defecto". Olvidar agregar un guard no crea agujero de seguridad |
| Hash de refresh tokens en BD | Si la BD es comprometida, los tokens no son utilizables directamente |
| `tenant_id` en payload JWT | Evita lookup a BD en cada request para determinar tenant |
| `@nestjs/throttler` sobre express-rate-limit | Solucion nativa de NestJS, integrada con guards |

---

## Riesgos y Mitigaciones

| Riesgo | Mitigacion |
|--------|-----------|
| `synchronize: true` alterara tabla `usuarios` automaticamente | Aceptable en desarrollo, desactivar en produccion |
| Frontend se rompe (login cambia de `/usuarios/login` a `/auth/login`) | Actualizar `api_service.dart` en coordinacion |
| Usuarios existentes no pueden loguearse post-hash | Ejecutar script de migracion inmediatamente despues del deploy |
