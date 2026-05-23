#!/usr/bin/env bash
#
# scripts/start.sh — Levanta TODO FarmLink (DB + Backend + Frontend Flutter)
# con un solo comando.
#
# Uso (Git Bash en Windows):
#   chmod +x scripts/start.sh   # solo la primera vez
#   ./scripts/start.sh
#
# Pasos:
#   1. Limpieza forzosa: PID file previo, puerto 3000 y node.exe huérfanos.
#   2. docker compose up -d  (PostgreSQL en farmlink-db).
#   3. IA Proxy: pip install, uvicorn main:app en background (logs en .run/ai_proxy.log).
#   4. Backend: npm install (si falta), migration:run, seed (vía seed.sh).
#   5. Backend: npm run start:dev en background (logs en .run/backend.log).
#   6. Health check: poll http://localhost:3000/api/docs hasta 200 OK.
#   7. Frontend: flutter run -d chrome --dart-define=API_BASE_URL=...
#
# Para detener el backend tras cerrar Flutter (Ctrl+C):
#   ./scripts/stop.sh          # solo backend
#   ./scripts/stop.sh --all    # backend + docker postgres

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

for PF in backend.pid ai_proxy.pid; do
  PF_PATH="$ROOT/.run/$PF"
  if [ -f "$PF_PATH" ]; then
    OLD_PID="$(cat "$PF_PATH" 2>/dev/null || true)"
    if [ -n "${OLD_PID:-}" ]; then
      kill "$OLD_PID" 2>/dev/null || true
    fi
    rm -f "$PF_PATH"
  fi
done

# Liberar puertos 3000 y 8000 si están ocupados (Windows: netstat + taskkill)
for PORT in 3000 8000; do
  PORT_PIDS=$(netstat -ano 2>/dev/null | grep ":$PORT " | grep -i LISTENING | awk '{print $NF}' | sort -u || true)
  if [ -n "${PORT_PIDS:-}" ]; then
    for PID in $PORT_PIDS; do
      taskkill //F //PID "$PID" >/dev/null 2>&1 || true
    done
    ok "Liberado puerto $PORT (PIDs: $PORT_PIDS)"
  else
    ok "Puerto $PORT libre"
  fi
done

# Matar cualquier node.exe huérfano de un start:dev anterior
taskkill //F //IM node.exe >/dev/null 2>&1 || true
ok "Procesos node.exe previos finalizados"

# ---------- 2. Docker / PostgreSQL ----------
step "2/7 Levantando PostgreSQL (docker compose)"
if ! command -v docker >/dev/null 2>&1; then
  fail "Docker no está instalado."
fi
if ! docker info >/dev/null 2>&1; then
  fail "Docker está instalado pero no corriendo. Abre Docker Desktop y reintenta."
fi

docker compose up -d
ok "Contenedor 'farmlink-db' arriba"

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

# ---------- 3. Backend IA Proxy ----------
step "3/7 Levantando Backend IA Proxy"
AI_PROXY_DIR="$ROOT/Backend-IA-Proxy"

if [ ! -f "$AI_PROXY_DIR/.env" ]; then
  if [ -f "$AI_PROXY_DIR/.env.example" ]; then
    warn "IA Proxy .env no existe — copiando de .env.example"
    cp "$AI_PROXY_DIR/.env.example" "$AI_PROXY_DIR/.env"
  else
    fail "Falta Backend-IA-Proxy/.env y no hay .env.example"
  fi
else
  ok "IA Proxy .env presente"
fi

if [ ! -d "$AI_PROXY_DIR/__pycache__" ]; then
  warn "Dependencias Python no instaladas — corriendo pip install..."
  cd "$AI_PROXY_DIR"
  pip install -r requirements.txt > /dev/null 2>&1 || \
    pip3 install -r requirements.txt > /dev/null 2>&1 || \
    warn "No se pudo instalar dependencias Python (pip no encontrado)"
  ok "Dependencias Python instaladas"
else
  ok "Dependencias Python ya instaladas"
fi

mkdir -p "$ROOT/.run"
AI_LOG_FILE="$ROOT/.run/ai_proxy.log"
AI_PID_FILE="$ROOT/.run/ai_proxy.pid"

cd "$AI_PROXY_DIR"
nohup python -m uvicorn main:app --host 0.0.0.0 --port 8000 > "$AI_LOG_FILE" 2>&1 &
AI_PID=$!
echo "$AI_PID" > "$AI_PID_FILE"
ok "IA Proxy lanzado (PID $AI_PID). Logs: .run/ai_proxy.log"

for i in $(seq 1 15); do
  set +e
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>/dev/null)
  set -e
  if [ "$CODE" = "200" ]; then
    ok "IA Proxy responde (HTTP 200)"
    break
  fi
  if [ "$i" = "15" ]; then
    warn "IA Proxy no respondió en 15 s (el chat usará modo offline)"
  fi
  sleep 1
done

cd "$ROOT"

# ---------- 4. Backend: deps + migraciones + seed ----------
step "4/7 Preparando Backend (deps, migraciones, seed)"
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

# ---------- 5. Backend en background ----------
step "5/7 Levantando Backend NestJS en background"
mkdir -p "$ROOT/.run"
LOG_FILE="$ROOT/.run/backend.log"

cd "$ROOT/Backend"
nohup npm run start:dev > "$LOG_FILE" 2>&1 &
BACK_PID=$!
echo "$BACK_PID" > "$ROOT/.run/backend.pid"
ok "Backend lanzado (PID $BACK_PID). Logs: .run/backend.log"

# ---------- 6. Health check ----------
step "6/7 Esperando a http://localhost:3000/api/docs"
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

# ---------- 7. Frontend Flutter ----------
step "7/7 Levantando Frontend Flutter en Chrome"
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
${G}  ✓ Backend listo. Lanzando Flutter en Chrome…${NC}

  Backend:  http://localhost:3000/api
  Swagger:  http://localhost:3000/api/docs
  IA Proxy: http://localhost:8000/health
  Logs:     tail -f .run/backend.log
  AI Logs:  tail -f .run/ai_proxy.log

  Login demo:
    Email:    admin@farmlink.com
    Password: admin123
    Tenant:   tenant-demo

  Ctrl+C cierra Flutter; el backend sigue vivo.
  Para detenerlo:        ./scripts/stop.sh
  Para detener todo:     ./scripts/stop.sh --all
${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

EOF

exec flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
