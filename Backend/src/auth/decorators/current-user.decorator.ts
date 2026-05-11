import { createParamDecorator, ExecutionContext } from '@nestjs/common';

// @CurrentUser() extrae request.user que JwtStrategy.validate() asignó.
// Contiene: { id, email, tenant_id, rol }
// Uso: findAll(@CurrentUser() user: any) { ... }
export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
