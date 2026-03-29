import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { RequestWithUser, JwtUserPayload } from '../interfaces/request-with-user.interface';

// @CurrentUser() — extrae request.user completo (payload JWT validado).
// @CurrentUser('email') — extrae solo el campo indicado.
//
// Uso:
//   findAll(@CurrentUser() user: JwtUserPayload) { ... }
//   getEmail(@CurrentUser('email') email: string) { ... }
//
// Requiere que JwtAuthGuard haya ejecutado antes (garantizado con APP_GUARD global).
export const CurrentUser = createParamDecorator(
  (field: keyof JwtUserPayload | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest<RequestWithUser>();
    const user = request.user;
    return field ? user?.[field] : user;
  },
);
