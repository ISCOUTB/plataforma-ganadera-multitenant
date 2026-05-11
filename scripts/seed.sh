#!/usr/bin/env bash
# scripts/seed.sh — wrapper sobre `npm run seed` (TypeORM batch insert).
#
# La lógica de siembra ahora vive en Backend/src/seed/seed.ts y se ejecuta
# vía `npm run seed` (DataSource standalone, sin pasar por HTTP). Este script
# solo:
#   1. Verifica que el backend esté corriendo (para Swagger en /api/docs).
#   2. Ejecuta el seeder Node (TRUNCATE + batch inserts, ~5-15s).
#   3. Valida que el admin sembrado puede loguearse vía /auth/login.
#
# El backend NO necesita estar online para que el seeder funcione (escribe
# directo a Postgres), pero lo verificamos para detectar entorno roto antes
# de borrar datos.

set -e

API="${API:-http://localhost:3000/api}"
EMAIL="admin@farmlink.com"
PASSWORD="admin123"

BLUE="\033[0;34m"; GREEN="\033[0;32m"; RED="\033[0;31m"; YELLOW="\033[1;33m"; NC="\033[0m"
log()  { echo -e "${BLUE}[seed]${NC} $1"; }
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
err()  { echo -e "  ${RED}✗${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../Backend"

log "Verificando backend en $API/docs ..."
CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API/docs" || echo 000)
if [ "$CODE" != "200" ]; then
  warn "Backend respondió HTTP $CODE — el seeder funcionará igual (escribe directo a Postgres),"
  warn "pero no podremos validar el login del admin al final."
  warn "Para arrancarlo: cd Backend && npm run start:dev"
else
  ok "Backend online"
fi

warn "El seeder ejecutará TRUNCATE CASCADE — se borrarán TODOS los datos del tenant demo."

log "Ejecutando seeder TypeORM (batch inserts, 5 años de operación)..."
( cd "$BACKEND_DIR" && npm run seed )

if [ "$CODE" = "200" ]; then
  log "Validando login del admin sembrado..."
  TOKEN=$(curl -s -X POST "$API/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('access_token',''))" 2>/dev/null || echo "")
  if [ -n "$TOKEN" ]; then
    ok "Login OK — datos demo listos"
  else
    err "Login falló — revisa el hash bcrypt en seedAdmin()"
    exit 1
  fi
fi

log "Listo. Abre el dashboard y verifica las 3 fincas con tendencias 2021-2026."
