# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**FarmLink** — Plataforma Inteligente de Gestión Ganadera Multitenant. Proyecto académico de la Universidad Tecnológica de Bolívar (Proyecto de Ingeniería 1). Backend NestJS + Frontend Flutter para administración de fincas ganaderas con aislamiento por tenant.

## CRITICAL: Architecture Discrepancy

Two conflicting designs exist in this repo:

1. **Prisma schema + root package.json + TESTING.md + TROUBLESHOOTING.md**: Describe a planned system with JWT auth, bcrypt, `/api/v1/` routes, Tenant model, Swagger docs. **This code was never built.**
2. **TypeORM entities + Backend/src/ code**: The real implementation. Uses TypeORM, Spanish-named routes (`/usuarios/login`), plain-text passwords, no auth guards.

**Always work from the Backend/ directory code, not the root-level configs.** The root `package.json`, `tsconfig.json`, `nest-cli.json` are orphaned artifacts from the planned Prisma architecture.

## Commands

### Backend (run from `Backend/` directory)
```bash
cd Backend
npm install
npm run start:dev       # Development with hot-reload (port 3000)
npm run build           # Compile TypeScript
npm run start:prod      # Run compiled output
npm run test            # Unit tests (Jest 30)
npm run test:e2e        # E2E tests (Supertest)
npm run lint            # ESLint
```

### Frontend (run from `Frontend/` directory)
```bash
cd Frontend
flutter pub get
flutter run              # Run on default device
flutter run -d chrome    # Web
flutter run -d macos     # macOS desktop
flutter analyze          # Static analysis
flutter test             # Widget tests
```

### Database
```bash
docker compose up db     # Start PostgreSQL only (port 5433 on host -> 5432 in container)
# docker compose up --build  # BROKEN: backend service references deleted Dockerfile
```

### Credentials (PostgreSQL via Docker)
- User: `postgres`, Password: `postgres`, Database: `farmlink`, Host port: `5433`

## Backend Environment Variables (`Backend/.env`)
```
DB_HOST=localhost
DB_PORT=5433
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE=farmlink
PORT=3000
```

## Backend Architecture

**Stack:** NestJS 11 + TypeORM 0.3.28 + PostgreSQL 16 (Docker)

### Module Completion State

| Module          | Entity | Controller | Service | Business Logic |
|-----------------|--------|------------|---------|----------------|
| usuarios        | Done   | Done       | Done    | registro, login (plain-text!), findAll |
| alimentos       | Done   | GET only   | findAll | Read only |
| fincas          | Done   | Missing    | Empty   | None |
| animales        | Done   | Missing    | Empty   | None |
| potreros        | Done   | Missing    | Empty   | None |
| salud           | Done   | Empty      | Empty   | None |
| reproduccion    | Done   | Empty      | Empty   | None |
| finanzas        | Done   | Empty      | Empty   | None |
| bovino-alimento | Done   | Missing    | Missing | Entity only |

### Working API Endpoints (as of current code)
- `POST /usuarios/registro` — Creates user (plain text password)
- `POST /usuarios/login` — Compares plain text password
- `GET /usuarios` — List all users
- `GET /alimentos` — List all alimentos
- `GET /` — "Hello World!" health check

### Entity Relationships (TypeORM)
- Finca 1:N Animal, Finca 1:N Potrero
- Potrero 1:N Animal
- Animal 1:N Reproduccion
- BovinoAlimento N:1 Animal, N:1 Alimento (composite PK)
- Salud, Finanza, Alimento: **no foreign keys** to parent entities (missing relations)
- Usuario has `tenant_id` string column (no FK to Finca)

### Known Issues
1. **Passwords in plain text** (`usuarios.service.ts` line 22)
2. **No auth guards**, no JWT, no middleware
3. **`synchronize: true`** in TypeORM config (auto-mutates schema)
4. **Missing FKs**: Salud→Animal, Finanza→Finca, Alimento→Finca
5. **Untyped relation**: `Animal.reproducciones: any` (line 58 of animal.entity.ts)
6. **No DTOs**: endpoints accept raw `body: any`
7. **No CORS** enabled in `main.ts`
8. **No validation pipe** configured
9. **Docker broken**: Dockerfile was deleted but docker-compose.yml still references it
10. Entity naming uses Spanish (`pk_id_bovino`, `nombre_finca`, `creado_en`)

## Frontend Architecture

**Stack:** Flutter (Dart 3.10+) + Dio 5.9.2 + Material Design 3

### Screen Flow
```
LandingScreen → LoginScreen → DashboardScreen
                    ↓
              RegistroScreen → DashboardScreen
```

### Current State
- **4 screens**: Landing (web marketing page), Login, Registro, Dashboard
- **2 components**: InputField, PrimaryButton
- **Dashboard is 100% hardcoded** — no API calls, all mock data
- **No state management** library (uses setState only)
- **No JWT token storage** — login response is discarded
- **No route guards** — Dashboard accessible without auth
- **Tenant ID hardcoded** as `'finca1'` in `api_service.dart`
- **API base URL** hardcoded to `http://localhost:3000`
- Theme supports light/dark mode (ThemeMode.system)
- Primary color: `#2E7D32` (forest green)

### File Naming Issue
`Frontend/lib/theme/Colors.dart` (capital C) is imported inconsistently — `Theme.dart` imports `colors.dart` (lowercase). Works on macOS (case-insensitive) but **will break on Linux CI**.

## Coding Conventions
- Backend entity fields: Spanish naming (`pk_id_bovino`, `nombre_finca`, `fecha_nacimiento`)
- Backend module pattern: `<domain>.module.ts`, `<domain>.controller.ts`, `<domain>.service.ts`, `entities/<domain>.entity.ts`
- Frontend screen files: PascalCase with underscore (`Dashboard_screen.dart`, `Login_screen.dart`)
- Frontend components: snake_case (`input_field.dart`, `primary_button.dart`)
- Border radius: 14px for inputs, 12-16px for cards
- Code formatting: Prettier (single quotes, trailing commas)
