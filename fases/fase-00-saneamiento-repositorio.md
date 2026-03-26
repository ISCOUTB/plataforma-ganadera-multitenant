# Fase 0: Saneamiento del Repositorio

## Objetivo

Eliminar la arquitectura fantasma (Prisma/JWT planificada pero nunca construida), corregir artefactos rotos y establecer una base limpia para las fases posteriores.

## Contexto: Dos Arquitecturas en Conflicto

El repositorio contiene dos diseños mutuamente excluyentes:

| Aspecto | Arq. Fantasma (eliminar) | Arq. Real (conservar) |
|---------|--------------------------|----------------------|
| ORM | Prisma 5.8.0 | TypeORM 0.3.28 |
| Ubicacion | `root/package.json`, `Backend/prisma/` | `Backend/package.json`, `Backend/src/` |
| Rutas | `/api/v1/auth/login` | `/usuarios/login` |
| Auth | JWT + bcrypt + refresh tokens | Texto plano (a corregir en Fase 1) |
| NestJS | ^10.3.0 | ^11.0.1 |

La Arq. Fantasma fue documentada en TESTING.md y TROUBLESHOOTING.md pero nunca implementada. Debe eliminarse para evitar confusion.

---

## Tareas

### Grupo A: Eliminar Artefactos Fantasma

| # | Archivo | Accion | Razon |
|---|---------|--------|-------|
| 0.1 | `Backend/prisma/schema.prisma` | DELETE | Schema Prisma no conectado al codigo TypeORM |
| 0.2 | `Backend/prisma/schema.prisma.bak` | DELETE | Backup del schema fantasma |
| 0.3 | `Backend/prisma/` | DELETE directorio | Directorio vacio tras eliminar contenido |
| 0.4 | `/package.json` (raiz) | DELETE | Declara deps Prisma/JWT/bcrypt que no estan en Backend/. Name: `farmlink-backend` conflicta con el real (`vac-app`). Scripts referencian Prisma |
| 0.5 | `/tsconfig.json` (raiz) | DELETE | Target ES2021 + CommonJS con path aliases Prisma. Backend/ usa ES2023 + NodeNext |
| 0.6 | `/nest-cli.json` (raiz) | DELETE | Duplica `Backend/nest-cli.json` con config diferente |
| 0.7 | `/setup.sh` | DELETE | Ejecuta `docker compose up --build` que referencia Dockerfile eliminado, y genera package-lock para el package.json raiz |

### Grupo B: Corregir Docker

| # | Archivo | Accion | Detalle |
|---|---------|--------|---------|
| 0.8 | `/docker-compose.yml` | EDIT | Eliminar servicio `backend` completo (lineas 22-44). Referencias: Dockerfile eliminado (commit `3c96fbe`), comando `npx prisma migrate deploy` inexistente. Conservar solo servicio `db` |

### Grupo C: Corregir .gitignore Raiz

| # | Archivo | Accion | Detalle |
|---|---------|--------|---------|
| 0.9 | `/.gitignore` | EDIT | Actualmente solo excluye `__MACOSX/` y `.DS_Store`. Agregar: `.env*`, `node_modules/`, `dist/`, `*.log`, `.idea/`, `.vscode/` |

### Grupo D: Corregir Backend

| # | Archivo | Accion | Detalle |
|---|---------|--------|---------|
| 0.10 | `Backend/package.json` | EDIT | Cambiar `"name": "vac-app"` a `"name": "farmlink-backend"` |
| 0.11 | `Backend/src/main.ts` | EDIT | Agregar `app.enableCors()` antes de `app.listen()`. Sin esto, Flutter Web no puede conectarse al backend |
| 0.12 | `Backend/src/app.module.ts` | EDIT | Eliminar `TypeOrmModule.forFeature([...])` de lineas 46-49. Ese bloque registra repositories en AppModule sin que ningun service los consuma ahi. Cada modulo de dominio debe registrar sus propios repos |

### Grupo E: Corregir Frontend

| # | Archivo | Accion | Detalle |
|---|---------|--------|---------|
| 0.13 | `Frontend/lib/theme/Colors.dart` | RENAME a `colors.dart` | `Theme.dart` importa `colors.dart` (minuscula). Funciona en macOS (case-insensitive) pero falla en Linux/CI. Estandarizar a minuscula |
| 0.14 | `Frontend/lib/screens/Dashboard_screen.dart` | EDIT | Eliminar `import 'package:flutter/services.dart'` (linea 2) — no se usa |

### Grupo F: Marcar Documentacion Aspiracional

| # | Archivo | Accion | Detalle |
|---|---------|--------|---------|
| 0.15 | `/TESTING.md` | EDIT | Agregar banner al inicio: `> **ATENCION:** Este documento describe una arquitectura planificada (Prisma + JWT + /api/v1/) que NO corresponde al codigo actual. El backend real usa TypeORM con rutas en espanol. Ver CLAUDE.md para el estado real.` |
| 0.16 | `/TROUBLESHOOTING.md` | EDIT | Mismo banner de advertencia |

### Grupo G: Crear Archivos Faltantes

| # | Archivo | Accion | Detalle |
|---|---------|--------|---------|
| 0.17 | `Backend/.env.example` | CREATE | Template con variables requeridas (sin valores secretos reales) |

Contenido:
```
DB_HOST=localhost
DB_PORT=5433
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE=farmlink
PORT=3000
```

---

## Orden de Ejecucion

```
1. Eliminar artefactos fantasma (0.1 - 0.7)    -- sin dependencias
2. Corregir docker-compose (0.8)                -- sin dependencias
3. Corregir .gitignore (0.9)                    -- sin dependencias
4. Corregir Backend (0.10 - 0.12)               -- sin dependencias
5. Corregir Frontend (0.13 - 0.14)              -- sin dependencias
6. Marcar docs aspiracionales (0.15 - 0.16)     -- sin dependencias
7. Crear .env.example (0.17)                    -- sin dependencias

Todos los grupos son independientes y pueden ejecutarse en paralelo.
```

---

## Criterios de Exito

| Verificacion | Comando | Resultado Esperado |
|-------------|---------|-------------------|
| Backend arranca | `cd Backend && npm run start:dev` | Sin warnings por archivos Prisma o configs duplicadas |
| Frontend compila | `cd Frontend && flutter analyze` | 0 errores, 0 warnings por imports |
| Docker DB funciona | `docker compose up db` | PostgreSQL arranca sin intentar build del backend |
| No hay archivos raiz conflictivos | `ls package.json tsconfig.json nest-cli.json setup.sh 2>/dev/null` | Ninguno existe |
| .gitignore protege secretos | `cat .gitignore \| grep .env` | `.env*` presente |
| CORS habilitado | `curl -I -X OPTIONS http://localhost:3000` | Headers `Access-Control-Allow-Origin` presentes |

---

## Riesgos

| Riesgo | Probabilidad | Mitigacion |
|--------|-------------|-----------|
| Alguien ejecuta `npm install` en raiz esperando el package.json | Baja | README actualizado indicando que todo se ejecuta desde `Backend/` |
| TESTING.md confunde a nuevos miembros del equipo | Media | Banner de advertencia prominente |
| `synchronize: true` altera tablas al arrancar tras cambios de entidad | Alta | Se corrige en Fase 2 (migraciones). En Fase 0 solo se documenta el riesgo |

---

## Dependencias

- **Prerequisitos:** Ninguno. Esta es la primera fase.
- **Desbloquea:** Fase 1 (Seguridad), Fase 2 (BD), y todas las demas.

---

## Archivos Afectados (resumen)

| Accion | Cantidad | Archivos |
|--------|----------|----------|
| DELETE | 7 | prisma/schema.prisma, prisma/schema.prisma.bak, prisma/, root package.json, root tsconfig.json, root nest-cli.json, setup.sh |
| EDIT | 7 | docker-compose.yml, .gitignore, Backend/package.json, main.ts, app.module.ts, TESTING.md, TROUBLESHOOTING.md |
| RENAME | 1 | Colors.dart -> colors.dart |
| CREATE | 1 | Backend/.env.example |
| **Total** | **16** | |
