import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';

// JwtRefreshStrategy valida el refresh token con JWT_REFRESH_SECRET.
// Soporta tres fuentes con orden de prioridad estricto:
//   1. Cookie HTTP-only 'refresh_token'  ← más seguro (browser)
//   2. Authorization header 'Bearer ...' ← compatibilidad con clientes existentes
//   3. Body field 'refresh_token'         ← compatibilidad máxima (Postman, API)
//
// El mismo orden de prioridad se aplica tanto al extractor (jwtFromRequest)
// como a la extracción del raw token en validate() para garantizar consistencia.
@Injectable()
export class JwtRefreshStrategy extends PassportStrategy(
  Strategy,
  'jwt-refresh',
) {
  constructor(configService: ConfigService) {
    super({
      // Extractor custom: cookie → header → body
      // passport-jwt acepta cualquier función (req) => string | null como extractor.
      jwtFromRequest: (req: any): string | null => {
        // Prioridad 1: Cookie HTTP-only (flujo browser/web)
        if (req?.cookies?.refresh_token) {
          return req.cookies.refresh_token;
        }
        // Prioridad 2: Authorization Bearer header (clientes API / Flutter actual)
        if (req?.headers?.authorization?.startsWith('Bearer ')) {
          return req.headers.authorization.split(' ')[1];
        }
        // Prioridad 3: Body field (Postman / clientes legacy)
        if (req?.body?.refresh_token) {
          return req.body.refresh_token;
        }
        return null;
      },
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_REFRESH_SECRET') as string,
      // passReqToCallback: true expone el Request completo en validate()
      // para que podamos extraer el raw token y compararlo contra el hash en BD.
      passReqToCallback: true,
    });
  }

  // Passport llama a validate() DESPUÉS de verificar la firma con JWT_REFRESH_SECRET.
  // payload contiene el JWT decodificado: { sub, email, tenant_id, rol }.
  // req contiene el request completo para extraer el raw token (mismo orden de prioridad).
  async validate(
    req: any,
    payload: {
      sub: number;
      email: string;
      tenant_id: string;
      rol: string;
    },
  ) {
    // El raw token es necesario para compararlo contra el bcrypt hash en BD (rotación).
    // NUNCA se loguea ni se expone en respuestas — solo se usa internamente para bcrypt.compare().
    // Se aplica el mismo orden de prioridad que el extractor para garantizar consistencia:
    // si el extractor tomó el token del header, validate() también lee del header.
    const rawRefreshToken: string =
      req.cookies?.refresh_token ||
      req.headers?.authorization?.split(' ')[1] ||
      req.body?.refresh_token ||
      '';

    // tenant_id viene SIEMPRE del payload JWT validado — nunca del cliente directamente.
    // Esto garantiza el aislamiento multitenant incluso en el flujo de refresh.
    return {
      sub: payload.sub,
      email: payload.email,
      refreshToken: rawRefreshToken,
      // tenant_id incluido en el retorno para que esté disponible en el controller
      // si fuera necesario en auditoría futura; no se usa en el flujo actual de refresh.
      tenant_id: payload.tenant_id,
    };
  }
}
