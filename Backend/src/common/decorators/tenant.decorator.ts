import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { RequestWithUser } from '../interfaces/request-with-user.interface';

// @Tenant() — extrae req.tenantId inyectado por TenantGuard.
// Devuelve el tenant_id del JWT validado (nunca del cliente directamente).
//
// Uso:
//   findAll(@Tenant() tenantId: string) { ... }
//
// Requiere que TenantGuard haya ejecutado antes (garantizado con APP_GUARD global).
// Si el usuario no tiene tenant_id asignado aún (Fase 0-1), retorna undefined.
export const Tenant = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): string | undefined => {
    const request = ctx.switchToHttp().getRequest<RequestWithUser>();
    return request.tenantId;
  },
);
