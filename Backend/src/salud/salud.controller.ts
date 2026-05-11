import { Controller, Get, Post, Patch, Delete, Body, Param, Query, ParseIntPipe, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { SaludService } from './salud.service';
import { CreateSaludDto } from './dto/create-salud.dto';
import { UpdateSaludDto } from './dto/update-salud.dto';
import { FilterSaludDto } from './dto/filter-salud.dto';
import { Tenant } from '../common/decorators/tenant.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { JwtUserPayload } from '../common/interfaces/request-with-user.interface';

@ApiTags('salud')
@ApiBearerAuth('access-token')
@Controller('salud')
export class SaludController {
  constructor(private readonly saludService: SaludService) {}

  @ApiOperation({ summary: 'Crear registro de salud' })
  @ApiResponse({ status: 201, description: 'Registro creado' })
  @Post()
  create(@Body() dto: CreateSaludDto, @Tenant() tenantId: string, @CurrentUser() user: JwtUserPayload) {
    return this.saludService.create(dto, tenantId, user.sub);
  }

  @ApiOperation({ summary: 'Listar registros de salud del tenant (paginado)' })
  @ApiResponse({ status: 200, description: 'Lista paginada de registros' })
  @Get()
  findAll(@Query() filters: FilterSaludDto, @Tenant() tenantId: string) {
    return this.saludService.findAllPaginated(tenantId, filters);
  }

  @ApiOperation({ summary: 'Alertas de salud: próximas (7 días) y vencidas' })
  @ApiResponse({ status: 200, description: 'Alertas agrupadas por próximas y vencidas' })
  @Get('alertas')
  getAlertas(@Tenant() tenantId: string) {
    return this.saludService.getAlertas(tenantId);
  }

  @ApiOperation({ summary: 'Detalle de un registro de salud' })
  @ApiParam({ name: 'id', description: 'ID del registro', example: 1 })
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @Tenant() tenantId: string) {
    return this.saludService.findOne(id, tenantId);
  }

  @ApiOperation({ summary: 'Actualizar registro de salud' })
  @ApiParam({ name: 'id', description: 'ID del registro', example: 1 })
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateSaludDto,
    @Tenant() tenantId: string,
    @CurrentUser() user: JwtUserPayload,
  ) {
    return this.saludService.update(id, dto, tenantId, user.sub);
  }

  @ApiOperation({ summary: 'Eliminar registro de salud (soft delete)' })
  @ApiParam({ name: 'id', description: 'ID del registro', example: 1 })
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  remove(@Param('id', ParseIntPipe) id: number, @Tenant() tenantId: string) {
    return this.saludService.remove(id, tenantId);
  }
}
