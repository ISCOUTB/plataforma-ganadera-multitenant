import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { UsuariosService } from './usuarios.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Tenant } from '../common/decorators/tenant.decorator';

@ApiTags('usuarios')
@Controller('usuarios')
export class UsuariosController {
  constructor(private readonly usuariosService: UsuariosService) {}

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Listar usuarios del tenant autenticado' })
  @ApiResponse({ status: 200, description: 'Lista de usuarios del tenant' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @UseGuards(JwtAuthGuard)
  @Get()
  findAll(@Tenant() tenantId: string) {
    return this.usuariosService.findAll(tenantId);
  }
}
