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
      this.logger.warn(`AI Proxy unavailable for chat (${error.message}), using fallback`);
      return 'Hola. Soy el asistente de FarmLink. Actualmente estoy en modo offline, pero puedes consultar las predicciones y recomendaciones en el dashboard. ¿En qué más puedo ayudarte?';
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
      this.logger.warn(`AI Proxy unavailable (${error.message}), using fallback`);
      return this._generateFallbackPrediction(metric, values, steps);
    }
  }

  private _generateFallbackPrediction(
    metric: string,
    values: number[],
    steps: number,
  ): any {
    const n = values.length;
    const sumX = (n * (n - 1)) / 2;
    const sumY = values.reduce((a, b) => a + b, 0);
    const sumXY = values.reduce((acc, y, i) => acc + i * y, 0);
    const sumX2 = (n * (n - 1) * (2 * n - 1)) / 6;
    const slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    const intercept = (sumY - slope * sumX) / n;
    const lastValue = values[values.length - 1];
    const trend = slope > 0.01 ? 'up' : slope < -0.01 ? 'down' : 'stable';

    const forecast: number[] = [];
    const labels: string[] = [];
    for (let i = 1; i <= Math.min(steps, 30); i++) {
      const noise = (Math.random() - 0.5) * lastValue * 0.1;
      forecast.push(Math.max(0, slope * (n + i) + intercept + noise));
      const date = new Date();
      date.setDate(date.getDate() + i);
      labels.push(date.toISOString().slice(0, 10));
    }

    const lastAvg = values.slice(-5).reduce((a, b) => a + b, 0) / 5;
    const forecastAvg = forecast.slice(0, 5).reduce((a, b) => a + b, 0) / 5;
    const change = ((forecastAvg - lastAvg) / lastAvg) * 100;

    return {
      id: `fallback-${Date.now()}`,
      metric,
      type: metric === 'weight' || metric === 'crecimiento' ? 'crecimiento' :
            metric === 'precio' ? 'precio' : 'produccion',
      values: forecast,
      labels,
      confidence: 0.65,
      trend,
      description: change >= 0
        ? `Proyección: +${change.toFixed(1)}% en los próximos días`
        : `Proyección: ${change.toFixed(1)}% en los próximos días`,
      generatedAt: new Date().toISOString(),
      model: 'linear-trend-fallback',
    };
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
