# Fase 3: API CRUD Completa

## Estado Actual

| Modulo | Entidad | Controller | Service | Logica | Endpoints |
|--------|---------|------------|---------|--------|-----------|
| usuarios | OK | OK | OK | registro, login, findAll | 3 |
| alimentos | OK | GET only | findAll | Solo lectura | 1 |
| fincas | OK | **FALTA** | **VACIO** | Ninguna | 0 |
| animales | OK | **FALTA** | **VACIO** | Ninguna | 0 |
| potreros | OK | **FALTA** | **VACIO** | Ninguna | 0 |
| salud | OK | **VACIO** | **VACIO** | Ninguna | 0 |
| reproduccion | OK | **VACIO** | **VACIO** | Ninguna | 0 |
| finanzas | OK | **VACIO** | **VACIO** | Ninguna | 0 |
| bovino-alimento | OK | **FALTA** | **FALTA** | Solo entidad | 0 |
| **app** | - | OK | OK | Health check | 1 |
| **TOTAL** | | | | | **5** |

**Deficiencias estructurales:**
- 6 de 8 modulos faltan `TypeOrmModule.forFeature()` en su modulo
- Sin DTOs en ningun lugar
- Sin ValidationPipe global
- Sin prefijo global (`/api/v1/`)
- Sin paginacion
- Sin filtrado por tenant

---

## Decisiones de Diseno

### Nomenclatura: Mantener Espanol

Los endpoints usan nombres en espanol para los recursos (coinciden con entidades/tablas):
- `/fincas`, `/animales`, `/potreros`, `/salud`, `/reproduccion`, `/finanzas`, `/alimentos`

Usar ingles para: query params (`page`, `limit`, `sort`, `order`, `search`) y keys de respuesta (`data`, `meta`, `total`).

### Estructura de URL

```
/api/v1/{recurso}               -- coleccion
/api/v1/{recurso}/:id           -- item individual
/api/v1/{padre}/:id/{hijo}      -- recursos anidados
```

### Formato de Paginacion

```json
{
  "data": [...],
  "meta": {
    "total": 150,
    "page": 1,
    "limit": 20,
    "totalPages": 8
  }
}
```

---

## Infraestructura Prerequisita

### Instalar dependencias

```bash
cd Backend && npm install class-validator class-transformer
```

### Modificar `main.ts`

```typescript
app.setGlobalPrefix('api/v1');
app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
app.enableCors();
```

### Crear infraestructura compartida

```
Backend/src/common/
  dto/pagination-query.dto.ts       -- page, limit, sort, order
  interfaces/paginated-result.interface.ts
  helpers/pagination.helper.ts      -- utility con Repository + PaginationQuery
  decorators/tenant-id.decorator.ts -- extrae X-Tenant-Id de headers
```

---

## Plan Completo de Endpoints por Modulo

### Modulo 1: FINCAS (Raiz del tenant)

**Archivos a crear:**
- `Backend/src/fincas/fincas.controller.ts`
- `Backend/src/fincas/dto/create-finca.dto.ts`
- `Backend/src/fincas/dto/update-finca.dto.ts`

**Archivos a modificar:**
- `Backend/src/fincas/fincas.service.ts` (reescribir desde vacio)
- `Backend/src/fincas/fincas.module.ts` (agregar TypeOrmModule.forFeature, controller)

| Metodo | Ruta | Proposito | Status |
|--------|------|-----------|--------|
| GET | `/api/v1/fincas` | Listar fincas (paginado) | 200 |
| GET | `/api/v1/fincas/:id` | Detalle de finca con conteos | 200/404 |
| POST | `/api/v1/fincas` | Crear finca | 201 |
| PUT | `/api/v1/fincas/:id` | Actualizar finca | 200/404 |
| DELETE | `/api/v1/fincas/:id` | Eliminar finca | 200/404 |

**CreateFincaDto:** `pk_id_finca` (req, max 15), `nombre_finca` (req, max 100), `ubicacion`, `propietario`, `area_total` (number), `fecha_registro`

### Modulo 2: ANIMALES

**Archivos a crear:** controller, create-dto, update-dto
**Archivos a modificar:** service (reescribir), module

| Metodo | Ruta | Proposito | Status |
|--------|------|-----------|--------|
| GET | `/api/v1/animales` | Listar animales (paginado, filtrable) | 200 |
| GET | `/api/v1/animales/:id` | Detalle con finca y potrero | 200/404 |
| POST | `/api/v1/animales` | Registrar animal | 201 |
| PUT | `/api/v1/animales/:id` | Actualizar animal | 200/404 |
| DELETE | `/api/v1/animales/:id` | Eliminar animal | 200/404 |
| GET | `/api/v1/fincas/:fincaId/animales` | Animales por finca | 200 |

**Filtros:** `genero`, `raza`, `fincaId`, `potreroId`
**CreateAnimalDto:** `numero_identificacion` (req), `fecha_nacimiento` (req), `genero` (req, enum m|h|n), `peso` (req), `raza` (req), `fincaId` (req), `potreroId`, `altura`, `origen`, `fecha_ingreso`

### Modulo 3: POTREROS

| Metodo | Ruta | Proposito |
|--------|------|-----------|
| GET | `/api/v1/potreros` | Listar potreros |
| GET | `/api/v1/potreros/:id` | Detalle con conteo de animales |
| POST | `/api/v1/potreros` | Crear potrero |
| PUT | `/api/v1/potreros/:id` | Actualizar potrero |
| DELETE | `/api/v1/potreros/:id` | Eliminar potrero |
| GET | `/api/v1/fincas/:fincaId/potreros` | Potreros por finca |
| GET | `/api/v1/potreros/:id/animales` | Animales en potrero |

### Modulo 4: ALIMENTOS (extender existente)

| Metodo | Ruta | Estado |
|--------|------|--------|
| GET | `/api/v1/alimentos` | **EXISTE** -- agregar paginacion |
| GET | `/api/v1/alimentos/:id` | **FALTA** |
| POST | `/api/v1/alimentos` | **FALTA** |
| PUT | `/api/v1/alimentos/:id` | **FALTA** |
| DELETE | `/api/v1/alimentos/:id` | **FALTA** |

### Modulo 5: SALUD

| Metodo | Ruta | Proposito |
|--------|------|-----------|
| GET | `/api/v1/salud` | Listar registros (filtrable por tipo, animalId) |
| GET | `/api/v1/salud/:id` | Detalle de registro |
| POST | `/api/v1/salud` | Crear intervencion sanitaria |
| PUT | `/api/v1/salud/:id` | Actualizar registro |
| DELETE | `/api/v1/salud/:id` | Eliminar registro |
| GET | `/api/v1/animales/:animalId/salud` | Salud por animal |

**Prerequisito:** Agregar FK `Salud -> Animal` (Fase 2)

### Modulo 6: REPRODUCCION

| Metodo | Ruta | Proposito |
|--------|------|-----------|
| GET | `/api/v1/reproduccion` | Listar registros reproductivos |
| GET | `/api/v1/reproduccion/:id` | Detalle |
| POST | `/api/v1/reproduccion` | Crear evento reproductivo |
| PUT | `/api/v1/reproduccion/:id` | Actualizar (estado prenada, fecha parto) |
| DELETE | `/api/v1/reproduccion/:id` | Eliminar |
| GET | `/api/v1/animales/:animalId/reproduccion` | Reproduccion por animal |

### Modulo 7: FINANZAS

| Metodo | Ruta | Proposito |
|--------|------|-----------|
| GET | `/api/v1/finanzas` | Listar transacciones (filtrable por tipo, categoria, fecha) |
| GET | `/api/v1/finanzas/:id` | Detalle de transaccion |
| POST | `/api/v1/finanzas` | Crear transaccion |
| PUT | `/api/v1/finanzas/:id` | Actualizar |
| DELETE | `/api/v1/finanzas/:id` | Eliminar |
| GET | `/api/v1/finanzas/resumen` | **Agregado**: total ingresos, gastos, balance por mes |

**Prerequisito:** Agregar FK `Finanza -> Finca` (Fase 2)

### Modulo 8: BOVINO-ALIMENTO (modulo completo nuevo)

**Archivos a crear:** module, controller, service, DTOs

| Metodo | Ruta | Proposito |
|--------|------|-----------|
| GET | `/api/v1/bovino-alimentos` | Listar asignaciones |
| GET | `/api/v1/bovino-alimentos/:bovinoId/:alimentoId` | Asignacion especifica (PK compuesta) |
| POST | `/api/v1/bovino-alimentos` | Asignar alimento a animal |
| PUT | `/api/v1/bovino-alimentos/:bovinoId/:alimentoId` | Actualizar cantidad |
| DELETE | `/api/v1/bovino-alimentos/:bovinoId/:alimentoId` | Remover asignacion |

### Modulo 9: USUARIOS (mejorar existente)

| Metodo | Ruta | Estado |
|--------|------|--------|
| POST | `/api/v1/usuarios/registro` | **EXISTE** -- agregar DTO |
| POST | `/api/v1/usuarios/login` | **EXISTE** -- agregar DTO |
| GET | `/api/v1/usuarios` | **EXISTE** -- agregar paginacion y filtro tenant |
| GET | `/api/v1/usuarios/:id` | **FALTA** |
| PUT | `/api/v1/usuarios/:id` | **FALTA** |
| DELETE | `/api/v1/usuarios/:id` | **FALTA** |

---

## Resumen de Endpoints

| Modulo | GET all | GET :id | POST | PUT | DELETE | Anidados | Total |
|--------|---------|---------|------|-----|--------|----------|-------|
| fincas | 1 | 1 | 1 | 1 | 1 | 0 | **5** |
| animales | 1 | 1 | 1 | 1 | 1 | 1 | **6** |
| potreros | 1 | 1 | 1 | 1 | 1 | 2 | **7** |
| alimentos | 1* | 1 | 1 | 1 | 1 | 0 | **5** |
| salud | 1 | 1 | 1 | 1 | 1 | 1 | **6** |
| reproduccion | 1 | 1 | 1 | 1 | 1 | 1 | **6** |
| finanzas | 1 | 1 | 1 | 1 | 1 | 1 | **6** |
| bovino-alimento | 1 | 1 | 1 | 1 | 1 | 2 | **7** |
| usuarios | 1* | 1 | 1* | 1 | 1 | 1* | **6** |
| **TOTAL** | | | | | | | **54** |

*Marcados con asterisco: ya existen (5 endpoints). Faltan 49.*

---

## Secuencia de Implementacion

| Fase | Modulo | Dependencia |
|------|--------|-------------|
| 0 | Infraestructura (ValidationPipe, prefix, common/) | Ninguna |
| 1 | Fincas | Ninguna (raiz del tenant) |
| 2 | Potreros | FK a Finca |
| 3 | Animales | FK a Finca y Potrero |
| 4 | Alimentos | FK a Finca (Fase 2 BD) |
| 5 | Salud | FK a Animal (Fase 2 BD) |
| 6 | Reproduccion | FK a Animal existente |
| 7 | Finanzas | FK a Finca (Fase 2 BD) |
| 8 | Bovino-Alimento | Depende de Animal y Alimento |
| 9 | Usuarios (mejoras) | Independiente |

---

## Codigos HTTP Estandar

| Operacion | Exito | Errores Comunes |
|-----------|-------|-----------------|
| GET lista | 200 | 400 (query params invalidos) |
| GET por id | 200 | 404 (no encontrado) |
| POST crear | 201 | 400 (validacion), 409 (duplicado) |
| PUT actualizar | 200 | 400 (validacion), 404 (no encontrado) |
| DELETE | 200 | 404, 409 (tiene dependientes) |
