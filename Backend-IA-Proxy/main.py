"""
Backend IA Proxy - FarmLink
Proxy ligero para APIs de IA remotas (Groq Llama + HuggingFace Chronos-2)
NO descarga modelos locales. Todo es vía APIs HTTP.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import httpx
import os
from dotenv import load_dotenv
import logging

load_dotenv()

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="FarmLink AI Proxy",
    description="Proxy para Llama 3B (Groq) + Chronos-2 (HuggingFace)",
    version="1.0.0"
)

# CORS - Permitir desde Frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción: especificar dominios
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================================
# CONFIGURACIÓN DE APIs REMOTAS
# ============================================================================

GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODEL = "mixtral-8x7b-32768"  # Llama-like, muy rápido

HUGGINGFACE_API_KEY = os.getenv("HUGGINGFACE_API_KEY", "")
HUGGINGFACE_URL = "https://api-inference.huggingface.co/models/amazon/chronos-t5-small"

# ============================================================================
# HEALTH CHECK
# ============================================================================

@app.get("/health")
async def health_check():
    """
    Health check endpoint
    Retorna el estado del servicio y disponibilidad de APIs
    """
    groq_available = bool(GROQ_API_KEY)
    huggingface_available = bool(HUGGINGFACE_API_KEY)
    
    return {
        "status": "ok",
        "service": "farmlink-ai-proxy",
        "groq_configured": groq_available,
        "huggingface_configured": huggingface_available,
    }

# ============================================================================
# ENDPOINT 1: CHAT CON LLAMA 3B (VÍA GROQ)
# ============================================================================

@app.post("/chat/completions")
async def chat_completion(request: dict):
    """
    Proxy para Llama 3B via Groq API
    
    Requiere:
    - tenant_id: ID del tenant (para auditoría multitenant)
    - messages: Lista de mensajes en formato OpenAI
    
    Ejemplo:
    {
        "tenant_id": "tenant-1",
        "messages": [
            {"role": "user", "content": "¿Cómo aumentar la producción de leche?"}
        ]
    }
    """
    
    if not GROQ_API_KEY:
        logger.error("GROQ_API_KEY no configurado")
        raise HTTPException(
            status_code=500,
            detail="GROQ_API_KEY no configurado en Backend IA"
        )
    
    tenant_id = request.get("tenant_id")
    if not tenant_id:
        raise HTTPException(
            status_code=400,
            detail="tenant_id requerido"
        )
    
    messages = request.get("messages", [])
    if not messages:
        raise HTTPException(
            status_code=400,
            detail="messages array requerido y no vacío"
        )
    
    logger.info(f"Chat request from tenant: {tenant_id}")
    
    # Llamar a Groq API
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(
                GROQ_URL,
                headers={
                    "Authorization": f"Bearer {GROQ_API_KEY}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": GROQ_MODEL,
                    "messages": messages,
                    "temperature": 0.7,
                    "max_tokens": 256,
                    "top_p": 1
                },
                timeout=30.0
            )
            
            if response.status_code != 200:
                logger.error(f"Groq API error: {response.status_code} - {response.text}")
                raise HTTPException(
                    status_code=response.status_code,
                    detail=f"Groq API error: {response.text}"
                )
            
            result = response.json()
            
            return {
                "tenant_id": tenant_id,
                "response": result["choices"][0]["message"]["content"],
                "model": GROQ_MODEL,
                "usage": result.get("usage", {})
            }
        
        except httpx.TimeoutException:
            logger.error("Groq API timeout")
            raise HTTPException(
                status_code=504,
                detail="Groq API timeout (>30s)"
            )
        except httpx.RequestError as e:
            logger.error(f"Groq request error: {str(e)}")
            raise HTTPException(
                status_code=503,
                detail=f"No se pudo conectar a Groq API: {str(e)}"
            )
        except Exception as e:
            logger.error(f"Unexpected error in chat: {str(e)}")
            raise HTTPException(
                status_code=500,
                detail=f"Error interno: {str(e)}"
            )

# ============================================================================
# ENDPOINT 2: PREDICCIÓN CON CHRONOS-2 (VÍA HUGGINGFACE)
# ============================================================================

@app.post("/predict")
async def predict(request: dict):
    """
    Proxy para Chronos-2 (series temporales) via HuggingFace Inference API
    
    Requiere:
    - tenant_id: ID del tenant
    - metric: Nombre de la métrica (ej: "weight", "milk_production")
    - values: Array de valores históricos (mín. 10)
    - steps: Cantidad de períodos a predecir (default: 30)
    
    Ejemplo:
    {
        "tenant_id": "tenant-1",
        "metric": "weight",
        "values": [45.2, 46.1, 47.3, 48.1, 48.9, 49.5, ...],
        "steps": 30
    }
    """
    
    if not HUGGINGFACE_API_KEY:
        logger.error("HUGGINGFACE_API_KEY no configurado")
        raise HTTPException(
            status_code=500,
            detail="HUGGINGFACE_API_KEY no configurado en Backend IA"
        )
    
    tenant_id = request.get("tenant_id")
    metric = request.get("metric", "unknown")
    values = request.get("values", [])
    steps = request.get("steps", 30)
    
    if not tenant_id:
        raise HTTPException(status_code=400, detail="tenant_id requerido")
    
    if not isinstance(values, list) or len(values) < 10:
        raise HTTPException(
            status_code=400,
            detail="values debe ser un array con mínimo 10 elementos"
        )
    
    if steps < 1 or steps > 365:
        raise HTTPException(
            status_code=400,
            detail="steps debe estar entre 1 y 365"
        )
    
    logger.info(f"Prediction request from tenant: {tenant_id}, metric: {metric}, steps: {steps}")
    
    # Llamar a HuggingFace Inference API
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(
                HUGGINGFACE_URL,
                headers={"Authorization": f"Bearer {HUGGINGFACE_API_KEY}"},
                json={
                    "inputs": values,
                    "parameters": {
                        "num_samples": 100,
                        "temperature": 1.0,
                        "top_k": 50,
                        "top_p": 1.0
                    }
                },
                timeout=30.0
            )
            
            if response.status_code != 200:
                logger.error(f"HuggingFace error: {response.status_code} - {response.text}")
                raise HTTPException(
                    status_code=response.status_code,
                    detail=f"HuggingFace API error: {response.text}"
                )
            
            result = response.json()
            
            # HuggingFace devuelve predicciones; tomamos los primeros 'steps'
            if isinstance(result, list) and len(result) > 0:
                predictions = result[0][:steps] if isinstance(result[0], list) else result[:steps]
            else:
                predictions = []
            
            return {
                "tenant_id": tenant_id,
                "metric": metric,
                "forecast": predictions,
                "steps": steps,
                "input_size": len(values),
                "model": "chronos-t5-small"
            }
        
        except httpx.TimeoutException:
            logger.error("HuggingFace API timeout")
            raise HTTPException(
                status_code=504,
                detail="HuggingFace API timeout (>30s)"
            )
        except httpx.RequestError as e:
            logger.error(f"HuggingFace request error: {str(e)}")
            raise HTTPException(
                status_code=503,
                detail=f"No se pudo conectar a HuggingFace: {str(e)}"
            )
        except Exception as e:
            logger.error(f"Unexpected error in predict: {str(e)}")
            raise HTTPException(
                status_code=500,
                detail=f"Error interno: {str(e)}"
            )

# ============================================================================
# MAIN
# ============================================================================

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=port,
        log_level="info"
    )
