import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Rol } from '../../usuarios/entities/usuario.entity';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

// RolesGuard verifica que el usuario autenticado tenga uno de los roles requeridos.
// Se usa junto a @Roles(Rol.ADMIN) en rutas que requieren un rol específico.
// Siempre debe aplicarse DESPUÉS de JwtAuthGuard (para que request.user ya exista).
//
// Comportamiento:
//   1. Si la ruta es @Public() → deja pasar sin verificar roles.
//   2. Si no hay @Roles() en la ruta → deja pasar a cualquier usuario autenticado.
//   3. Si hay @Roles() → verifica que user.rol esté en la lista.
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    // Rutas marcadas con @Public() no requieren verificación de roles
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    // Obtener roles requeridos del decorador @Roles() en el handler o el controller
    const requiredRoles = this.reflector.getAllAndOverride<Rol[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    // Sin @Roles() explícito → accesible para cualquier usuario autenticado
    if (!requiredRoles || requiredRoles.length === 0) return true;

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    // Verificar que el rol del usuario esté en la lista de roles permitidos
    return requiredRoles.some((role) => user?.rol === role);
  }
}
