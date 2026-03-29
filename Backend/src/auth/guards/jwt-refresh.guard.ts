import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

// JwtRefreshGuard activa la estrategia 'jwt-refresh' (JwtRefreshStrategy).
// Uso: @UseGuards(JwtRefreshGuard) en POST /auth/refresh.
// El cliente debe enviar el refresh token en: Authorization: Bearer <refresh_token>
@Injectable()
export class JwtRefreshGuard extends AuthGuard('jwt-refresh') {}
