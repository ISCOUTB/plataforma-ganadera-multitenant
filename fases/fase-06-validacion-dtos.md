# Fase 6: Validacion & DTOs

## Estado Actual

- **0 DTOs** en todo el proyecto
- Endpoints aceptan `@Body() body: any` sin validacion
- Sin `class-validator` ni `class-transformer` en `package.json`
- Sin `ValidationPipe` configurado en `main.ts`
- `tsconfig.json` ya tiene `emitDecoratorMetadata: true` (requerido)

---

## Dependencias

```bash
cd Backend
npm install class-validator class-transformer @nestjs/mapped-types @nestjs/swagger
```

---

## Configuracion Global

### `main.ts` -- ValidationPipe

```typescript
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,              // remueve propiedades no declaradas en DTO
  forbidNonWhitelisted: true,   // lanza 400 si propiedades desconocidas
  transform: true,              // auto-transforma payloads a instancias de clase
  transformOptions: {
    enableImplicitConversion: true,  // convierte string "123" a number
  },
  validationError: {
    target: false,              // no expone instancia DTO en errores
    value: false,               // no expone valores enviados en errores
  },
}));
```

### `main.ts` -- Swagger Setup

```typescript
const config = new DocumentBuilder()
  .setTitle('FarmLink API')
  .setDescription('Plataforma de Gestion Ganadera Multitenant')
  .setVersion('1.0')
  .build();
const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup('api/docs', app, document);
```

---

## Validadores Custom

### `Backend/src/common/validators/is-date-not-future.validator.ts`
- Valida que una fecha no sea futura
- Para: `fecha_nacimiento`, `fecha_ingreso`, `fecha_aplicacion`
- Mensaje: `'La fecha no puede ser futura'`

### `Backend/src/common/validators/is-date-after.validator.ts`
- Valida que campo fecha sea posterior a otro campo del mismo DTO
- Para: `fecha_fin_estimada` > `fecha_inicio`, `fecha_proxima_rotacion` > `fecha_rotacion`
- Toma nombre de propiedad de comparacion como argumento

### `Backend/src/common/validators/is-colombian-cedula.validator.ts`
- Valida que string sea 6-10 digitos numericos
- Mensaje: `'La cedula debe contener entre 6 y 10 digitos numericos'`

---

## DTOs por Modulo

### Usuarios

**`create-usuario.dto.ts`**

| Campo | Tipo | Validadores | Swagger |
|-------|------|-------------|---------|
| email | string | `@IsEmail()`, `@IsNotEmpty()` | `@ApiProperty({ example: 'admin@farmlink.co' })` |
| password | string | `@IsString()`, `@MinLength(8)`, `@MaxLength(50)`, `@Matches(/^(?=.*[A-Z])(?=.*\d)/)` | `@ApiProperty({ minLength: 8 })` |
| nombre | string | `@IsString()`, `@IsNotEmpty()`, `@MaxLength(100)`, `@Transform(trim)` | `@ApiProperty()` |
| telefono | string | `@IsOptional()`, `@Matches(/^\+?[0-9]{7,15}$/)` | `@ApiPropertyOptional()` |
| rol | string | `@IsOptional()`, `@IsIn(['admin', 'veterinario', 'operario'])` | `@ApiPropertyOptional({ enum: [...] })` |
| tenant_id | string | `@IsString()`, `@IsNotEmpty()` | `@ApiProperty()` |

**`login-usuario.dto.ts`**: email (`@IsEmail`), password (`@IsString`)

**`update-usuario.dto.ts`**: `OmitType(CreateUsuarioDto, ['email', 'tenant_id'])` + `PartialType`

### Animales

**`create-animal.dto.ts`**

| Campo | Tipo | Validadores |
|-------|------|-------------|
| numero_identificacion | string | `@IsString()`, `@IsNotEmpty()`, `@MaxLength(50)` |
| metodo_identificacion | string | `@IsOptional()`, `@IsIn(['chip', 'arete', 'tatuaje', 'collar'])` |
| fecha_nacimiento | Date | `@IsDateString()`, `@IsNotEmpty()`, `@IsDateNotFuture()` |
| genero | string | `@IsNotEmpty()`, `@IsIn(['m', 'h', 'n'])` |
| peso | number | `@IsNumber({ maxDecimalPlaces: 2 })`, `@Min(0.1)`, `@Max(99999.99)` |
| altura | number | `@IsOptional()`, `@IsNumber()`, `@Min(0.1)` |
| raza | string | `@IsString()`, `@IsNotEmpty()`, `@MaxLength(100)` |
| origen | string | `@IsOptional()`, `@MaxLength(100)` |
| fecha_ingreso | Date | `@IsOptional()`, `@IsDateString()`, `@IsDateNotFuture()` |
| fincaId | string | `@IsString()`, `@IsNotEmpty()`, `@MaxLength(15)` |
| potreroId | string | `@IsOptional()`, `@MaxLength(15)` |

Nota: `edad_actual` es campo computado, NO es input.

**`update-animal.dto.ts`**: `PartialType(OmitType(Create, ['numero_identificacion']))` -- ID animal no cambia

### Fincas

**`create-finca.dto.ts`**

| Campo | Tipo | Validadores |
|-------|------|-------------|
| pk_id_finca | string | `@IsString()`, `@IsNotEmpty()`, `@MaxLength(15)`, `@Matches(/^[a-zA-Z0-9_-]+$/)` |
| nombre_finca | string | `@IsString()`, `@IsNotEmpty()`, `@MaxLength(100)`, `@Transform(trim)` |
| ubicacion | string | `@IsOptional()`, `@MaxLength(150)` |
| propietario | string | `@IsOptional()`, `@MaxLength(100)` |
| area_total | number | `@IsOptional()`, `@IsNumber()`, `@Min(0.01)` |
| fecha_registro | Date | `@IsOptional()`, `@IsDateString()`, `@IsDateNotFuture()` |

### Potreros

**`create-potrero.dto.ts`**

| Campo | Tipo | Validadores |
|-------|------|-------------|
| pk_id_potrero | string | `@IsString()`, `@MaxLength(15)`, `@Matches(/^[a-zA-Z0-9_-]+$/)` |
| nombre_potrero | string | `@IsString()`, `@IsNotEmpty()`, `@MaxLength(100)` |
| area | number | `@IsOptional()`, `@IsNumber()`, `@Min(0.01)` |
| capacidad_animales | number | `@IsInt()`, `@Min(1)`, `@Max(10000)` |
| estado | string | `@IsOptional()`, `@IsIn(['activo', 'en_descanso', 'mantenimiento'])` |
| fecha_rotacion | Date | `@IsOptional()`, `@IsDateString()` |
| fecha_proxima_rotacion | Date | `@IsOptional()`, `@IsDateString()`, `@IsDateAfter('fecha_rotacion')` |
| fincaId | string | `@IsString()`, `@IsNotEmpty()`, `@MaxLength(15)` |

### Salud

**`create-salud.dto.ts`**

| Campo | Tipo | Validadores |
|-------|------|-------------|
| tipo_intervencion | string | `@IsNotEmpty()`, `@IsIn(['vacunacion', 'vitaminas', 'desparasitacion', 'enfermedad'])` |
| descripcion_enfermedad | string | `@IsOptional()`, `@MaxLength(255)`, `@ValidateIf(o => o.tipo_intervencion === 'enfermedad')` + `@IsNotEmpty()` |
| producto_aplicado | string | `@IsOptional()`, `@MaxLength(100)` |
| dosis | string | `@IsOptional()`, `@MaxLength(50)` |
| fecha_aplicacion | Date | `@IsOptional()`, `@IsDateString()`, `@IsDateNotFuture()` |
| fecha_proxima_aplicacion | Date | `@IsOptional()`, `@IsDateString()`, `@IsDateAfter('fecha_aplicacion')` |
| costo | number | `@IsOptional()`, `@IsNumber()`, `@Min(0)` |
| bovinoId | number | `@IsInt()`, `@IsNotEmpty()`, `@Min(1)` |

### Reproduccion

**`create-reproduccion.dto.ts`**

| Campo | Tipo | Validadores |
|-------|------|-------------|
| pk_id_reproduccion | string | `@IsString()`, `@MaxLength(15)` |
| fk_id_padre | string | `@IsOptional()`, `@MaxLength(15)` |
| fk_id_madre | string | `@IsOptional()`, `@MaxLength(15)` |
| metodo_reproduccion | string | `@IsOptional()`, `@IsIn(['monta_natural', 'inseminacion_artificial', 'transferencia_embriones'])` |
| en_celo | boolean | `@IsOptional()`, `@IsBoolean()` |
| prenada | boolean | `@IsOptional()`, `@IsBoolean()` |
| numero_crias | number | `@IsOptional()`, `@IsInt()`, `@Min(0)`, `@Max(4)` |
| fecha_estimado_parto | Date | `@IsOptional()`, `@IsDateString()` |
| bovinoId | number | `@IsInt()`, `@IsNotEmpty()` |

### Finanzas

**`create-finanza.dto.ts`**

| Campo | Tipo | Validadores |
|-------|------|-------------|
| pk_id_finanza | string | `@IsString()`, `@MaxLength(15)` |
| tipo_movimiento | string | `@IsNotEmpty()`, `@IsIn(['ingreso', 'gasto'])` |
| concepto | string | `@IsOptional()`, `@MaxLength(200)`, `@Transform(trim)` |
| categoria | string | `@IsOptional()`, `@MaxLength(50)` |
| monto | number | `@IsNumber()`, `@IsNotEmpty()`, `@Min(0.01)` |
| fecha | Date | `@IsDateString()`, `@IsNotEmpty()` |
| factura | string | `@IsOptional()`, `@MaxLength(100)` |
| metodo_pago | string | `@IsOptional()`, `@IsIn(['efectivo', 'transferencia', 'cheque', 'tarjeta'])` |

### Alimentos

**`create-alimento.dto.ts`**

| Campo | Tipo | Validadores |
|-------|------|-------------|
| pk_id_alimento | string | `@IsString()`, `@MaxLength(15)` |
| tipo_alimento | string | `@IsString()`, `@IsNotEmpty()`, `@MaxLength(100)` |
| cantidad_total | number | `@IsOptional()`, `@IsNumber()`, `@Min(0)` |
| frecuencia | string | `@IsOptional()`, `@IsIn(['diaria', 'semanal', 'quincenal', 'mensual'])` |
| fecha_inicio | Date | `@IsOptional()`, `@IsDateString()` |
| fecha_fin_estimada | Date | `@IsOptional()`, `@IsDateString()`, `@IsDateAfter('fecha_inicio')` |
| costo | number | `@IsOptional()`, `@IsNumber()`, `@Min(0)` |

### Bovino-Alimento

**`create-bovino-alimento.dto.ts`**

| Campo | Tipo | Validadores |
|-------|------|-------------|
| fk_id_bovino | number | `@IsInt()`, `@Min(1)` |
| fk_id_alimento | string | `@IsString()`, `@MaxLength(15)` |
| cantidad | number | `@IsNumber()`, `@Min(0.01)` |
| fecha | Date | `@IsDateString()`, `@IsNotEmpty()` |

### DTO Compartido: Paginacion

**`Backend/src/common/dto/pagination-query.dto.ts`**

| Campo | Tipo | Validadores |
|-------|------|-------------|
| page | number | `@IsOptional()`, `@IsInt()`, `@Min(1)`, `@Type(() => Number)` |
| limit | number | `@IsOptional()`, `@IsInt()`, `@Min(1)`, `@Max(100)`, `@Type(() => Number)` |

---

## Inventario Total de Archivos

### Infraestructura comun (7)
1. `common/validators/is-colombian-cedula.validator.ts`
2. `common/validators/is-date-not-future.validator.ts`
3. `common/validators/is-date-after.validator.ts`
4. `common/validators/index.ts`
5. `common/filters/http-exception.filter.ts`
6. `common/filters/index.ts`
7. `common/dto/pagination-query.dto.ts`

### DTOs por modulo (27)
- usuarios: create, update, login, index (4)
- animales: create, update, index (3)
- fincas: create, update, index (3)
- potreros: create, update, index (3)
- salud: create, update, index (3)
- reproduccion: create, update, index (3)
- finanzas: create, update, index (3)
- alimentos: create, update, index (3)
- bovino-alimento: create, update, index (3)

### Archivos a modificar (2)
- `Backend/src/main.ts` -- ValidationPipe, Swagger
- `Backend/package.json` -- 4 dependencias

**Total: 35 archivos nuevos + 2 modificados**

---

## Secuencia de Implementacion

| Fase | Accion |
|------|--------|
| 1 | Instalar dependencias |
| 2 | Configurar main.ts (ValidationPipe + Swagger) |
| 3 | Crear exception filter y custom validators |
| 4 | Crear DTOs para modulos con controllers funcionando (usuarios, alimentos) |
| 5 | Actualizar controllers existentes: reemplazar `body: any` con DTOs |
| 6 | Crear DTOs para modulos con controllers vacios |
| 7 | Crear DTOs para modulos sin controller |
| 8 | Crear PaginationQueryDto |
