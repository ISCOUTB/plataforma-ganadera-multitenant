# Módulo de IA — FarmLink

## Arquitectura

```
Flutter (Dio, 45s timeout)
  → NestJS (POST /api/ai/*)
    → AI Proxy FastAPI (localhost:8000)
      → Groq API (llama-3.1-8b-instant)
      → HuggingFace (chronos-t5-small) [DNS bloqueado → fallback]
    → Motor de reglas (recomendaciones, sin proxy)
```

**Levantamiento:** `./scripts/start.sh` lanza AI proxy con `uvicorn` en background (no Docker).

---

## 1. Chatbot IA

### Endpoint
`POST /api/ai/chat`

### Request
```json
{ "messages": [{ "role": "user", "content": "¿Cómo aumentar la producción de leche?" }] }
```

### Response
```json
{ "status": 200, "response": "...", "tenant": "tenant-demo", "timestamp": "..." }
```

### Stack
| Capa | Tecnología |
|------|-----------|
| UI | `AiChatFab` — botón flotante + dialog 380×520 |
| State | `ChatBloc` (Initial → Loading → Success/Error) |
| HTTP | `IaRemoteDataSource` (Dio, `/ai/chat`) |
| Backend | `AiController` → `AiService.chat()` |
| AI Proxy | `POST /chat/completions` → Groq `llama-3.1-8b-instant` |

### Configuración Groq
- Historial limitado a últimos 10 mensajes
- System prompt: asistente ganadero, respuestas concisas (3-4 párrafos)
- `max_tokens: 512`, `temperature: 0.7`, timeout 30s
- Tier gratuito: 8000 TPM (tokens por minuto)

### Fixes aplicados
| Problema | Solución |
|----------|----------|
| `tenantId` vs `tenant_id` en JWT | Controller usa `req.user.tenant_id` (snake_case) |
| Doble `/api/` en URL | Datasource usa `/ai/chat` (sin prefijo) |
| Dio timeout 20s insuficiente | `receiveTimeout` aumentado a 45s |
| Parsing de respuesta | Maneja `String` y `Map<String, dynamic>` |
| Provider error en dialog | `tenantId`/`fincaId` pasados como parámetros |

---

## 2. Predicciones IA

### Endpoint
`POST /api/ai/predict`

### Request
```json
{ "metric": "weight", "values": [200, 210, 220, ...], "steps": 12 }
```
Mínimo 10 valores históricos. Métricas: `weight`, `income`, `expense`, `health`.

### Response
```json
{
  "tenant_id": "tenant-demo",
  "metric": "weight",
  "forecast": [271.5, 273.2, ...],
  "labels": ["22/05", "29/05", ...],
  "model": "holt-exponential",
  "confidence": 0.87,
  "trend": "up",
  "description": "Proyección de peso promedio: se espera aumento del 3.2% en 12 períodos...",
  "generatedAt": "2026-05-21T..."
}
```

### Stack
| Capa | Tecnología |
|------|-----------|
| UI | `IaPredictionsCard` — card con selector de métrica (Animales, Ingresos, Gastos, Salud) |
| State | `PredictionsBloc` |
| Backend | `AiService.predict()` → modelos matemáticos |

### Modelos matemáticos (ingeniería económica)

Cuando el AI proxy no responde (HuggingFace DNS bloqueado), NestJS usa 3 modelos y selecciona automáticamente el mejor:

| Modelo | Fórmula | Uso ideal |
|--------|---------|-----------|
| **Regresión lineal** | `y = a + b·x` (mínimos cuadrados) | Datos con tendencia clara |
| **Suavizado exponencial de Holt** | `L(t) = α·Y(t) + (1-α)(L+T)`, `T(t) = β·(L-L_prev) + (1-β)T` | Datos con nivel + tendencia |
| **Media móvil ponderada** | Pesos `[0.4, 0.3, 0.2, 0.1]` en últimos 4 períodos | Datos estables |

### Selección automática del modelo
- Cada modelo se evalúa con **MAPE** (Mean Absolute Percentage Error) sobre datos históricos
- Se selecciona el modelo con menor MAPE
- Confianza calculada: `max(0.55, min(0.95, 1 - MAPE))`

### UI
- Selector de 4 métricas: Animales, Ingresos, Gastos, Salud
- Datos reales del dashboard (`TrendsData`) como entrada
- Descripción contextual generada: "Proyección de peso: se espera aumento del X% en N períodos (modelo: Y, confianza: Z%)"

---

## 3. Recomendaciones Contextuales

### Endpoint
`GET /api/ai/recommendations`

### Response
```json
{
  "status": 200,
  "data": [
    {
      "id": "rec-salud-1234567890-1",
      "category": "salud",
      "title": "3 tratamiento(s) vencido(s)",
      "description": "Hay 3 registro(s) de salud con fecha vencida...",
      "confidence": 0.95,
      "generatedAt": "2026-05-21T..."
    }
  ]
}
```

### Motor de reglas (`AiService.getRecommendations`)
Consulta datos reales de la DB vía TypeORM y genera recomendaciones por categoría:

| Categoría | Regla | Confidence |
|-----------|-------|------------|
| Salud | Tratamientos con `fecha_proxima_aplicacion` vencida | 0.95 |
| Salud | Tratamientos próximos (7 días) | 0.90 |
| Reproducción | Partos vencidos (`fecha_estimado_parto` < hoy) | 0.92 |
| Reproducción | Partos próximos (30 días) | 0.88 |
| Reproducción | Vacas en celo (`en_celo = true`) | 0.85 |
| Alimentación | Animales en engorde → optimizar proteína 14-16% | 0.80 |
| Alimentación | Animales en producción → suplementación mineral | 0.82 |
| Alimentación | Animales en crecimiento → meta 0.8-1.2 kg/día | 0.78 |
| Finanzas | Balance negativo | 0.90 |
| Finanzas | Margen ajustado (ingresos/gastos < 1.2) | 0.75 |
| Potreros | Potreros en uso activo → revisar rotación | 0.70 |

### Datos consultados
- `Animal` (etapa_productiva, estado, potrero)
- `Salud` (fecha_proxima_aplicacion, tipo_intervencion)
- `Reproduccion` (preñada, en_celo, fecha_estimado_parto)
- `Finanza` (tipo_movimiento, monto)
- `Potrero` (capacidad_animales, estado)

Filtrado por `tenant_id` + `finca_id` opcional. Excluye soft-deleted.

---

## Archivos modificados

### Backend
| Archivo | Cambio |
|---------|--------|
| `Backend/src/ai/ai.controller.ts` | Endpoints + `tenant_id` fix |
| `Backend/src/ai/ai.service.ts` | Chat, predict (3 modelos matemáticos), recommendations engine |
| `Backend/src/ai/ai.module.ts` | TypeORM + farm module dependencies |

### Frontend
| Archivo | Cambio |
|---------|--------|
| `ai_chat_fab.dart` | FAB + dialog con parámetros tenantId/fincaId |
| `ia_predictions_card.dart` | Selector de métricas + datos reales del dashboard |
| `ia_recommendations_card.dart` | Card dashboard con recomendaciones |
| `ia_remote_data_source.dart` | URL `/ai/*` + parsing de respuesta |
| `prediction.dart` | Tipos: peso, ingresos, gastos, salud |
| `prediction_model.dart` | Mapeo metric→type desde respuesta backend |
| `home_shell.dart` | IA BLoCs + AiChatFab integration |
| `dashboard_bento_page.dart` | Cards en layout bento |
| `env.dart` | `receiveTimeout: 45s` |
| `injection.dart` | IA dependencies |

### AI Proxy
| Archivo | Cambio |
|---------|--------|
| `Backend-IA-Proxy/main.py` | Modelo `llama-3.1-8b-instant`, historial limitado, system prompt |

### Scripts
| Archivo | Cambio |
|---------|--------|
| `scripts/start.sh` | Lanza AI proxy en background + 7 pasos |
| `scripts/stop.sh` | Mata backend + AI proxy por PID |

---

## Estado actual

| Feature | Estado | Nota |
|---------|--------|------|
| Chat | ✅ Funcional | Groq API, llama-3.1-8b-instant |
| Predicciones | ✅ Modelos matemáticos | Regresión lineal, Holt, media móvil — selección automática por MAPE |
| Recomendaciones | ✅ Funcional | Motor contextual con datos reales de DB |
| UI | ✅ Integrada | FAB flotante + cards con selector de métricas |
| Análisis | ✅ Limpio | `flutter analyze` sin errores |
