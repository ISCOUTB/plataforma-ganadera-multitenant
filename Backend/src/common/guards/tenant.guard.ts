import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../../auth/decorators/public.decorator';
import type { RequestWithUser } from '../interfaces/request-with-user.interface';

// TenantGuard global: enriquece el request con req.tenantId y previene
// el acceso cruzado entre tenants (fincas) cuando la ruta expone tenant_id.
//
// Responsabilidades:
//   1. Inyectar req.tenantId desde el JWT para que @Tenant() funcione.
//   2. Si la ruta incluye tenant_id (params/query/body), validar que coincida
//      con el tenant_id del JWT para prevenir escalada horizontal.
//
// Estado: esqueleto funcional (Fase 2). Fase 4 agrega validación de FK
// contra la tabla Finca y hace tenant_id obligatorio en todas las entidades.
//
// Se ejecuta DESPUÉS de JwtAuthGuard, así que request.user siempre existe.
@Injectable()
export class TenantGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const request = context.switchToHttp().getRequest<RequestWithUser>();
    const user = request.user;

    // Sin usuario autenticado → JwtAuthGuard ya devolvió 401; no hacer nada aquí
    if (!user) return true;

    // Enriquecer el request: req.tenantId queda disponible para @Tenant() decorator
    if (user.tenant_id) {
      request.tenantId = user.tenant_id;
    }

    // Extraer tenant_id del request en orden de prioridad: params > query > body
    const requestTenantId: string | undefined =
      (request.params as Record<string, string>)?.tenant_id ||
      (request.query as Record<string, string>)?.tenant_id ||
      (request.body as Record<string, string>)?.tenant_id;

    // Rutas sin tenant_id en el request no necesitan validación cruzada
    if (!requestTenantId) return true;

    // TODO (Fase 4): verificar también que tenant_id existe en la tabla Finca
    // y que el usuario tiene acceso a esa finca (relación Usuario ↔ Finca).
    return user.tenant_id === requestTenantId;
  }
}
