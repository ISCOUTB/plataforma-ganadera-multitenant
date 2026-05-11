#!/usr/bin/env bash
#
# scripts/stop.sh — Detiene el backend y opcionalmente postgres.
#
# Uso:
#   ./scripts/stop.sh         # solo backend
#   ./scripts/stop.sh --all   # backend + docker postgres

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PIDFILE="$ROOT/.run/backend.pid"

G='\033[0;32m'
Y='\033[1;33m'
NC='\033[0m'

if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE")
  if kill -0 "$PID" 2>/dev/null; then
    # Mata el proceso y todos sus hijos (nest start --watch lanza un subproceso)
    pkill -P "$PID" 2>/dev/null || true
    kill "$PID" 2>/dev/null || true
    echo -e "${G}✓${NC} Backend detenido (PID $PID)"
  else
    echo -e "${Y}⚠${NC} El PID $PID ya no existía"
  fi
  rm -f "$PIDFILE"
else
  echo -e "${Y}⚠${NC} No hay backend marcado como corriendo (.run/backend.pid no existe)"
fi

# Por si el watch dejó subprocesos huérfanos
pkill -f "nest start" 2>/dev/null && echo -e "${G}✓${NC} Procesos 'nest start' huérfanos eliminados" || true

if [ "$1" = "--all" ]; then
  cd "$ROOT"
  docker compose down
  echo -e "${G}✓${NC} Docker postgres detenido"
fi
