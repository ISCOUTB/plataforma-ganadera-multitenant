import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';

// JwtStrategy valida el token en cada request protegido.
// Passport llama a validate() con el payload ya decodificado.
// El objeto retornado por validate() se asigna a request.user.
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(configService: ConfigService) {
    super({
      // Extrae el token del header: Authorization: Bearer <token>
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      // JWT_SECRET leído desde variables de entorno (Backend/.env).
      // 'as string' porque ConfigService.get puede retornar undefined — en práctica
      // siempre existe por .env (dev) o por la config del servidor (prod).
      secretOrKey: configService.get<string>('JWT_SECRET') as string,
    });
  }

  // NestJS llama a validate() después de verificar la firma del token.
  // Lo que retornamos aquí queda disponible como @CurrentUser() en los controllers.
  async validate(payload: {
    sub: number;
    email: string;
    tenant_id: string;
    rol: string;
  }) {
    return {
      sub: payload.sub,
      email: payload.email,
      tenant_id: payload.tenant_id, // clave para multitenant
      rol: payload.rol,
    };
  }
}
