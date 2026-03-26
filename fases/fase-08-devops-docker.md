# Fase 8: DevOps & Docker

## Estado Actual

- `docker-compose.yml` -- **ROTO**: referencia Dockerfile eliminado, contexto incorrecto, comando Prisma invalido
- `setup.sh` -- ejecuta `docker compose up --build` (falla)
- Sin Dockerfiles en todo el repo
- Sin CI/CD (sin directorio `.github/`)
- Sin `.dockerignore`
- `Colors.dart` mayuscula rompe builds en Linux/Docker (case-sensitive)
- `synchronize: true` en produccion es peligroso
- Health check solo es `GET /` → "Hello World!"

---

## Archivos a Crear (15)

| # | Archivo | Proposito |
|---|---------|-----------|
| 1 | `Backend/Dockerfile` | Multi-stage build para NestJS |
| 2 | `Backend/.dockerignore` | Excluir node_modules, dist, .env, tests |
| 3 | `Frontend/Dockerfile` | Multi-stage: Flutter build → nginx |
| 4 | `Frontend/.dockerignore` | Excluir build, platform dirs |
| 5 | `docker-compose.yml` | **REEMPLAZAR** -- db + backend + frontend |
| 6 | `docker-compose.dev.yml` | Override para desarrollo (hot-reload, volumes) |
| 7 | `Backend/.env.example` | Template de variables backend |
| 8 | `Frontend/.env.example` | Template variables frontend |
| 9 | `.env.example` | Template raiz para docker-compose |
| 10 | `.github/workflows/ci.yml` | CI: lint, test, build |
| 11 | `.github/workflows/cd.yml` | CD: Docker build + push |
| 12 | `Backend/src/health/health.controller.ts` | Health check con verificacion DB |
| 13 | `Backend/src/health/health.module.ts` | Modulo NestJS para health |
| 14 | `nginx/default.conf` | Config nginx para Frontend |
| 15 | `scripts/backup-db.sh` | Script de backup de BD |
| 16 | `scripts/restore-db.sh` | Script de restauracion |

---

## Backend Dockerfile

**Path:** `Backend/Dockerfile`

### Stage 1: build
```dockerfile
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY src/ tsconfig.json tsconfig.build.json nest-cli.json ./
RUN npm run build
RUN npm prune --production
```

### Stage 2: production
```dockerfile
FROM node:22-alpine AS production
WORKDIR /app
RUN addgroup -S farmlink && adduser -S farmlink -G farmlink
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./
ENV NODE_ENV=production
EXPOSE 3000
USER farmlink
HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
ENTRYPOINT ["node", "dist/main"]
```

**Imagen resultante:** ~180MB (Alpine)

---

## Frontend Dockerfile

**Path:** `Frontend/Dockerfile`

### Stage 1: build
```dockerfile
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
ARG API_BASE_URL=http://localhost:3000
RUN flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL
```

### Stage 2: production
```dockerfile
FROM nginx:1.27-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1
```

---

## Nginx Config

**Path:** `nginx/default.conf`

```nginx
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;

    # SPA routing fallback
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml image/svg+xml;

    # Cache para assets estaticos
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## docker-compose.yml (REEMPLAZO COMPLETO)

```yaml
services:
  db:
    image: postgres:16-alpine
    container_name: farmlink-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-postgres}
      POSTGRES_DB: ${POSTGRES_DB:-farmlink}
    ports:
      - "${DB_HOST_PORT:-5433}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - farmlink-network

  backend:
    build:
      context: ./Backend
      target: production
    container_name: farmlink-backend
    restart: unless-stopped
    ports:
      - "${BACKEND_PORT:-3000}:3000"
    environment:
      DB_HOST: db
      DB_PORT: 5432
      DB_USERNAME: ${POSTGRES_USER:-postgres}
      DB_PASSWORD: ${POSTGRES_PASSWORD:-postgres}
      DB_DATABASE: ${POSTGRES_DB:-farmlink}
      PORT: 3000
      NODE_ENV: production
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - farmlink-network

  frontend:
    build:
      context: ./Frontend
    container_name: farmlink-frontend
    restart: unless-stopped
    ports:
      - "${FRONTEND_PORT:-80}:80"
    depends_on:
      backend:
        condition: service_healthy
    networks:
      - farmlink-network

volumes:
  postgres_data:

networks:
  farmlink-network:
    driver: bridge
```

---

## docker-compose.dev.yml

```yaml
services:
  backend:
    build:
      target: build  # incluye devDependencies
    command: npm run start:dev
    volumes:
      - ./Backend/src:/app/src
      - ./Backend/test:/app/test
    environment:
      NODE_ENV: development
      DB_HOST: db
      DB_PORT: 5432
    healthcheck:
      disable: true
```

Uso: `docker compose -f docker-compose.yml -f docker-compose.dev.yml up`

Frontend NO se incluye en dev compose -- Flutter dev es mejor localmente con `flutter run -d chrome`.

---

## Variables de Entorno

### `.env.example` (raiz)
```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=farmlink
DB_HOST_PORT=5433
BACKEND_PORT=3000
FRONTEND_PORT=80
JWT_SECRET=change-me-in-production
JWT_REFRESH_SECRET=change-me-in-production
```

### `Backend/.env.example`
```env
DB_HOST=localhost
DB_PORT=5433
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE=farmlink
PORT=3000
NODE_ENV=development
```

### `Frontend/.env.example`
```env
API_BASE_URL=http://localhost:3000
```

---

## Health Check Endpoint

### `Backend/src/health/health.controller.ts`

- `GET /health` → `{ status: 'ok', timestamp: ISO-string }`
- `GET /health/db` → intenta `SELECT 1`
  - Exito: `{ status: 'ok', database: 'connected' }`
  - Fallo: 503 `{ status: 'error', database: 'disconnected' }`

Registrar `HealthModule` en `app.module.ts`.

---

## GitHub Actions CI

### `.github/workflows/ci.yml`

**Trigger:** push a `main`/`develop`, PRs

**Job 1: backend-lint-test**
- `ubuntu-latest` + PostgreSQL 16 service
- `npm ci`, `npm run lint`, `npm run test`, `npm run test:e2e`

**Job 2: frontend-analyze**
- Flutter stable
- `flutter pub get`, `flutter analyze`, `flutter test`

**Job 3: docker-build**
- Buildx
- `docker build --target production -t farmlink-backend:test ./Backend`
- `docker build -t farmlink-frontend:test ./Frontend`

### `.github/workflows/cd.yml`

**Trigger:** push de tags `v*`, workflow_dispatch

- Build + push a GitHub Container Registry (ghcr.io)
- Tags: `latest` + version del tag

---

## Logging Estructurado

**Instalar:** `npm install nestjs-pino pino-http && npm install -D pino-pretty`

- JSON estructurado en produccion
- Legible con `pino-pretty` en desarrollo
- Campos: timestamp, level, msg, req.id, method, url, statusCode, responseTime

---

## .dockerignore

### `Backend/.dockerignore`
```
node_modules
dist
coverage
.env
.env.*
*.log
.git
test
prisma
README.md
```

### `Frontend/.dockerignore`
```
build
.dart_tool
.pub-cache
android
ios
linux
macos
windows
test
.git
```

---

## Backup de Base de Datos

### `scripts/backup-db.sh`
- `docker exec farmlink-db pg_dump -U postgres -Fc farmlink > backups/farmlink_<timestamp>.dump`
- Retiene ultimos 7 backups diarios

### `scripts/restore-db.sh`
- Toma filename como argumento
- `docker exec -i farmlink-db pg_restore -U postgres -d farmlink --clean --if-exists`

---

## Orden de Implementacion

| # | Accion | Dependencia |
|---|--------|-------------|
| 0 | **FIX CRITICO:** Renombrar `Colors.dart` → `colors.dart` | Bloquea Docker en Linux |
| 1 | Crear `.env.example` files | Fundacion |
| 2 | Crear `.dockerignore` files | Antes de Docker builds |
| 3 | Crear health check endpoint | Requerido por Docker healthcheck |
| 4 | Crear `Backend/Dockerfile` | Core |
| 5 | Crear `nginx/default.conf` | Requerido por Frontend Dockerfile |
| 6 | Crear `Frontend/Dockerfile` | Core |
| 7 | Reemplazar `docker-compose.yml` | Depende de ambos Dockerfiles |
| 8 | Crear `docker-compose.dev.yml` | Override dev |
| 9 | Actualizar `.gitignore` | Patrones nuevos |
| 10 | CI pipeline | Dockerfiles deben ser buildables |
| 11 | CD pipeline | CI debe estar verde |
| 12 | Scripts de backup | Independiente |

---

## Comandos de Referencia

```bash
# Desarrollo local (solo BD en Docker)
docker compose up db
cd Backend && npm run start:dev
cd Frontend && flutter run -d chrome

# Desarrollo containerizado
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build

# Produccion
docker compose up --build -d
docker compose logs -f backend
docker compose ps
docker compose down

# Base de datos
docker compose exec db psql -U postgres -d farmlink
./scripts/backup-db.sh
./scripts/restore-db.sh backups/farmlink_20260326.dump
```
