import type { Request } from 'express';

// Payload que JwtStrategy.validate() retorna y Passport asigna a request.user.
// Campos: sub = userId, rol = Rol enum value, tenant_id = finca UUID.
export interface JwtUserPayload {
  sub: number;
  email: string;
  tenant_id: string;
  rol: string;
}

// Request tipado para controllers y guards que acceden a request.user.
// tenantId es inyectado por TenantGuard (common) para facilitar el acceso
// al tenant sin necesidad de leer request.user.tenant_id directamente.
export interface RequestWithUser extends Request {
  user: JwtUserPayload;
  tenantId?: string;
}
