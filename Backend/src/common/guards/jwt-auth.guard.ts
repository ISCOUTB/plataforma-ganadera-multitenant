import { Injectable, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import { IS_PUBLIC_KEY } from '../../auth/decorators/public.decorator';

// Guard global para JWT. Extiende AuthGuard('jwt') de Passport e intercepta
// la verificación para respetar el decorador @Public().
//
// Al registrarse como APP_GUARD en AppModule, todas las rutas requieren
// un access token válido por defecto. Las rutas @Public() quedan exentas.
//
// Orden de ejecución (cuando hay múltiples APP_GUARD):
//   JwtAuthGuard → RolesGuard → TenantGuard
// Este orden garantiza que request.user exista cuando los siguientes guards lo lean.
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    // Rutas marcadas con @Public() saltan la verificación JWT
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    // Delegar al AuthGuard('jwt') de Passport: valida la firma y extrae el payload
    return super.canActivate(context);
  }
}
