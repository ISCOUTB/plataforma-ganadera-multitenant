import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import type { Request } from 'express';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

// LoggingInterceptor — registra cada request HTTP exitoso con:
//   [METHOD] /path → statusCode (Xms)
//
// Solo registra el camino feliz (2xx). Los errores (4xx/5xx) son registrados
// por GlobalHttpExceptionFilter para evitar doble log.
//
// Registrar en main.ts ANTES de ClassSerializerInterceptor:
//   app.useGlobalInterceptors(new LoggingInterceptor(), new ClassSerializerInterceptor(...))
// Orden: LoggingInterceptor envuelve la cadena completa → mide el tiempo total real.
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const ctx = context.switchToHttp();
    const request = ctx.getRequest<Request>();
    const { method, url } = request;
    const start = Date.now();

    return next.handle().pipe(
      tap(() => {
        const response = ctx.getResponse<{ statusCode: number }>();
        const elapsed = Date.now() - start;
        this.logger.log(`[${method}] ${url} → ${response.statusCode} (${elapsed}ms)`);
      }),
    );
  }
}
