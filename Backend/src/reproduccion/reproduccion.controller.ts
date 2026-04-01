import { Controller, Get, Post, Patch, Delete, Body, Param, Query, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { ReproduccionService } from './reproduccion.service';
import { CreateReproduccionDto } from './dto/create-reproduccion.dto';
import { UpdateReproduccionDto } from './dto/update-reproduccion.dto';
import { FilterReproduccionDto } from './dto/filter-reproduccion.dto';
import { Tenant } from '../common/decorators/tenant.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { JwtUserPayload } from '../common/interfaces/request-with-user.interface';

@ApiTags('reproduccion')
@ApiBearerAuth('access-token')
@Controller('reproduccion')
export class ReproduccionController {
  constructor(private readonly reproduccionService: ReproduccionService) {}

  @ApiOperation({ summary: 'Crear registro reproductivo' })
  @ApiResponse({ status: 201, description: 'Registro creado' })
  @Post()
  create(@Body() dto: CreateReproduccionDto, @Tenant() tenantId: string, @CurrentUser() user: JwtUserPayload) {
    return this.reproduccionService.create(dto, tenantId, user.sub);
  }

  @ApiOperation({ summary: 'Listar registros reproductivos del tenant (paginado)' })
  @ApiResponse({ status: 200, description: 'Lista paginada de registros' })
  @Get()
  findAll(@Query() filters: FilterReproduccionDto, @Tenant() tenantId: string) {
    return this.reproduccionService.findAllPaginated(tenantId, filters);
  }

  @ApiOperation({ summary: 'Alertas reproductivas: partos próximos (30 días), en celo, vencidos' })
  @ApiResponse({ status: 200, description: 'Alertas agrupadas' })
  @Get('alertas')
  getAlertas(@Tenant() tenantId: string) {
    return this.reproduccionService.getAlertas(tenantId);
  }

  @ApiOperation({ summary: 'Detalle de un registro reproductivo' })
  @ApiParam({ name: 'id', description: 'pk_id_reproduccion', example: 'REP001' })
  @Get(':id')
  findOne(@Param('id') id: string, @Tenant() tenantId: string) {
    return this.reproduccionService.findOne(id, tenantId);
  }

  @ApiOperation({ summary: 'Actualizar registro reproductivo' })
  @ApiParam({ name: 'id', description: 'pk_id_reproduccion', example: 'REP001' })
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateReproduccionDto, @Tenant() tenantId: string, @CurrentUser() user: JwtUserPayload) {
    return this.reproduccionService.update(id, dto, tenantId, user.sub);
  }

  @ApiOperation({ summary: 'Eliminar registro reproductivo (soft delete)' })
  @ApiParam({ name: 'id', description: 'pk_id_reproduccion', example: 'REP001' })
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  remove(@Param('id') id: string, @Tenant() tenantId: string) {
    return this.reproduccionService.remove(id, tenantId);
  }
}
