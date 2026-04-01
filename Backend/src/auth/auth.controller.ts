import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
  Res,
} from '@nestjs/common';
import type { Response } from 'express';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegistroDto } from './dto/registro.dto';
import { JwtRefreshGuard } from './guards/jwt-refresh.guard';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { Public } from './decorators/public.decorator';
import { CurrentUser } from './decorators/current-user.decorator';

// Opciones de cookie centralizadas para mantener consistencia entre
// login (set), refresh (rotate) y logout (clear).
// secure: false en dev — cambiar a true en producción (requiere HTTPS).
const REFRESH_COOKIE_OPTIONS = {
  httpOnly: true,   // inaccesible desde JavaScript → protege contra XSS
  secure: false,    // true en producción con HTTPS
  sameSite: 'lax' as const,
  path: '/api/auth/refresh', // browser solo envía esta cookie al endpoint de refresh
};

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // Ruta pública — crea un nuevo usuario y devuelve el perfil sin password.
  @ApiOperation({ summary: 'Registrar nuevo usuario' })
  @ApiResponse({ status: 201, description: 'Usuario creado exitosamente' })
  @ApiResponse({ status: 409, description: 'El email ya está registrado' })
  @Public()
  @Post('registro')
  registro(@Body() body: RegistroDto) {
    return this.authService.registro(body);
  }

  // Ruta pública — valida credenciales y devuelve { access_token, refresh_token }.
  // TAMBIÉN setea el refresh_token como cookie HTTP-only (flujo browser/web).
  // Clientes API (Flutter, Postman) pueden ignorar la cookie y usar el JSON.
  // HttpCode 200: no se crea un recurso nuevo (no 201).
  @ApiOperation({ summary: 'Iniciar sesión — retorna access_token y refresh_token' })
  @ApiResponse({ status: 200, description: 'Tokens generados correctamente' })
  @ApiResponse({ status: 401, description: 'Credenciales inválidas' })
  @Public()
  @HttpCode(HttpStatus.OK)
  @Post('login')
  async login(
    @Body() body: LoginDto,
    // passthrough: true → NestJS sigue manejando la serialización de la respuesta.
    // Sin passthrough, devolver res.json() sería responsabilidad del método.
    @Res({ passthrough: true }) res: Response,
  ) {
    const tokens = await this.authService.login(body.email, body.password);

    // Setear refresh_token en cookie HTTP-only.
    // path: '/auth/refresh' limita el envío automático de la cookie a ese endpoint.
    res.cookie('refresh_token', tokens.refresh_token, REFRESH_COOKIE_OPTIONS);

    // Retornar ambos tokens en JSON para compatibilidad con clientes que usan el body.
    // tenant_id NO se incluye en la cookie — siempre viaja en el JWT validado.
    return tokens;
  }

  // Ruta protegida — retorna el perfil del usuario autenticado.
  // Flutter usa esto para: cold start (token en storage → validar + cargar perfil),
  // settings screen, role-based UI gating.
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Obtener perfil del usuario autenticado' })
  @ApiResponse({ status: 200, description: 'Perfil del usuario' })
  @ApiResponse({ status: 401, description: 'Token inválido o expirado' })
  @Get('me')
  getProfile(@CurrentUser() user: any) {
    return this.authService.getProfile(user.sub);
  }

  // Ruta protegida con JwtRefreshGuard (JWT_REFRESH_SECRET).
  // Acepta refresh token desde 3 fuentes en orden de prioridad:
  //   1. Cookie HTTP-only 'refresh_token'
  //   2. Authorization: Bearer <token>
  //   3. Body: { "refresh_token": "..." }
  // La rotación invalida el token anterior — user.refreshToken viene de JwtRefreshStrategy.
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Rotar refresh token y obtener nuevos tokens' })
  @ApiResponse({ status: 200, description: 'Tokens rotados correctamente' })
  @ApiResponse({ status: 403, description: 'Refresh token inválido o expirado' })
  @UseGuards(JwtRefreshGuard)
  @HttpCode(HttpStatus.OK)
  @Post('refresh')
  async refreshTokens(
    @CurrentUser() user: any,
    @Res({ passthrough: true }) res: Response,
  ) {
    const tokens = await this.authService.refreshTokens(
      user.sub,
      user.refreshToken,
    );

    // Rotar cookie: el nuevo refresh_token reemplaza al anterior.
    // El hash anterior ya fue invalidado en AuthService.refreshTokens().
    res.cookie('refresh_token', tokens.refresh_token, REFRESH_COOKIE_OPTIONS);

    return tokens;
  }

  // Ruta protegida con JwtAuthGuard (JWT_SECRET — access token).
  // Limpia el refresh_token_hash en BD e invalida la cookie.
  // user.id viene de JwtStrategy.validate() que retorna { id: payload.sub, ... }.
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Cerrar sesión e invalidar refresh token' })
  @ApiResponse({ status: 200, description: 'Sesión cerrada correctamente' })
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @Post('logout')
  async logout(
    @CurrentUser() user: any,
    @Res({ passthrough: true }) res: Response,
  ) {
    const result = await this.authService.logout(user.id);

    // Limpiar cookie con las mismas opciones usadas al crearla (mismo path obligatorio).
    // Sin el path correcto, el browser no encuentra la cookie y no la elimina.
    res.clearCookie('refresh_token', REFRESH_COOKIE_OPTIONS);

    return result; // { message: 'Sesión cerrada correctamente' }
  }
}
