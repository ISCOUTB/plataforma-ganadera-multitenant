import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../../auth/decorators/public.decorator';
import { ROLES_KEY } from '../decorators/roles.decorator';
import type { RequestWithUser } from '../interfaces/request-with-user.interface';

// RolesGuard global: verifica que el usuario autenticado tenga un rol autorizado.
//
// Comportamiento:
//   1. @Public() → deja pasar sin verificar roles.
//   2. Sin @Roles() → accesible para cualquier usuario autenticado.
//   3. Con @Roles('admin', 'propietario') → verifica user.rol.
//
// Se ejecuta DESPUÉS de JwtAuthGuard (garantizado por el orden de APP_GUARD
// en AppModule), así que request.user siempre existe cuando llega aquí.
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    // Leer roles requeridos del decorador @Roles() en el handler o el controller
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    // Sin @Roles() → cualquier usuario autenticado puede acceder
    if (!requiredRoles || requiredRoles.length === 0) return true;

    const request = context.switchToHttp().getRequest<RequestWithUser>();
    const user = request.user;

    return requiredRoles.some((role) => user?.rol === role);
  }
}
