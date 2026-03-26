# Fase 2: Base de Datos & Entidades

## Estado Actual

### Inventario de Entidades (9 tablas)

| Entidad | Tabla | PK | Tipo PK | tiene `updated_at` | tiene `deleted_at` | tiene `tenant_id` |
|---------|-------|----|---------|--------------------|--------------------|--------------------|
| Usuario | `usuarios` | `id` (auto) | number | No | No | Si (string sin FK) |
| Finca | `finca` | `pk_id_finca` | string(15) | No | No | No |
| Animal | `bovinos` | `pk_id_bovino` (auto) | number | Si | No | No |
| Potrero | `potreros` | `pk_id_potrero` | string(15) | No | No | No |
| Alimento | `alimento` | `pk_id_alimento` | string(15) | No | No | No |
| Salud | `salud` | `pk_id_salud` (auto) | number | No | No | No |
| Reproduccion | `reproduccion` | `pk_id_reproduccion` | string(15) | No | No | No |
| Finanza | `finanzas` | `pk_id_finanza` | string(15) | No | No | No |
| BovinoAlimento | `bovino_alimento` | composite | composite | No | No | No |

### Relaciones Existentes (con decoradores TypeORM)

```
Finca  ──(1:N)──> Animal       [OK: @OneToMany/@ManyToOne]
Finca  ──(1:N)──> Potrero      [OK: @OneToMany/@ManyToOne]
Potrero ──(1:N)──> Animal      [OK: @OneToMany/@ManyToOne]
Animal ──(1:N)──> Reproduccion [OK: @ManyToOne en Reproduccion]
BovinoAlimento ──(N:1)──> Animal    [OK: unidireccional]
BovinoAlimento ──(N:1)──> Alimento  [OK: unidireccional]
```

### Defectos Criticos

1. **`Animal.reproducciones: any`** (linea 58) -- propiedad sin decorador, TypeORM la ignora
2. **Sin `@JoinColumn` en ninguna relacion** -- columnas FK auto-generadas con nombres inconsistentes
3. **Sin indices** -- ningun `@Index` en todo el proyecto

### Relaciones Faltantes

| Entidad | Relacion Faltante | Logica de Negocio |
|---------|-------------------|-------------------|
| Salud | Sin FK a Animal | Registro de salud DEBE pertenecer a un animal |
| Finanza | Sin FK a Finca | Registros financieros DEBEN pertenecer a una finca |
| Alimento | Sin FK a Finca | Inventario de alimentos DEBE pertenecer a una finca |
| Usuario | Sin FK a Finca/Tenant | `tenant_id` es string sin constraint |
| Reproduccion | `fk_id_padre`/`fk_id_madre` son strings, no FKs | Deben ser `@ManyToOne` a Animal |

---

## Plan de Implementacion

### Fase A: Clase Base de Entidad y Columnas de Auditoria

**Crear:** `Backend/src/common/entities/base.entity.ts`

Clase abstracta que provee:
- `@CreateDateColumn({ name: 'creado_en' })` -- ya existe individualmente en la mayoria
- `@UpdateDateColumn({ name: 'actualizado_en' })` -- solo existe en Animal
- `@DeleteDateColumn({ name: 'eliminado_en' })` -- no existe en ninguna
- `@Column({ name: 'tenant_id' })` -- para aislamiento multi-tenant

**Impacto:** 8 entidades necesitan columnas `actualizado_en` y `eliminado_en` (8 ALTER TABLE).

### Fase B: Corregir Relaciones Existentes

#### B1. Corregir `Animal.reproducciones`

Archivo: `Backend/src/animales/entities/animal.entity.ts` (linea 58)

- Remover `reproducciones: any;`
- Reemplazar con `@OneToMany(() => Reproduccion, r => r.bovino) reproducciones: Reproduccion[]`

#### B2. Agregar `@JoinColumn` a todas las relaciones `@ManyToOne`

| Entidad | Relacion | JoinColumn |
|---------|----------|------------|
| Animal.finca | ManyToOne -> Finca | `@JoinColumn({ name: 'fk_id_finca' })` |
| Animal.potrero | ManyToOne -> Potrero | `@JoinColumn({ name: 'fk_id_potrero' })` |
| Potrero.finca | ManyToOne -> Finca | `@JoinColumn({ name: 'fk_id_finca' })` |
| Reproduccion.bovino | ManyToOne -> Animal | `@JoinColumn({ name: 'fk_id_bovino' })` |

### Fase C: Agregar Foreign Keys Faltantes

#### C1. Salud -> Animal

```
// salud.entity.ts
@ManyToOne(() => Animal, animal => animal.registrosSalud)
@JoinColumn({ name: 'fk_id_bovino' })
bovino: Animal;
```

En Animal agregar: `@OneToMany(() => Salud, s => s.bovino) registrosSalud: Salud[]`

#### C2. Finanza -> Finca

```
// finanza.entity.ts
@ManyToOne(() => Finca, finca => finca.finanzas)
@JoinColumn({ name: 'fk_id_finca' })
finca: Finca;
```

En Finca agregar: `@OneToMany(() => Finanza, f => f.finca) finanzas: Finanza[]`

#### C3. Alimento -> Finca

```
// alimento.entity.ts
@ManyToOne(() => Finca, finca => finca.alimentos)
@JoinColumn({ name: 'fk_id_finca' })
finca: Finca;
```

En Finca agregar: `@OneToMany(() => Alimento, a => a.finca) alimentos: Alimento[]`

#### C4. Reproduccion padre/madre -> Animal

Reemplazar columnas string planas:

```
// reproduccion.entity.ts
@ManyToOne(() => Animal, { nullable: true, onDelete: 'SET NULL' })
@JoinColumn({ name: 'fk_id_padre' })
padre: Animal;

@ManyToOne(() => Animal, { nullable: true, onDelete: 'SET NULL' })
@JoinColumn({ name: 'fk_id_madre' })
madre: Animal;
```

**ATENCION:** `fk_id_padre`/`fk_id_madre` son `varchar(15)` pero Animal PK es `integer`. La migracion debe manejar la conversion de tipo.

#### C5. BovinoAlimento lados inversos (bidireccional)

En Animal: `@OneToMany(() => BovinoAlimento, ba => ba.bovino) alimentacion: BovinoAlimento[]`
En Alimento: `@OneToMany(() => BovinoAlimento, ba => ba.alimento) bovinosAlimentados: BovinoAlimento[]`

### Fase D: Agregar `tenant_id` a Todas las Entidades

**Estrategia:** Desnormalizar `tenant_id` en cada tabla (FK a Finca).

```
Tenant/Finca ──(1:N)──> Animal (tenant_id directo)
Tenant/Finca ──(1:N)──> Potrero (tenant_id directo)
Tenant/Finca ──(1:N)──> Alimento (tenant_id directo)
Tenant/Finca ──(1:N)──> Salud (tenant_id directo)
Tenant/Finca ──(1:N)──> Reproduccion (tenant_id directo)
Tenant/Finca ──(1:N)──> Finanza (tenant_id directo)
Tenant/Finca ──(1:N)──> BovinoAlimento (tenant_id directo)
```

Ventajas: WHERE clauses simples sin JOINs, habilita PostgreSQL RLS.

### Fase E: Indices de Rendimiento

| Tabla | Indice | Tipo | Razon |
|-------|--------|------|-------|
| `usuarios` | `(tenant_id)` | B-tree | Filtrar por tenant |
| `usuarios` | `(email)` | Unique | Lookup de login |
| `finca` | `(tenant_id)` | B-tree | Filtrar fincas |
| `bovinos` | `(tenant_id)` | B-tree | Filtrar animales |
| `bovinos` | `(fk_id_finca)` | B-tree | FK lookup |
| `bovinos` | `(fk_id_potrero)` | B-tree | FK lookup |
| `bovinos` | `(tenant_id, numero_identificacion)` | Unique | ID animal unico por tenant |
| `potreros` | `(tenant_id)` | B-tree | Filtrar potreros |
| `salud` | `(fk_id_bovino)` | B-tree | Historial de salud por animal |
| `salud` | `(fecha_aplicacion)` | B-tree | Consultas por rango de fecha |
| `reproduccion` | `(fk_id_bovino)` | B-tree | FK lookup |
| `reproduccion` | `(fecha_estimado_parto)` | B-tree | Proximos nacimientos |
| `finanzas` | `(tenant_id, fecha)` | B-tree | Reportes financieros |
| `finanzas` | `(tipo_movimiento)` | B-tree | Filtrar ingreso/gasto |
| `alimento` | `(fk_id_finca)` | B-tree | FK lookup |

### Fase F: Reglas de Cascade y Eliminacion

| Padre | Hijo | onDelete | Razon |
|-------|------|----------|-------|
| Finca | Animal | RESTRICT | Reasignar animales antes de eliminar |
| Finca | Potrero | RESTRICT | Reasignar animales primero |
| Finca | Alimento | CASCADE | Registros de alimento van con la finca |
| Finca | Finanza | RESTRICT | Registros financieros deben preservarse |
| Potrero | Animal | SET NULL | Animal queda sin potrero asignado |
| Animal | Salud | CASCADE | Registros de salud van con el animal |
| Animal | Reproduccion | CASCADE | Registros reproductivos van con el animal |
| Animal | BovinoAlimento | CASCADE | Registros de alimentacion van con el animal |
| Animal (padre) | Reproduccion | SET NULL | Anular referencia al padre |
| Animal (madre) | Reproduccion | SET NULL | Anular referencia a la madre |

**Soft delete hace la mayoria de cascades no destructivas.** Con `@DeleteDateColumn`, un "delete" solo marca `eliminado_en`.

---

## Estrategia de Migraciones

### Paso 1: Capturar esquema actual

```bash
docker compose up db
cd Backend && npm run start:dev  # Sincronizar esquema actual
```

### Paso 2: Configurar CLI de TypeORM

**Crear:** `Backend/src/data-source.ts`

DataSource con todas las entidades y ruta de migraciones (`src/migrations`).

**Agregar scripts a `package.json`:**
```json
"typeorm": "ts-node -r tsconfig-paths/register ./node_modules/typeorm/cli.js -d src/data-source.ts",
"migration:generate": "npm run typeorm -- migration:generate src/migrations/$npm_config_name",
"migration:run": "npm run typeorm -- migration:run",
"migration:revert": "npm run typeorm -- migration:revert"
```

### Paso 3: Crear migracion baseline

1. Desactivar `synchronize: true` -> `false` en `app.module.ts`
2. Agregar `migrations: ['dist/migrations/*.js']` y `migrationsRun: true`
3. `npx typeorm migration:generate src/migrations/InitialSchema`
4. `npx typeorm migration:run`

### Paso 4: Migracion de evolucion

```bash
npx typeorm migration:generate src/migrations/AddRelationsAndTenantIsolation
```

Contenido:
1. ALTER TABLE en 8 tablas para agregar `tenant_id`, `actualizado_en`, `eliminado_en`
2. ALTER TABLE `salud` para agregar `fk_id_bovino`
3. ALTER TABLE `finanzas` para agregar `fk_id_finca`
4. ALTER TABLE `alimento` para agregar `fk_id_finca`
5. ALTER TABLE `reproduccion` para cambiar tipo de `fk_id_padre`/`fk_id_madre`
6. ADD CONSTRAINT para todas las nuevas FKs
7. CREATE INDEX para todos los indices de rendimiento

---

## Archivos a Crear/Modificar

### Nuevos (3 archivos)
- `Backend/src/common/entities/base.entity.ts`
- `Backend/src/data-source.ts`
- `Backend/src/migrations/` (directorio, archivos auto-generados)

### Modificar (12 archivos)
- `Backend/src/animales/entities/animal.entity.ts` -- fix reproducciones, agregar JoinColumns, registrosSalud, alimentacion, tenant_id
- `Backend/src/fincas/entities/finca.entity.ts` -- agregar finanzas, alimentos, audit columns
- `Backend/src/salud/entities/salud.entity.ts` -- agregar ManyToOne a Animal, tenant_id
- `Backend/src/finanzas/entities/finanza.entity.ts` -- agregar ManyToOne a Finca, tenant_id
- `Backend/src/alimentos/entities/alimento.entity.ts` -- agregar ManyToOne a Finca, bovinosAlimentados, tenant_id
- `Backend/src/reproduccion/entities/reproduccion.entity.ts` -- cambiar padre/madre a ManyToOne, tenant_id
- `Backend/src/potreros/entities/potrero.entity.ts` -- agregar JoinColumn, tenant_id
- `Backend/src/usuarios/entities/usuario.entity.ts` -- FK a Finca, audit columns
- `Backend/src/bovino-alimento/entities/bovino-alimento.entity.ts` -- JoinColumns, tenant_id
- `Backend/src/app.module.ts` -- synchronize: false, migrations config
- Cada modulo de dominio -- agregar `TypeOrmModule.forFeature([Entity])` donde falta

---

## Orden de Ejecucion

| # | Accion |
|---|--------|
| 1 | Crear `data-source.ts` y agregar scripts de migracion |
| 2 | Generar migracion baseline con `synchronize: true`, luego cambiar a `false` |
| 3 | Agregar columnas base (`actualizado_en`, `eliminado_en`) |
| 4 | Corregir `Animal.reproducciones` |
| 5 | Agregar `@JoinColumn` a relaciones existentes |
| 6 | Agregar FKs faltantes: Salud->Animal, Finanza->Finca, Alimento->Finca |
| 7 | Corregir tipo de Reproduccion padre/madre |
| 8 | Agregar `tenant_id` a todas las entidades |
| 9 | Agregar indices |
| 10 | Agregar `TypeOrmModule.forFeature` a modulos que faltan |
| 11 | Generar migracion de evolucion |
| 12 | Probar migracion en BD limpia Y con datos existentes |

---

## Riesgos

| Riesgo | Mitigacion |
|--------|-----------|
| Datos existentes con NULL en `tenant_id` | Crear tenant default, asignar datos, luego agregar NOT NULL |
| Tipo mismatch `fk_id_padre`/`fk_id_madre` (varchar->integer) | Verificar si hay datos; si los hay, convertir |
| `@JoinColumn` puede crear columnas FK duplicadas | Inspeccionar BD actual antes de generar migracion |
| `synchronize: false` puede causar fallo si migracion no ha corrido | `migrationsRun: true` auto-ejecuta al iniciar |
