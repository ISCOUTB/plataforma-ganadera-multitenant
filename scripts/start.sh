#!/usr/bin/env bash
#
# scripts/start.sh — Levanta TODO FarmLink (DB + Backend IA + Backend + Frontend Flutter)
# con un solo comando.
#
# Uso (Git Bash en Windows):
#   chmod +x scripts/start.sh   # solo la primera vez
#   ./scripts/start.sh
#
# Pasos:
#   1. Limpieza forzosa: PID file previo, puertos (3000, 8000) y node.exe huérfanos.
#   2. docker compose up -d (PostgreSQL + Backend IA Proxy en farmlink-db y farmlink-ai-proxy).
#   3. Backend: npm install (si falta), migration:run, seed (vía seed.sh).
#   4. Backend: npm run start:dev en background (logs en .run/backend.log).
#   5. Health check: poll http://localhost:3000/api/docs hasta 200 OK.
#   6. Health check: poll http://localhost:8000/health hasta 200 OK.
#   7. Frontend: flutter run -d chrome --dart-define=API_BASE_URL=...
#
# Para detener el backend tras cerrar Flutter (Ctrl+C):
#   ./scripts/stop.sh          # solo backend
#   ./scripts/stop.sh --all    # backend + docker (postgresql + backend-ai)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; B='\033[0;34m'; NC='\033[0m'
step()  { echo -e "\n${B}▶ $1${NC}"; }
ok()    { echo -e "${G}  ✓${NC} $1"; }
warn()  { echo -e "${Y}  ⚠${NC} $1"; }
fail()  { echo -e "${R}  ✗${NC} $1"; exit 1; }

# ---------- 1. Limpieza forzosa ----------
step "1/7 Limpiando procesos previos"

PID_FILE="$ROOT/.run/backend.pid"
if [ -f "$PID_FILE" ]; then
  OLD_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [ -n "${OLD_PID:-}" ]; then
    kill "$OLD_PID" 2>/dev/null || true
  fi
  rm -f "$PID_FILE"
fi

# Liberar puerto 3000 si está ocupado (Windows: netstat + taskkill)
PORT_PIDS=$(netstat -ano 2>/dev/null | grep ":3000 " | grep -i LISTENING | awk '{print $NF}' | sort -u || true)
if [ -n "${PORT_PIDS:-}" ]; then
  for PID in $PORT_PIDS; do
    taskkill //F //PID "$PID" >/dev/null 2>&1 || true
  done
  ok "Liberado puerto 3000 (PIDs: $PORT_PIDS)"
else
  ok "Puerto 3000 libre"
fi

# Liberar puerto 8000 si está ocupado (Backend IA)
PORT_PIDS_8000=$(netstat -ano 2>/dev/null | grep ":8000 " | grep -i LISTENING | awk '{print $NF}' | sort -u || true)
if [ -n "${PORT_PIDS_8000:-}" ]; then
  for PID in $PORT_PIDS_8000; do
    taskkill //F //PID "$PID" >/dev/null 2>&1 || true
  done
  ok "Liberado puerto 8000 (PIDs: $PORT_PIDS_8000)"
else
  ok "Puerto 8000 libre"
fi

# Matar cualquier node.exe huérfano de un start:dev anterior
taskkill //F //IM node.exe >/dev/null 2>&1 || true
ok "Procesos node.exe previos finalizados"

# ---------- 2. Docker / PostgreSQL + Backend IA ----------
step "2/7 Levantando PostgreSQL + Backend IA Proxy (docker compose)"
if ! command -v docker >/dev/null 2>&1; then
  fail "Docker no está instalado."
fi
if ! docker info >/dev/null 2>&1; then
  fail "Docker está instalado pero no corriendo. Abre Docker Desktop y reintenta."
fi

# Verificar que Backend-IA-Proxy/.env existe
if [ ! -f "Backend-IA-Proxy/.env" ]; then
  if [ -f "Backend-IA-Proxy/.env.example" ]; then
    warn "Backend-IA-Proxy/.env no existe — copiando de .env.example"
    cp Backend-IA-Proxy/.env.example Backend-IA-Proxy/.env
    warn "⚠️  IMPORTANTE: Edita Backend-IA-Proxy/.env y agrega tus API keys"
    echo "   1. GROQ_API_KEY: https://console.groq.com"
    echo "   2. HUGGINGFACE_API_KEY: https://huggingface.co/settings/tokens"
    echo ""
  else
    fail "Falta Backend-IA-Proxy/.env y no hay .env.example"
  fi
fi

docker compose up -d
ok "Contenedores 'farmlink-db' y 'farmlink-ai-proxy' arriba"

for i in $(seq 1 30); do
  if docker exec farmlink-db pg_isready -U postgres >/dev/null 2>&1; then
    ok "PostgreSQL responde"
    break
  fi
  if [ "$i" = "30" ]; then
    fail "PostgreSQL no respondió en 30 s"
  fi
  sleep 1
done

# Health check Backend IA
step "2.5/7 Esperando Backend IA Proxy en http://localhost:8000/health"
AI_HEALTH_OK=0
for i in $(seq 1 60); do
  set +e
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>/dev/null)
  set -e
  if [ "$CODE" = "200" ]; then
    echo
    ok "Backend IA OK (HTTP 200)"
    AI_HEALTH_OK=1
    break
  fi
  printf "."
  sleep 1
done

if [ "$AI_HEALTH_OK" != "1" ]; then
  echo
  echo "Logs del Backend IA:"
  docker logs farmlink-ai-proxy 2>&1 | tail -20 || true
  fail "Backend IA no respondió en 60 s. Verifica:"
  echo "  1. GROQ_API_KEY configurado en Backend-IA-Proxy/.env"
  echo "  2. HUGGINGFACE_API_KEY configurado en Backend-IA-Proxy/.env"
  echo "  3. docker logs farmlink-ai-proxy"
fi

# ---------- 3. Backend: deps + migraciones + seed ----------
step "3/7 Preparando Backend (deps, migraciones, seed)"
cd "$ROOT/Backend"

if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    warn ".env no existe — copiando de .env.example"
    cp .env.example .env
  else
    fail "Falta Backend/.env y no hay .env.example"
  fi
else
  ok ".env presente"
fi

if [ ! -d node_modules ]; then
  warn "node_modules no existe — corriendo npm install (puede tardar)..."
  npm install
  ok "Dependencias instaladas"
else
  ok "node_modules ya existe"
fi

# Migraciones primero para que el seed encuentre el esquema.
# Idempotente: TypeORM saltea las ya aplicadas vía typeorm_migrations.
npm run migration:run
ok "Migraciones aplicadas"

# Seed vía wrapper (TRUNCATE + batch inserts, ~5-15s).
# Nota: seed.sh valida login si el backend está online; aquí todavía no lo está,
# así que solo correrá el seeder. Eso es OK — el backend hará migraciones y se
# levantará limpio en el siguiente paso.
bash "$ROOT/scripts/seed.sh"

# ---------- 4. Backend en background ----------
step "4/7 Levantando Backend NestJS en background"
mkdir -p "$ROOT/.run"
LOG_FILE="$ROOT/.run/backend.log"

cd "$ROOT/Backend"
nohup npm run start:dev > "$LOG_FILE" 2>&1 &
BACK_PID=$!
echo "$BACK_PID" > "$PID_FILE"
ok "Backend lanzado (PID $BACK_PID). Logs: .run/backend.log"

# ---------- 5. Health check ----------
step "5/7 Esperando a http://localhost:3000/api/docs"
HEALTH_OK=0
for i in $(seq 1 90); do
  set +e
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/docs 2>/dev/null)
  set -e
  if [ "$CODE" = "200" ]; then
    echo
    ok "Backend OK (HTTP 200 en /api/docs)"
    HEALTH_OK=1
    break
  fi
  printf "."
  sleep 1
done

if [ "$HEALTH_OK" != "1" ]; then
  echo
  echo "Últimas líneas del log del backend:"
  tail -50 "$LOG_FILE" || true
  fail "Backend no respondió 200 en 90 s"
fi

# ---------- 6. Frontend Flutter ----------
step "6/7 Levantando Frontend Flutter en Chrome"
cd "$ROOT/Frontend"

if ! command -v flutter >/dev/null 2>&1; then
  fail "Flutter no está en PATH. Instala Flutter o ajusta tu PATH."
fi

if [ ! -d .dart_tool ]; then
  warn ".dart_tool no existe — corriendo flutter pub get"
  flutter pub get
fi

cat <<EOF

${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${G}  ✓ Todos los servicios listos. Lanzando Flutter en Chrome…${NC}

  Backend NestJS: http://localhost:3000/api
  Swagger:        http://localhost:3000/api/docs
  Backend IA:     http://localhost:8000
  IA Docs:        http://localhost:8000/docs
  IA Health:      http://localhost:8000/health
  
  Logs NestJS:    tail -f .run/backend.log
  Logs IA:        docker logs farmlink-ai-proxy -f

  Login demo:
    Email:    admin@farmlink.com
    Password: admin123
    Tenant:   tenant-demo

  Ctrl+C cierra Flutter; los servicios siguen vivos.
  Para detener el backend:       ./scripts/stop.sh
  Para detener todo (+ docker):  ./scripts/stop.sh --all
  
  📚 IMPORTANTE: 
    • Los modelos de IA se ejecutan REMOTAMENTE (APIs de Groq + HuggingFace)
    • Verifica que Backend-IA-Proxy/.env tenga tus API keys configuradas
    • Si Backend IA falla, revisa: docker logs farmlink-ai-proxy
${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

EOF

exec flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
