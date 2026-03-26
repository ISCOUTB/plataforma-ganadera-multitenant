# Fase 9: Documentacion API (Swagger/OpenAPI)

## Estado Actual

- Sin `@nestjs/swagger` en `package.json`
- Sin DTOs, sin decoradores `@ApiProperty`
- Sin versionamiento de API
- Sin prefijo global
- Sin CORS
- Endpoints en espanol (`/usuarios/login`, `/alimentos`)

---

## Dependencia

```bash
cd Backend && npm install @nestjs/swagger class-validator class-transformer
```

---

## Configuracion en `main.ts`

### Global Prefix + Versionamiento
```typescript
app.setGlobalPrefix('api/v1', { exclude: ['/'] });
```

### Swagger DocumentBuilder
```typescript
const config = new DocumentBuilder()
  .setTitle('FarmLink API')
  .setDescription('API de Gestion Ganadera Multitenant - UTB')
  .setVersion('1.0')
  .addBearerAuth({ type: 'http', scheme: 'bearer', bearerFormat: 'JWT' }, 'JWT-auth')
  .addTag('Usuarios', 'Autenticacion y gestion de usuarios')
  .addTag('Fincas', 'Gestion de fincas ganaderas')
  .addTag('Animales', 'Registro y seguimiento de bovinos')
  .addTag('Potreros', 'Gestion de potreros y rotacion')
  .addTag('Alimentos', 'Alimentacion y dietas')
  .addTag('Salud', 'Intervenciones sanitarias')
  .addTag('Reproduccion', 'Control reproductivo')
  .addTag('Finanzas', 'Movimientos financieros')
  .addTag('Bovino-Alimento', 'Asignacion alimento-bovino')
  .addServer('http://localhost:3000', 'Local Development')
  .build();

SwaggerModule.setup('api/docs', app, document, {
  swaggerOptions: {
    persistAuthorization: true,
    docExpansion: 'list',
    filter: true,
    tagsSorter: 'alpha',
  },
});
```

**Swagger UI:** `http://localhost:3000/api/docs`
**OpenAPI JSON:** `http://localhost:3000/api/docs-json`

---

## Response Envelope Estandar

### Exito
```json
{
  "data": { ... },
  "meta": {
    "timestamp": "2026-03-26T...",
    "path": "/api/v1/usuarios",
    "version": "1.0"
  }
}
```

### Error
```json
{
  "error": "Unauthorized",
  "message": "Credenciales invalidas",
  "statusCode": 401,
  "timestamp": "2026-03-26T...",
  "path": "/api/v1/usuarios/login"
}
```

### Archivos para envelope

| Archivo | Proposito |
|---------|-----------|
| `common/interceptors/response-transform.interceptor.ts` | Wrapper de respuestas exitosas |
| `common/filters/http-exception.filter.ts` | Formato de errores |
| `common/dto/api-response.dto.ts` | Schemas Swagger para envelopes |
| `common/dto/pagination.dto.ts` | PaginationQueryDto + PaginatedMetaDto |

---

## Decoradores Swagger por Controller

### Patron Estandar por Operacion

**POST (crear):**
```typescript
@ApiOperation({ summary: 'Crear [entidad]' })
@ApiBody({ type: Create[Entity]Dto })
@ApiResponse({ status: 201, description: '[Entidad] creada exitosamente' })
@ApiResponse({ status: 400, description: 'Datos invalidos' })
```

**GET lista:**
```typescript
@ApiOperation({ summary: 'Listar [entidades]' })
@ApiResponse({ status: 200, description: 'Lista de [entidades]' })
```

**GET por id:**
```typescript
@ApiOperation({ summary: 'Obtener [entidad] por ID' })
@ApiParam({ name: 'id', description: 'ID del [entidad]' })
@ApiResponse({ status: 200 })
@ApiResponse({ status: 404, description: 'No encontrado' })
```

**PATCH actualizar:**
```typescript
@ApiOperation({ summary: 'Actualizar [entidad]' })
@ApiParam({ name: 'id' })
@ApiBody({ type: Update[Entity]Dto })
@ApiResponse({ status: 200 })
@ApiResponse({ status: 404 })
```

**DELETE:**
```typescript
@ApiOperation({ summary: 'Eliminar [entidad]' })
@ApiParam({ name: 'id' })
@ApiResponse({ status: 200 })
@ApiResponse({ status: 404 })
```

### Controllers a Decorar

| Controller | Tag | Decoradores |
|------------|-----|-------------|
| `app.controller.ts` | Health | `@ApiTags('Health')`, `@ApiOperation` en getHello |
| `usuarios.controller.ts` | Usuarios | Decorar 3 metodos existentes + agregar findOne, update, delete |
| `alimentos.controller.ts` | Alimentos | Decorar findAll + agregar CRUD stubs |
| `finanzas.controller.ts` | Finanzas | Llenar con CRUD + Swagger |
| `salud.controller.ts` | Salud | Llenar con CRUD + Swagger |
| `reproduccion.controller.ts` | Reproduccion | Llenar con CRUD + Swagger |
| **Nuevos:** | | |
| `fincas.controller.ts` | Fincas | Crear con CRUD completo + Swagger |
| `animales.controller.ts` | Animales | Crear con CRUD completo + Swagger |
| `potreros.controller.ts` | Potreros | Crear con CRUD completo + Swagger |
| `bovino-alimento.controller.ts` | Bovino-Alimento | Crear con CRUD + Swagger |

---

## `@ApiProperty` en Entidades

Agregar a CADA `@Column` de las 9 entidades:

```typescript
@ApiProperty({ example: 'juan@finca.com', description: 'Email unico del usuario' })
@Column({ unique: true })
email: string;

@ApiHideProperty()  // NUNCA exponer en respuestas
@Column()
password: string;
```

**Archivos a modificar:** 9 archivos de entidad

---

## DTOs con Swagger

Cada DTO usa `@ApiProperty` o `@ApiPropertyOptional` con `example`:

```typescript
@ApiProperty({ example: 'Hacienda La Esperanza', maxLength: 100 })
@IsString()
@IsNotEmpty()
nombre_finca: string;

@ApiPropertyOptional({ example: 250.5, description: 'Area en hectareas' })
@IsOptional()
@IsNumber()
area_total?: number;
```

Para UpdateDTOs: usar `PartialType` de `@nestjs/swagger` (no de `@nestjs/mapped-types`) -- preserva metadata de Swagger.

---

## Export para Postman/Insomnia

### Automatico
El JSON de OpenAPI en `http://localhost:3000/api/docs-json` se puede importar directamente en Postman e Insomnia.

### Script de export estatico

**Crear:** `Backend/src/swagger-export.ts`

Script standalone que:
1. Boota la app NestJS
2. Extrae documento Swagger via `SwaggerModule.createDocument()`
3. Escribe a `Backend/docs/openapi.json`
4. Sale

**Script npm:** `"swagger:export": "ts-node src/swagger-export.ts"`

### Directorio de documentacion

```
Backend/docs/
  openapi.json           -- Spec generada
  API_CHANGELOG.md       -- Changelog de la API
  README.md              -- Instrucciones de import
```

---

## API Changelog

**Crear:** `Backend/docs/API_CHANGELOG.md`

```markdown
# API Changelog

## [1.0.0] - 2026-03-26

### Added
- Documentacion Swagger/OpenAPI 3.0
- Prefijo global /api/v1/
- Response envelope estandar {data, meta}
- Validacion DTO en todos los endpoints
- CRUD: Usuarios, Fincas, Animales, Potreros, Alimentos,
  Salud, Reproduccion, Finanzas, Bovino-Alimento
- Configuracion Bearer token (enforcement pendiente)

### Changed
- Todas las rutas prefijadas con /api/v1/

### Security
- Validacion de input via class-validator
- Password excluido de respuestas API
```

---

## Inventario de Archivos

### Nuevos (30+)
- 4 archivos de infraestructura comun (interceptor, filter, response DTOs, pagination DTO)
- 17 archivos DTO (ver Fase 6)
- 4 controllers nuevos (fincas, animales, potreros, bovino-alimento)
- 1 swagger export script
- 2 archivos de docs (changelog, readme)
- 1 common.module.ts

### Modificar (14)
- `main.ts` -- Swagger, prefix, CORS, pipes, interceptor, filter
- `package.json` -- 3 dependencias
- `app.module.ts` -- importar CommonModule
- `app.controller.ts` -- `@ApiTags`, `@ApiOperation`
- 5 controllers existentes -- agregar decoradores Swagger
- 3 modules -- registrar controllers nuevos
- 9 entities -- agregar `@ApiProperty`

---

## Secuencia

1. Instalar dependencias
2. Crear infraestructura comun (interceptor, filter, DTOs)
3. Crear todos los DTOs (Fase 6)
4. Modificar `main.ts` (prefix, Swagger, pipes)
5. Agregar `@ApiProperty` a entidades
6. Decorar controllers existentes
7. Crear controllers faltantes con Swagger completo
8. Actualizar modules
9. Probar Swagger UI en `http://localhost:3000/api/docs`
10. Crear docs/ con export y changelog

---

## Impacto en Frontend

**BREAKING CHANGE:** Agregar `/api/v1/` como prefijo rompe el frontend actual.

- `api_service.dart` debe cambiar baseUrl de `http://localhost:3000` a `http://localhost:3000/api/v1`
- Response envelope `{data, meta}` significa que frontend accede `response.data.data` en vez de `response.data`
- Coordinar deploy con actualizacion frontend
