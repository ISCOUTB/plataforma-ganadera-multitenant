import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { AnimalesService } from './animales.service';
import { CreateAnimalDto } from './dto/create-animal.dto';
import { UpdateAnimalDto } from './dto/update-animal.dto';
import { Tenant } from '../common/decorators/tenant.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { JwtUserPayload } from '../common/interfaces/request-with-user.interface';

// Todas las rutas están protegidas por defecto (JwtAuthGuard global).
// @Tenant() y @CurrentUser() son inyectados por TenantGuard tras validar el JWT.
// tenant_id NUNCA viene del body — siempre del JWT validado.
@ApiTags('animales')
@ApiBearerAuth('access-token')
@Controller('animales')
export class AnimalesController {
  constructor(private readonly animalesService: AnimalesService) {}

  // POST /animales — crea bovino en el tenant del usuario autenticado.
  @ApiOperation({ summary: 'Crear un bovino en el tenant del usuario autenticado' })
  @ApiResponse({ status: 201, description: 'Bovino creado correctamente' })
  @ApiResponse({ status: 400, description: 'Datos inválidos o campos extra' })
  @Post()
  create(
    @Body() dto: CreateAnimalDto,
    @Tenant() tenantId: string,
    @CurrentUser() user: JwtUserPayload,
  ) {
    return this.animalesService.create(dto, tenantId, user.sub);
  }

  // GET /animales — lista bovinos activos del tenant.
  @ApiOperation({ summary: 'Listar todos los bovinos activos del tenant' })
  @ApiResponse({ status: 200, description: 'Lista de bovinos del tenant' })
  @Get()
  findAll(@Tenant() tenantId: string) {
    return this.animalesService.findAll(tenantId);
  }

  // GET /animales/:id — detalle de un bovino del tenant.
  @ApiOperation({ summary: 'Obtener detalle de un bovino' })
  @ApiParam({ name: 'id', description: 'ID numérico del bovino', type: Number })
  @ApiResponse({ status: 200, description: 'Detalle del bovino' })
  @ApiResponse({ status: 404, description: 'Bovino no encontrado' })
  @Get(':id')
  findOne(
    @Param('id', ParseIntPipe) id: number,
    @Tenant() tenantId: string,
  ) {
    return this.animalesService.findOne(id, tenantId);
  }

  // PATCH /animales/:id — actualiza campos del bovino.
  @ApiOperation({ summary: 'Actualizar campos de un bovino' })
  @ApiParam({ name: 'id', description: 'ID numérico del bovino', type: Number })
  @ApiResponse({ status: 200, description: 'Bovino actualizado correctamente' })
  @ApiResponse({ status: 404, description: 'Bovino no encontrado' })
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateAnimalDto,
    @Tenant() tenantId: string,
    @CurrentUser() user: JwtUserPayload,
  ) {
    return this.animalesService.update(id, dto, tenantId, user.sub);
  }

  // DELETE /animales/:id — soft delete (deleted_at = NOW()).
  @ApiOperation({ summary: 'Soft delete de un bovino (deleted_at = NOW())' })
  @ApiParam({ name: 'id', description: 'ID numérico del bovino', type: Number })
  @ApiResponse({ status: 200, description: 'Bovino eliminado correctamente' })
  @ApiResponse({ status: 404, description: 'Bovino no encontrado' })
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  remove(
    @Param('id', ParseIntPipe) id: number,
    @Tenant() tenantId: string,
  ) {
    return this.animalesService.remove(id, tenantId);
  }
}
