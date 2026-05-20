# 🤖 Backend IA - Arquitectura y Modelo de Ejecución

## ¿Dónde corren los modelos de IA?

**RESPUESTA CORTA**: Los modelos corre **REMOTAMENTE** en servidores de terceros (Groq + HuggingFace), NO en tu máquina local.

### Diagrama de Flujo

```
┌─────────────────────────────────┐
│  Frontend (Flutter/React)       │
│  Envía solicitud de IA          │
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│  Backend NestJS (3000)          │
│  Valida usuario + tenant        │
│  Llamada HTTP al Backend IA     │
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│  Backend IA Proxy (8000)        │
│  FastAPI (contenedor Docker)    │
│  - Recibe solicitud             │
│  - Redirige a APIs remotas      │
└──┬────────────────────────────┬─┘
   │                            │
   ▼                            ▼
┌──────────────────┐   ┌─────────────────────────┐
│ Groq API Cloud   │   │ HuggingFace Inference   │
│ (Llama 3B)       │   │ (Chronos-2 predicciones)│
│ https://...      │   │ https://...             │
└──────────────────┘   └─────────────────────────┘
   │                            │
   └──────┬─────────────────────┘
          ▼
   ┌─────────────────────┐
   │  Backend IA Proxy   │
   │  (recibe respuesta) │
   └────────┬────────────┘
            │
            ▼
   ┌─────────────────────┐
   │ Backend NestJS      │
   │ (parsea resultado)  │
   └────────┬────────────┘
            │
            ▼
   ┌─────────────────────┐
   │ Frontend            │
   │ (muestra resultado) │
   └─────────────────────┘
```

---

## Desglose: ¿Qué es cada componente?

### 1. **Backend IA Proxy** (Contenedor Docker en tu máquina)
- **Ubicación**: `Backend-IA-Proxy/main.py`
- **Función**: Intermediario que redirige llamadas a APIs remotas
- **Puerto**: `8000` (localhost)
- **Modelo de ejecución**: LOCAL (en tu máquina, dentro de Docker)
- **Requisitos**: Python 3.11, FastAPI, httpx
- **¿Descarga modelos?**: NO. Solo HTTP client.

### 2. **Groq API** (Llama 3B - Servidor remoto)
- **Ubicación**: `https://api.groq.com/...` (servidores de Groq en la nube)
- **Función**: Ejecuta el modelo Llama 3B para chat
- **Requisito**: API Key (gratis, límite 2000 req/min)
- **Modelo de ejecución**: REMOTO (en servidores de Groq)
- **¿Descargas modelos?**: NO. Ya están en servidores de Groq.
- **Latencia**: <100ms (muy rápido)

### 3. **HuggingFace Inference** (Chronos-2 - Servidor remoto)
- **Ubicación**: `https://api-inference.huggingface.co/...` (servidores de HuggingFace)
- **Función**: Predicciones de series temporales (ej: producción de leche)
- **Requisito**: API Key (gratis)
- **Modelo de ejecución**: REMOTO (en servidores de HuggingFace)
- **¿Descargas modelos?**: NO. Ya están en servidores de HuggingFace.
- **Latencia**: 200-500ms

---

## ¿Por qué es remoto?

| Ventaja | Detalles |
|---------|----------|
| **Sin GPU requerida** | Los modelos corren en GPUs de Groq/HuggingFace |
| **Sin descargar modelos** | No ocupan 2GB+ en tu máquina |
| **Sin memoria local** | No necesitas 8GB+ RAM para la inferencia |
| **Instant setup** | Solo obtén API keys, no instalaciones complejas |
| **Escalable** | Si 1 usuario → 10 → 1000, solo cambia el plan de API |
| **Seguro** | Datos de IA procesados en servidores certif icados |

---

## Setup: Obtener API Keys (5 min)

### 1. GROQ API Key (Llama 3B)

```bash
# 1. Ve a: https://console.groq.com
# 2. Crea cuenta (gratis)
# 3. Ve a Settings → API Keys
# 4. Copia tu key
# 5. Agrega a Backend-IA-Proxy/.env:
GROQ_API_KEY=gsk_your_key_here
```

**Límites gratis**: 2000 req/min (más que suficiente para desarrollo)

### 2. HuggingFace API Key (Chronos-2)

```bash
# 1. Ve a: https://huggingface.co/settings/tokens
# 2. Crea cuenta (gratis)
# 3. Genera un "Access Token"
# 4. Copia el token
# 5. Agrega a Backend-IA-Proxy/.env:
HUGGINGFACE_API_KEY=hf_your_key_here
```

**Límites gratis**: Inference API gratuita (sin cuota)

---

## Flujo de una Solicitud

### Ejemplo 1: Chat con Llama

```
Usuario Frontend:
  POST /api/ai/chat
  Body: {
    "messages": [
      {"role": "user", "content": "¿Cómo aumentar la producción de leche?"}
    ]
  }
  
↓ (con JWT + tenant_id)

Backend NestJS (ai.controller.ts):
  • Valida JWT y tenant_id
  • Llama a AiService.chat()
  
↓

AiService (ai.service.ts):
  • Prepara payload
  • POST http://localhost:8000/chat/completions
  
↓

Backend IA Proxy (main.py):
  • Recibe solicitud
  • Añade tenant_id al log
  • POST https://api.groq.com/... (con tu API key)
  
↓ (HTTP request a Groq)

Groq Cloud Servers:
  • Ejecuta Llama 3B
  • Devuelve respuesta en <100ms
  
↓

Backend IA Proxy:
  • Recibe respuesta de Groq
  • Extrae texto
  • Devuelve al Backend NestJS
  
↓

Backend NestJS:
  • Recibe respuesta
  • La devuelve al Frontend
  
↓

Frontend:
  • Muestra respuesta al usuario
```

**Tiempo total**: ~500ms (mayoría es red roundtrip)

---

## Flujo de una Predicción

### Ejemplo 2: Predicción de Peso de Animal

```
Usuario Frontend:
  POST /api/ai/predict
  Body: {
    "metric": "weight",
    "values": [45.2, 46.1, 47.3, 48.1, ...],  // últimos 90 días
    "steps": 30  // predecir 30 días adelante
  }
  
↓

Backend NestJS:
  • Valida tenant_id
  • Valida que el animal pertenece a este tenant
  • Obtiene últimos 90 registros de peso de BD
  • POST http://localhost:8000/predict
  
↓

Backend IA Proxy:
  • Recibe solicitud
  • POST https://api-inference.huggingface.co/... (con tu API key)
  • Body: {"inputs": [45.2, 46.1, 47.3, ...]}
  
↓ (HTTP request a HuggingFace)

HuggingFace Cloud Servers:
  • Ejecuta Chronos-2
  • Genera 30 predicciones con intervalos de confianza
  • Devuelve array: [49.2, 50.1, 51.0, ...]
  
↓

Backend IA Proxy:
  • Recibe predicciones
  • Devuelve al Backend NestJS
  
↓

Backend NestJS:
  • Almacena predicción en BD (cache)
  • Devuelve al Frontend
  
↓

Frontend:
  • Gráfica las predicciones
```

**Tiempo total**: ~1-2s (HuggingFace es más lento que Groq)

---

## Seguridad Multitenant

✅ **Protección implementada**:

1. **Validación en NestJS**
   ```typescript
   // ai.controller.ts
   const tenantId = req.user.tenantId;  // Extraído del JWT
   // Valida que el animal pertenece a este tenant
   const animal = await this.animalsService.findOne(dto.animal_id, tenantId);
   ```

2. **Datos filtrados antes de Backend IA**
   ```typescript
   // Solo se envía a Backend IA los datos ya filtrados por tenant
   const timeseries = await db.query(
     'SELECT weight FROM weight_records WHERE animal_id = $1 AND finca_id = $2',
     [animal_id, finca_id]  // ← Scoped a este tenant
   );
   ```

3. **Logging y auditoría**
   ```python
   # Backend IA Proxy registra tenant_id en cada solicitud
   logger.info(f"Chat request from tenant: {tenant_id}")
   ```

❌ **Nunca hacemos**:
- Entrenar modelos con datos de múltiples tenants
- Compartir datos entre fincas
- Exponer datos sensibles a APIs remotas sin cifrar

---

## Troubleshooting

### Problem: "GROQ_API_KEY no configurado"

**Solución**:
```bash
# 1. Edita Backend-IA-Proxy/.env
nano Backend-IA-Proxy/.env

# 2. Agrega tu key:
GROQ_API_KEY=gsk_tu_key_aqui

# 3. Reinicia Docker:
docker-compose restart backend-ai
```

### Problem: "HuggingFace API timeout"

**Solución**:
```bash
# 1. Verifica que tu key es válida
# 2. Prueba directamente:
curl -X POST \
  https://api-inference.huggingface.co/models/amazon/chronos-t5-small \
  -H "Authorization: Bearer hf_tu_key" \
  -H "Content-Type: application/json" \
  -d '{"inputs": [1.0, 2.0, 3.0, 4.0, 5.0]}'

# 3. Si falla, tu key podría estar mal
```

### Problem: "Backend IA responde 500"

**Ver logs**:
```bash
docker logs farmlink-ai-proxy -f
```

**Causas comunes**:
- API keys inválidas
- Sin conexión a internet
- Rate limit excedido en Groq/HuggingFace

---

## Para Testing Remoto (ngrok)

Si quieres que otro developer use el Backend IA desde su máquina:

```bash
# Terminal 1: Backend IA local
./scripts/dev-ai-tunnel.sh local

# Terminal 2: Expone con ngrok
./scripts/dev-ai-tunnel.sh expose

# Output:
# Backend IA expuesto en: https://xxx-yyy-zzz.ngrok.io
# Pasa esta URL al otro developer
```

---

## Costos (Desarrollo Local)

| Servicio | Costo (Gratis) | Límite |
|----------|---|---|
| **Groq** | $0 | 2000 req/min |
| **HuggingFace** | $0 | Inference API |
| **Docker** | $0 | Local |
| **Total** | **$0** | Suficiente para dev |

---

## Escalabilidad a Producción

Cuando escales a producción:

| Componente | Desarrollo Local | Producción |
|-----------|---|---|
| **Backend IA Proxy** | Docker local | Kubernetes/ECS |
| **Groq** | API Cloud (pago) | API Cloud (pago) |
| **HuggingFace** | API Cloud (pago) | API Cloud (pago) |
| **Base de Datos** | PostgreSQL local | RDS/PostgreSQL Cloud |
| **Ngrok** | Temporal | CloudFlare Tunnel / VPN privada |

---

## Resumen

✅ **Los modelos de IA NO se descargan ni ejecutan localmente**
✅ **Todo corre en APIs remotas de Groq + HuggingFace**
✅ **Backend IA Proxy es solo un proxy HTTP**
✅ **Setup simple: solo obtén 2 API keys gratuitas**
✅ **Seguridad multitenant garantizada en NestJS**

