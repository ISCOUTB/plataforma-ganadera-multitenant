import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

// TenantGuard previene el acceso cruzado entre tenants (fincas).
// Compara el tenant_id del JWT con el tenant_id del request (params/query/body).
//
// Estado actual: esqueleto funcional para Fase 1.
// Implementación completa en Fase 4 (multitenant) donde tenant_id
// tendrá FK a Finca y será obligatorio en todas las entidades de dominio.
//
// Uso: @UseGuards(JwtAuthGuard, TenantGuard) en controllers de dominio (Fase 4).
@Injectable()
export class TenantGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    // Rutas públicas no requieren validación de tenant
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    // Si no hay usuario autenticado, dejar que JwtAuthGuard maneje el 401
    if (!user) return true;

    // Extraer tenant_id del request en orden de prioridad: params > query > body
    const requestTenantId =
      request.params?.tenant_id ||
      request.query?.tenant_id ||
      request.body?.tenant_id;

    // Si la ruta no contiene tenant_id en el request, no hay nada que validar.
    // Las rutas de dominio en Fase 4 siempre incluirán tenant_id en los params.
    if (!requestTenantId) return true;

    // TODO (Fase 4): validar que el tenant_id existe en la tabla Finca
    // y que el usuario tiene acceso a esa finca.
    return user.tenant_id === requestTenantId;
  }
}
