import {
  Controller,
  Post,
  Body,
  UseGuards,
  Request,
  HttpStatus,
  Get,
  BadRequestException,
} from '@nestjs/common';
import { AiService } from './ai.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { TenantGuard } from '../common/guards/tenant.guard';

/**
 * Controlador para endpoints de IA
 * - POST /api/ai/chat - Chat con Llama 3B
 * - POST /api/ai/predict - Predicciones con Chronos-2
 */
@Controller('ai')
@UseGuards(JwtAuthGuard, TenantGuard)
export class AiController {
  constructor(private readonly aiService: AiService) {}

  /**
   * Health check del Backend IA
   */
  @Get('health')
  async health() {
    try {
      const status = await this.aiService.healthCheck();
      return {
        status: HttpStatus.OK,
        message: 'Backend IA disponible',
        details: status,
      };
    } catch (error) {
      return {
        status: HttpStatus.SERVICE_UNAVAILABLE,
        message: 'Backend IA no disponible',
        error: error.message,
      };
    }
  }

  /**
   * Endpoint de chat con Llama 3B
   *
   * Body requerido:
   * {
   *   "messages": [
   *     { "role": "user", "content": "¿Cómo aumentar la producción de leche?" }
   *   ]
   * }
   *
   * La autenticación extrae automáticamente tenant_id del JWT
   */
  @Post('chat')
  async chat(@Request() req, @Body() body: any) {
    const tenantId = req.user.tenantId; // Extraído del JWT por guards
    const { messages } = body;

    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      throw new BadRequestException(
        'Body debe contener un array "messages" no vacío'
      );
    }

    const response = await this.aiService.chat(tenantId, messages);
    return {
      status: HttpStatus.OK,
      response,
      tenant: tenantId,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Endpoint de predicción con Chronos-2
   *
   * Body requerido:
   * {
   *   "metric": "weight",
   *   "values": [45.2, 46.1, 47.3, ...],  // mín. 10 valores
   *   "steps": 30  // opcional, default: 30
   * }
   *
   * La autenticación extrae automáticamente tenant_id del JWT
   */
  @Post('predict')
  async predict(@Request() req, @Body() body: any) {
    const tenantId = req.user.tenantId;
    const { metric, values, steps = 30 } = body;

    if (!metric || typeof metric !== 'string') {
      throw new BadRequestException('Body debe contener "metric" (string)');
    }

    if (!Array.isArray(values) || values.length < 10) {
      throw new BadRequestException(
        'Body debe contener "values" (array con mín. 10 elementos)'
      );
    }

    if (typeof steps !== 'number' || steps < 1 || steps > 365) {
      throw new BadRequestException('steps debe estar entre 1 y 365');
    }

    const result = await this.aiService.predict(
      tenantId,
      metric,
      values,
      steps
    );

    return {
      status: HttpStatus.OK,
      data: result,
      tenant: tenantId,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Endpoint de recomendaciones IA
   * Genera recomendaciones basadas en el contexto de la finca
   */
  @Get('recommendations')
  async recommendations(@Request() req) {
    const tenantId = req.user.tenantId;
    const fincaId = req.user.fincaId || '';

    const recommendations = await this.aiService.getRecommendations(
      tenantId,
      fincaId
    );

    return {
      status: HttpStatus.OK,
      data: recommendations,
      tenant: tenantId,
      timestamp: new Date().toISOString(),
    };
  }
}
