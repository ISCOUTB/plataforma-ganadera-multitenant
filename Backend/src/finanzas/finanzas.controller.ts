import { Controller, Get, Post, Patch, Delete, Body, Param, Query, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { FinanzasService } from './finanzas.service';
import { CreateFinanzaDto } from './dto/create-finanza.dto';
import { UpdateFinanzaDto } from './dto/update-finanza.dto';
import { FilterFinanzasDto } from './dto/filter-finanzas.dto';
import { Tenant } from '../common/decorators/tenant.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { JwtUserPayload } from '../common/interfaces/request-with-user.interface';

@ApiTags('finanzas')
@ApiBearerAuth('access-token')
@Controller('finanzas')
export class FinanzasController {
  constructor(private readonly finanzasService: FinanzasService) {}

  @ApiOperation({ summary: 'Crear movimiento financiero' })
  @ApiResponse({ status: 201, description: 'Movimiento creado' })
  @Post()
  create(@Body() dto: CreateFinanzaDto, @Tenant() tenantId: string, @CurrentUser() user: JwtUserPayload) {
    return this.finanzasService.create(dto, tenantId, user.sub);
  }

  @ApiOperation({ summary: 'Listar movimientos financieros del tenant (paginado)' })
  @ApiResponse({ status: 200, description: 'Lista paginada de movimientos' })
  @Get()
  findAll(@Query() filters: FilterFinanzasDto, @Tenant() tenantId: string) {
    return this.finanzasService.findAllPaginated(tenantId, filters);
  }

  @ApiOperation({ summary: 'Resumen financiero: ingresos, gastos, balance' })
  @ApiResponse({ status: 200, description: 'Resumen con totales y balance' })
  @Get('resumen')
  getResumen(@Tenant() tenantId: string) {
    return this.finanzasService.getResumen(tenantId);
  }

  @ApiOperation({ summary: 'Detalle de un movimiento financiero' })
  @ApiParam({ name: 'id', description: 'pk_id_finanza', example: 'FIN001' })
  @Get(':id')
  findOne(@Param('id') id: string, @Tenant() tenantId: string) {
    return this.finanzasService.findOne(id, tenantId);
  }

  @ApiOperation({ summary: 'Actualizar movimiento financiero' })
  @ApiParam({ name: 'id', description: 'pk_id_finanza', example: 'FIN001' })
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateFinanzaDto, @Tenant() tenantId: string, @CurrentUser() user: JwtUserPayload) {
    return this.finanzasService.update(id, dto, tenantId, user.sub);
  }

  @ApiOperation({ summary: 'Eliminar movimiento financiero (soft delete)' })
  @ApiParam({ name: 'id', description: 'pk_id_finanza', example: 'FIN001' })
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  remove(@Param('id') id: string, @Tenant() tenantId: string) {
    return this.finanzasService.remove(id, tenantId);
  }
}
