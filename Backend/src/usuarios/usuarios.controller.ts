import { Controller, Post, Get, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { UsuariosService } from './usuarios.service';
import { AuthService } from '../auth/auth.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Public } from '../auth/decorators/public.decorator';
import { Tenant } from '../common/decorators/tenant.decorator';
import { LoginDto } from '../auth/dto/login.dto';
import { RegistroDto } from '../auth/dto/registro.dto';

@ApiTags('usuarios')
@Controller('usuarios')
export class UsuariosController {
  constructor(
    private readonly usuariosService: UsuariosService,
    // AuthService inyectado para los stubs de compatibilidad con el frontend Flutter actual.
    // Fase 10: actualizar Flutter a /auth/* y eliminar estos stubs.
    private readonly authService: AuthService,
  ) {}

  // STUB DE COMPATIBILIDAD — @deprecated: usar POST /auth/registro
  // Mantiene funcionando el frontend Flutter hasta la migración en Fase 10.
  @ApiOperation({ summary: '[Legacy] Registrar usuario — usar POST /auth/registro' })
  @ApiResponse({ status: 201, description: 'Usuario registrado' })
  @Public()
  @Post('registro')
  registro(@Body() body: RegistroDto) {
    return this.authService.registro(body);
  }

  // STUB DE COMPATIBILIDAD — @deprecated: usar POST /auth/login
  // Mantiene funcionando el frontend Flutter hasta la migración en Fase 10.
  @ApiOperation({ summary: '[Legacy] Iniciar sesión — usar POST /auth/login' })
  @ApiResponse({ status: 200, description: 'Login exitoso' })
  @Public()
  @Post('login')
  login(@Body() body: LoginDto) {
    return this.authService.login(body.email, body.password);
  }

  // Ruta protegida — requiere token JWT válido (global JwtAuthGuard lo aplica).
  // CORRECCIÓN DE VIOLACIÓN: tenantId inyectado por TenantGuard desde el JWT,
  // NUNCA tomado del body o query params.
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Listar usuarios del tenant autenticado' })
  @ApiResponse({ status: 200, description: 'Lista de usuarios del tenant' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @UseGuards(JwtAuthGuard)
  @Get()
  findAll(@CurrentUser() user: any, @Tenant() tenantId: string) {
    console.log('Usuario autenticado:', user.email, '| Rol:', user.rol);
    return this.usuariosService.findAll(tenantId);
  }
}
