import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { UsuariosService } from './usuarios.service';
import { Tenant } from '../common/decorators/tenant.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { JwtUserPayload } from '../common/interfaces/request-with-user.interface';
import { CreateUsuarioDto } from './dto/create-usuario.dto';
import { UpdateUsuarioDto } from './dto/update-usuario.dto';

@ApiTags('usuarios')
@ApiBearerAuth('access-token')
@Controller('usuarios')
export class UsuariosController {
  constructor(private readonly usuariosService: UsuariosService) {}

  @ApiOperation({ summary: 'Listar usuarios del tenant autenticado' })
  @ApiResponse({ status: 200, description: 'Lista de usuarios del tenant' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @Roles('admin', 'superadmin')
  @Get()
  findAll(@Tenant() tenantId: string) {
    return this.usuariosService.findAll(tenantId);
  }

  @ApiOperation({ summary: 'Crear usuario dentro del tenant autenticado' })
  @ApiResponse({ status: 201, description: 'Usuario creado' })
  @ApiResponse({ status: 409, description: 'Email ya registrado' })
  @Roles('admin', 'superadmin')
  @Post()
  create(
    @Tenant() tenantId: string,
    @CurrentUser() actor: JwtUserPayload,
    @Body() dto: CreateUsuarioDto,
  ) {
    return this.usuariosService.create(dto, tenantId, actor.sub);
  }

  @ApiOperation({ summary: 'Actualizar usuario del tenant' })
  @ApiResponse({ status: 200, description: 'Usuario actualizado' })
  @ApiResponse({ status: 404, description: 'Usuario no encontrado' })
  @Roles('admin', 'superadmin')
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Tenant() tenantId: string,
    @CurrentUser() actor: JwtUserPayload,
    @Body() dto: UpdateUsuarioDto,
  ) {
    return this.usuariosService.update(id, dto, tenantId, actor.sub);
  }

  @ApiOperation({ summary: 'Eliminar usuario (soft delete) del tenant' })
  @ApiResponse({ status: 200, description: 'Usuario eliminado' })
  @ApiResponse({ status: 400, description: 'No puedes eliminarte a ti mismo' })
  @ApiResponse({ status: 404, description: 'Usuario no encontrado' })
  @Roles('admin', 'superadmin')
  @Delete(':id')
  remove(
    @Param('id', ParseIntPipe) id: number,
    @Tenant() tenantId: string,
    @CurrentUser() actor: JwtUserPayload,
  ) {
    return this.usuariosService.remove(id, tenantId, actor.sub);
  }
}
