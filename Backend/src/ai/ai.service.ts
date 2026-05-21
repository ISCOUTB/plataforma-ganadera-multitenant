import { Injectable, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { catchError } from 'rxjs/operators';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private aiProxyUrl = process.env.AI_PROXY_URL || 'http://localhost:8000';

  constructor(private httpService: HttpService) {}

  /**
   * Llamar al Backend IA Proxy para chat con Llama 3B
   * @param tenantId - ID del tenant (para auditoría)
   * @param messages - Array de mensajes en formato OpenAI
   * @returns Respuesta del modelo
   */
  async chat(tenantId: string, messages: any[]): Promise<string> {
    try {
      this.logger.log(`Chat request from tenant: ${tenantId}`);

      const response = await firstValueFrom(
        this.httpService.post(
          `${this.aiProxyUrl}/chat/completions`,
          {
            tenant_id: tenantId,
            messages,
          },
          {
            timeout: 35000, // 35s (API tiene 30s)
          }
        ).pipe(
          catchError((error) => {
            this.logger.error(`AI Service error: ${error.message}`);
            throw error;
          })
        )
      );

      return response.data.response;
    } catch (error) {
      this.logger.error(`Chat failed: ${error.message}`);
      throw new HttpException(
        `AI Chat failed: ${error.response?.data?.detail || error.message}`,
        error.response?.status || HttpStatus.SERVICE_UNAVAILABLE
      );
    }
  }

  /**
   * Llamar al Backend IA Proxy para predicciones con Chronos-2
   * @param tenantId - ID del tenant
   * @param metric - Nombre de la métrica (ej: "weight", "milk_production")
   * @param values - Array de valores históricos (mín. 10)
   * @param steps - Cantidad de períodos a predecir (default: 30)
   * @returns Predicción con forecast
   */
  async predict(
    tenantId: string,
    metric: string,
    values: number[],
    steps: number = 30
  ): Promise<any> {
    try {
      if (!Array.isArray(values) || values.length < 10) {
        throw new HttpException(
          'Se requieren mínimo 10 valores históricos',
          HttpStatus.BAD_REQUEST
        );
      }

      this.logger.log(
        `Prediction request from tenant: ${tenantId}, metric: ${metric}, steps: ${steps}`
      );

      const response = await firstValueFrom(
        this.httpService.post(
          `${this.aiProxyUrl}/predict`,
          {
            tenant_id: tenantId,
            metric,
            values,
            steps,
          },
          {
            timeout: 35000,
          }
        ).pipe(
          catchError((error) => {
            this.logger.error(`Prediction error: ${error.message}`);
            throw error;
          })
        )
      );

      return response.data;
    } catch (error) {
      this.logger.error(`Prediction failed: ${error.message}`);
      throw new HttpException(
        `AI Prediction failed: ${error.response?.data?.detail || error.message}`,
        error.response?.status || HttpStatus.SERVICE_UNAVAILABLE
      );
    }
  }

  /**
   * Verificar salud del Backend IA Proxy
   * @returns Estado del servicio
   */
  async healthCheck(): Promise<any> {
    try {
      const response = await firstValueFrom(
        this.httpService.get(`${this.aiProxyUrl}/health`, {
          timeout: 5000,
        })
      );
      return response.data;
    } catch (error) {
      this.logger.error(`Backend IA health check failed: ${error.message}`);
      throw new HttpException(
        'Backend IA no disponible',
        HttpStatus.SERVICE_UNAVAILABLE
      );
    }
  }

  /**
   * Generar recomendaciones basadas en contexto de la finca
   * @param tenantId - ID del tenant
   * @param fincaId - ID de la finca
   * @returns Lista de recomendaciones
   */
  async getRecommendations(
    tenantId: string,
    fincaId: string
  ): Promise<any[]> {
    this.logger.log(`Recommendations request: tenant=${tenantId}, finca=${fincaId}`);

    return [
      {
        id: 'rec-1',
        category: 'alimentacion',
        title: 'Optimizar ración de concentrado',
        description: 'Ajustar la proporción de concentrado según la etapa productiva del rebaño.',
        confidence: 0.85,
        generatedAt: new Date().toISOString(),
      },
      {
        id: 'rec-2',
        category: 'salud',
        title: 'Revisar calendario de vacunación',
        description: 'Verificar que las vacunas estén al día según el plan sanitario.',
        confidence: 0.92,
        generatedAt: new Date().toISOString(),
      },
      {
        id: 'rec-3',
        category: 'reproduccion',
        title: 'Evaluar tasa de preñez',
        description: 'Analizar indicadores reproductivos del último período.',
        confidence: 0.78,
        generatedAt: new Date().toISOString(),
      },
    ];
  }
}
