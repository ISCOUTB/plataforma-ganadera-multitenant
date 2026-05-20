#!/usr/bin/env bash
#
# scripts/dev-ai-tunnel.sh
# Arranca Backend IA + expone vía ngrok (opcional)
#
# Uso:
#   ./scripts/dev-ai-tunnel.sh local    # Sin ngrok (para Android emulator)
#   ./scripts/dev-ai-tunnel.sh expose   # Con ngrok (para dispositivo físico)
#
# Requisitos:
#   - Python 3.11+
#   - FastAPI + dependencies (pip install -r Backend-IA-Proxy/requirements.txt)
#   - ngrok instalado (solo si usas "expose")
#   - .env configurado con GROQ_API_KEY y HUGGINGFACE_API_KEY
#

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; B='\033[0;34m'; NC='\033[0m'
step()  { echo -e "\n${B}▶ $1${NC}"; }
ok()    { echo -e "${G}  ✓${NC} $1"; }
warn()  { echo -e "${Y}  ⚠${NC} $1"; }
fail()  { echo -e "${R}  ✗${NC} $1"; exit 1; }

MODE="${1:-local}"

# ============================================================================
# SETUP: Verificar directorios y dependencias
# ============================================================================

step "Setup: Verificando Backend-IA-Proxy"

if [ ! -d "Backend-IA-Proxy" ]; then
  fail "Directorio Backend-IA-Proxy no encontrado"
fi

if [ ! -f "Backend-IA-Proxy/main.py" ]; then
  fail "Backend-IA-Proxy/main.py no encontrado"
fi

if [ ! -f "Backend-IA-Proxy/.env" ]; then
  if [ -f "Backend-IA-Proxy/.env.example" ]; then
    warn "Backend-IA-Proxy/.env no existe — copiando de .env.example"
    cp Backend-IA-Proxy/.env.example Backend-IA-Proxy/.env
    echo ""
    echo "⚠️  IMPORTANTE: Edita Backend-IA-Proxy/.env y agrega tus API keys:"
    echo "   1. GROQ_API_KEY (obtén en https://console.groq.com)"
    echo "   2. HUGGINGFACE_API_KEY (obtén en https://huggingface.co/settings/tokens)"
    echo ""
  else
    fail "Falta Backend-IA-Proxy/.env y no hay .env.example"
  fi
fi

# Verificar Python
if ! command -v python3 >/dev/null 2>&1; then
  fail "Python 3 no está instalado o no está en PATH"
fi
ok "Python 3 disponible"

# Verificar dependencias
cd Backend-IA-Proxy
if [ ! -d "venv" ]; then
  warn "venv no existe — creando entorno virtual"
  python3 -m venv venv
  ok "Entorno virtual creado"
fi

# Activar venv (compatible Windows + Unix)
if [ -f "venv/Scripts/activate" ]; then
  source venv/Scripts/activate  # Git Bash en Windows
elif [ -f "venv/bin/activate" ]; then
  source venv/bin/activate      # macOS/Linux
fi

if ! python3 -c "import fastapi" 2>/dev/null; then
  warn "Instalando dependencias (pip install -r requirements.txt)..."
  pip install -q -r requirements.txt
  ok "Dependencias instaladas"
fi

cd "$ROOT"

# ============================================================================
# MODO 1: LOCAL (sin ngrok)
# ============================================================================

if [ "$MODE" = "local" ]; then
  step "Iniciando Backend IA en modo LOCAL"
  echo ""
  echo "Configuración:"
  echo "  Servidor: http://localhost:8000"
  echo "  Docs: http://localhost:8000/docs"
  echo ""
  echo "Uso:"
  echo "  • Si usas Android emulator: Accede desde http://10.0.2.2:8000"
  echo "  • Si usas iOS emulator/Android dispositivo físico: Usa ngrok (run: ./scripts/dev-ai-tunnel.sh expose)"
  echo ""
  
  # Limpieza de puertos previos
  if command -v lsof >/dev/null 2>&1; then
    if lsof -i :8000 >/dev/null 2>&1; then
      warn "Puerto 8000 ocupado — intentando liberar"
      lsof -i :8000 | awk 'NR!=1 {print $2}' | xargs kill -9 2>/dev/null || true
      sleep 1
    fi
  fi
  
  cd Backend-IA-Proxy
  
  # Activar venv nuevamente
  if [ -f "venv/Scripts/activate" ]; then
    source venv/Scripts/activate
  elif [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
  fi
  
  echo ""
  ok "Levantando Backend IA..."
  python3 main.py

# ============================================================================
# MODO 2: EXPOSE (con ngrok)
# ============================================================================

elif [ "$MODE" = "expose" ]; then
  step "Iniciando Backend IA en modo EXPOSE (ngrok)"
  
  # Validar ngrok
  if ! command -v ngrok >/dev/null 2>&1; then
    fail "ngrok no está instalado. Instálalo desde https://ngrok.com/download"
  fi
  ok "ngrok disponible"
  
  # Validar authtoken
  if [ -z "$NGROK_AUTHTOKEN" ]; then
    echo ""
    echo "❌ NGROK_AUTHTOKEN no configurado"
    echo ""
    echo "Pasos para obtener tu authtoken:"
    echo "  1. Ve a https://dashboard.ngrok.com/auth/your-authtoken"
    echo "  2. Copia tu authtoken personal"
    echo "  3. Exportalo en tu terminal:"
    echo "     export NGROK_AUTHTOKEN=tu_token_aqui"
    echo "  4. Vuelve a ejecutar este script"
    echo ""
    fail "NGROK_AUTHTOKEN requerido"
  fi
  ok "NGROK_AUTHTOKEN configurado"
  
  # Health check del Backend IA
  step "Health check: Esperando Backend IA en :8000..."
  
  cd Backend-IA-Proxy
  
  # Activar venv
  if [ -f "venv/Scripts/activate" ]; then
    source venv/Scripts/activate
  elif [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
  fi
  
  # Iniciar Backend IA en background
  python3 main.py > /dev/null 2>&1 &
  AI_PID=$!
  
  cd "$ROOT"
  
  # Esperar a que responda
  HEALTH_OK=0
  for i in {1..30}; do
    if curl -s http://localhost:8000/health >/dev/null 2>&1; then
      ok "Backend IA responde"
      HEALTH_OK=1
      break
    fi
    if [ $i -eq 30 ]; then
      kill $AI_PID 2>/dev/null || true
      fail "Backend IA no respondió en 30s. Verifica:"
      echo "  - Las API keys en Backend-IA-Proxy/.env"
      echo "  - La conectividad a Groq y HuggingFace"
    fi
    printf "."
    sleep 1
  done
  
  echo ""
  
  if [ "$HEALTH_OK" != "1" ]; then
    kill $AI_PID 2>/dev/null || true
    fail "Backend IA no disponible"
  fi
  
  # Iniciar ngrok
  step "Exponiendo Backend IA via ngrok..."
  ngrok http 8000 --authtoken "$NGROK_AUTHTOKEN" > /dev/null 2>&1 &
  NGROK_PID=$!
  
  sleep 3
  
  # Capturar URL
  NGROK_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -o '"public_url":"[^"]*' | cut -d'"' -f4 | head -1)
  
  if [ -z "$NGROK_URL" ]; then
    kill $NGROK_PID 2>/dev/null || true
    kill $AI_PID 2>/dev/null || true
    fail "No se pudo obtener URL de ngrok"
  fi
  
  echo ""
  ok "Backend IA expuesto"
  
  cat <<EOF

${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${G}✓ Backend IA disponible via ngrok${NC}

URL pública: ${B}$NGROK_URL${NC}
Docs: ${B}$NGROK_URL/docs${NC}

Health: curl $NGROK_URL/health

${Y}⚠️  IMPORTANTE:${NC}
  • Esta URL es TEMPORAL (cambiará cada sesión)
  • NO la uses en producción
  • Comparte esta URL con otros developers para testing remoto

${Y}Para tu Frontend:${NC}
  Usa esta URL en tus variables de entorno (ej: .env, secrets):
    AI_BACKEND_URL=$NGROK_URL

${Y}Para detener:${NC}
  Presiona Ctrl+C

${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

EOF
  
  # Mantener procesos activos
  wait $NGROK_PID $AI_PID
  
else
  echo "Uso: $0 [local|expose]"
  echo ""
  echo "Opciones:"
  echo "  local  - Backend IA en http://localhost:8000 (sin ngrok)"
  echo "  expose - Backend IA expuesto via ngrok (para testing remoto)"
  exit 1
fi
