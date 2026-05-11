import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Request, Response } from 'express';

// GlobalHttpExceptionFilter — estandariza TODAS las respuestas de error.
//
// Respuesta normalizada:
//   { statusCode: number, message: string | string[], path: string, timestamp: string }
//
// Captura:
//   1. HttpException y subclases (NotFoundException, UnauthorizedException, BadRequestException…)
//      → extrae statusCode y message del propio HttpException.
//   2. Error genérico no controlado (TypeORM errors, bugs, etc.)
//      → responde 500, oculta detalles al cliente, registra stack completo.
//
// El campo message es string[] cuando ValidationPipe lanza BadRequestException
// con múltiples errores de class-validator — el filter los preserva para el cliente.
//
// Registrar en main.ts: app.useGlobalFilters(new GlobalHttpExceptionFilter())
@Catch()
export class GlobalHttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalHttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let statusCode: number;
    let message: string | string[];

    if (exception instanceof HttpException) {
      statusCode = exception.getStatus();
      const res = exception.getResponse();

      if (typeof res === 'string') {
        message = res;
      } else if (typeof res === 'object' && res !== null && 'message' in res) {
        const msg = (res as Record<string, unknown>).message;
        message = Array.isArray(msg) ? (msg as string[]) : String(msg);
      } else {
        message = exception.message;
      }
    } else {
      // Error no controlado — log completo en servidor, respuesta genérica al cliente.
      statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
      message = 'Error interno del servidor';
      this.logger.error(
        `Unhandled exception: ${(exception as Error)?.message ?? String(exception)}`,
        (exception as Error)?.stack,
      );
    }

    // 5xx → error, 4xx → warn (no drowning the logs with client errors)
    if (statusCode >= 500) {
      this.logger.error(`[${request.method}] ${request.url} → ${statusCode}`);
    } else {
      this.logger.warn(
        `[${request.method}] ${request.url} → ${statusCode}: ${JSON.stringify(message)}`,
      );
    }

    response.status(statusCode).json({
      statusCode,
      message,
      path: request.url,
      timestamp: new Date().toISOString(),
    });
  }
}
