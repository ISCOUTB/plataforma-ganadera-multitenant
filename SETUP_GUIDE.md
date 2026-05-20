# 🚀 GUÍA DE INSTALACIÓN Y PRIMER ARRANQUE

## Paso 1: Obtener API Keys (5 minutos)

### 1.1 Groq API Key (Llama 3B)
```bash
# 1. Abre en tu navegador:
https://console.groq.com

# 2. Crea una cuenta (email + contraseña)
# 3. Verifica tu email
# 4. Ve a Settings → API Keys → Create New API Key
# 5. Copia el key (empieza con "gsk_")
# Ejemplo: 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
```

### 1.2 HuggingFace API Key
```bash
# 1. Abre en tu navegador:
https://huggingface.co/settings/tokens

# 2. Crea una cuenta (email + contraseña)
# 3. Verifica tu email
# 4. Ve a Settings → Access Tokens → New token
# 5. Nombre: "farmlink-dev"
# 6. Permisos: Read
# 7. Copia el token (empieza con "hf_")
# Ejemplo: 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
```

### 1.3 (Opcional) ngrok AuthToken
```bash
# Solo si quieres testing remoto (otro developer pruebe tu Backend IA)

# 1. Abre: https://dashboard.ngrok.com/auth/your-authtoken
# 2. Crea cuenta gratuita
# 3. Copia tu authtoken personal
# Ejemplo: 3_abc123def456ghi789
```

---

## Paso 2: Configurar Variables de Entorno

### 2.1 Crear `.env` en la raíz del proyecto

```bash
cd ~/plataforma-ganadera-multitenant  # Tu proyecto

# Copiar template
cp .env.example .env

# Editar (usa tu editor favorito)
# Opciones:
#   Windows: notepad .env
#   macOS/Linux: nano .env  (Ctrl+O, Enter, Ctrl+X)
#   VS Code: code .env
```

### 2.2 Llenar `.env` con tus valores

```env
# .env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=farmlink

# ← PEGA AQUÍ TUS API KEYS
GROQ_API_KEY=gsk_aBcDeFgHiJkLmNoPqRsTuVwXyZ
HUGGINGFACE_API_KEY=hf_aBcDeFgHiJkLmNoPqRsTuVwXyZ
NGROK_AUTHTOKEN=3_abc123def456ghi789  # (opcional)
```

### 2.3 Crear `.env` en Backend-IA-Proxy

```bash
# Copiar template
cp Backend-IA-Proxy/.env.example Backend-IA-Proxy/.env

# Editar
nano Backend-IA-Proxy/.env
```

```env
# Backend-IA-Proxy/.env
GROQ_API_KEY=gsk_aBcDeFgHiJkLmNoPqRsTuVwXyZ
HUGGINGFACE_API_KEY=hf_aBcDeFgHiJkLmNoPqRsTuVwXyZ
PORT=8000
ENVIRONMENT=development
```

### 2.4 Crear `.env` en Backend (si no existe)

```bash
# Copiar template
cp Backend/.env.example Backend/.env

# Editar
nano Backend/.env
```

```env
# Backend/.env
DB_HOST=localhost
DB_PORT=5433
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE=farmlink

PORT=3000

JWT_SECRET=tu-secreto-super-seguro-aqui-64-caracteres
JWT_EXPIRES_IN=1d
JWT_REFRESH_SECRET=otro-secreto-distinto-64-caracteres
JWT_REFRESH_EXPIRES_IN=7d

CORS_ORIGIN=http://localhost:5173,http://localhost:3000,http://localhost:8080

# ← IMPORTANTE: Apunta al Backend IA Proxy
AI_PROXY_URL=http://localhost:8000
```

---

## Paso 3: Verificar Requisitos

```bash
# Windows, macOS o Linux - verifica esto:

# 1. Docker Desktop está corriendo
#    En Windows/macOS: Abre la app "Docker"
#    En Linux: systemctl status docker

# 2. Git Bash (Windows) o Terminal (macOS/Linux)
which bash        # Debe existir

# 3. Node.js + npm (para Backend NestJS)
node --version    # v18+ recomendado
npm --version     # 9+

# 4. Flutter (para Frontend)
flutter --version

# 5. Python 3.11+ (para Backend IA Proxy)
python3 --version

# Si algo falta, instálalo primero
```

---

## Paso 4: Ejecutar `./scripts/start.sh`

### 4.1 En Windows (Git Bash)

```bash
cd C:\Users\tu-usuario\tu-ruta\plataforma-ganadera-multitenant

# Primera vez: hacer ejecutable
chmod +x scripts/start.sh

# Ejecutar
./scripts/start.sh
```

### 4.2 En macOS/Linux

```bash
cd ~/plataforma-ganadera-multitenant

# Primera vez: hacer ejecutable
chmod +x scripts/start.sh

# Ejecutar
./scripts/start.sh
```

---

## Paso 5: Qué Pasa Mientras se Ejecuta

El script hace esto **automáticamente** (no necesitas hacer nada):

```
1. Limpia puertos anteriores (3000, 8000)
   ✓ Libera puerto 3000 (Backend NestJS)
   ✓ Libera puerto 8000 (Backend IA)

2. Levanta Docker Compose
   ✓ PostgreSQL (farmlink-db) en :5433
   ✓ Backend IA Proxy (farmlink-ai-proxy) en :8000
   
3. Espera a que PostgreSQL responda
   ⏳ Retry 1/30, 2/30, ...
   ✓ PostgreSQL responde

4. Espera a que Backend IA responda
   ⏳ Health check :8000/health
   ✓ Backend IA OK

5. Prepara Backend NestJS
   ✓ npm install (si falta node_modules)
   ✓ Migraciones de BD
   ✓ Seed de datos

6. Lanza Backend NestJS en background
   ✓ npm run start:dev
   
7. Espera a que Backend responda
   ⏳ Health check :3000/api/docs
   ✓ Backend OK

8. Lanza Frontend Flutter en Chrome
   ✓ flutter run -d chrome
```

**Tiempo total**: 2-3 minutos (primera vez), 30-60s (segunda vez)

---

## Paso 6: Verificar Todo Está OK

Una vez que Flutter se abre, verifica en una **nueva terminal**:

```bash
# Terminal nueva (mientras Flutter está corriendo)

# 1. PostgreSQL OK
curl -s http://localhost:5433 || echo "PostgreSQL OK (puerto no expuesto HTTP)"

# 2. Backend IA OK
curl http://localhost:8000/health
# Respuesta: {"status":"ok","service":"farmlink-ai-proxy",...}

# 3. Backend NestJS OK
curl http://localhost:3000/api/docs
# Respuesta: HTML de Swagger

# 4. Probar AI Chat
curl -X POST http://localhost:8000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "tenant_id": "test",
    "messages": [{"role": "user", "content": "Hola"}]
  }'
# Respuesta: {"tenant_id":"test","response":"..."}
```

---

## Paso 7: Login en Frontend

En Chrome, cuando se abre Flutter:

```
Email:    admin@farmlink.com
Password: admin123
Tenant:   tenant-demo
```

---

## Probar Endpoints de IA

### Test 1: Chat

```bash
# Con JWT válido (obtén del login del Frontend)
curl -X POST http://localhost:3000/api/ai/chat \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "¿Cómo cuidar un ternero recién nacido?"}
    ]
  }'
```

### Test 2: Predicción

```bash
# Envía series temporales históricas (últimos 90 días)
curl -X POST http://localhost:3000/api/ai/predict \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "metric": "weight",
    "values": [45.2, 46.1, 47.3, 48.1, 48.9, 49.5, 50.1, 50.8, 51.4, 52.0, 52.6],
    "steps": 30
  }'
```

---

## Troubleshooting

### Problem: "GROQ_API_KEY no configurado"

```bash
# Edita Backend-IA-Proxy/.env
nano Backend-IA-Proxy/.env

# Verifica que contiene:
GROQ_API_KEY=gsk_...
HUGGINGFACE_API_KEY=hf_...

# Reinicia docker
docker-compose restart backend-ai
docker logs farmlink-ai-proxy
```

### Problem: "Backend IA no respondió en 60s"

```bash
# Ver logs del Backend IA
docker logs farmlink-ai-proxy -f

# Causas comunes:
# 1. API keys inválidas
# 2. Sin conexión a internet
# 3. Groq/HuggingFace caídos
```

### Problem: "PostgreSQL no respondió"

```bash
# Verifica Docker Desktop está corriendo
docker ps

# Si no ves farmlink-db, reinicia
docker-compose down
docker-compose up -d
```

### Problem: "Puerto 3000/8000 ya está en uso"

```bash
# El script intenta liberar automáticamente
# Si aún falla, matá procesos manualmente

# Windows:
tasklist | findstr :3000
taskkill /PID <PID> /F

# macOS/Linux:
lsof -i :3000
kill -9 <PID>
```

---

## Para Desarrollo Remoto (Otro Developer)

Si otro developer quiere usar tu Backend IA desde su máquina:

```bash
# Terminal 1: Tu máquina - Backend IA local
./scripts/dev-ai-tunnel.sh local

# Terminal 2: Tu máquina - Expone con ngrok
export NGROK_AUTHTOKEN=tu_token
./scripts/dev-ai-tunnel.sh expose

# Output:
# ✓ Backend IA expuesto en: https://xxx-yyy-zzz.ngrok.io

# Comparte esta URL con el otro developer:
# Agrégala a su Backend/.env:
AI_PROXY_URL=https://xxx-yyy-zzz.ngrok.io
```

---

## Detener Servicios

```bash
# Opción 1: Solo Backend NestJS
./scripts/stop.sh

# Opción 2: Backend + Docker (PostgreSQL + Backend IA)
./scripts/stop.sh --all

# Opción 3: Manual
docker-compose down
```

---

## Próximos Pasos

1. **Crear UI en Flutter** para consumir `/api/ai/chat` y `/api/ai/predict`
2. **Integrar gráficas** para mostrar predicciones
3. **Cache de predicciones** en PostgreSQL
4. **Auditoría y logging** de solicitudes de IA
5. **Rate limiting** por tenant

---

¡Listo! Si todo funcionó, deberías ver:

```
✓ Backend listo. Lanzando Flutter en Chrome…

  Backend NestJS: http://localhost:3000/api
  Swagger:        http://localhost:3000/api/docs
  Backend IA:     http://localhost:8000
  IA Docs:        http://localhost:8000/docs
  
  📚 IMPORTANTE: 
    • Los modelos de IA se ejecutan REMOTAMENTE
    • Verifica Backend-IA-Proxy/.env tiene API keys
```

¡Buena suerte! 🚀
