import { Controller, Get, Post, Patch, Delete, Body, Param, Query, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { AlimentosService } from './alimentos.service';
import { CreateAlimentoDto } from './dto/create-alimento.dto';
import { UpdateAlimentoDto } from './dto/update-alimento.dto';
import { FilterAlimentosDto } from './dto/filter-alimentos.dto';
import { Tenant } from '../common/decorators/tenant.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { JwtUserPayload } from '../common/interfaces/request-with-user.interface';

@ApiTags('alimentos')
@ApiBearerAuth('access-token')
@Controller('alimentos')
export class AlimentosController {
  constructor(private readonly alimentosService: AlimentosService) {}

  @ApiOperation({ summary: 'Crear un alimento' })
  @ApiResponse({ status: 201, description: 'Alimento creado' })
  @Post()
  create(@Body() dto: CreateAlimentoDto, @Tenant() tenantId: string, @CurrentUser() user: JwtUserPayload) {
    return this.alimentosService.create(dto, tenantId, user.sub);
  }

  @ApiOperation({ summary: 'Listar alimentos activos del tenant (paginado)' })
  @ApiResponse({ status: 200, description: 'Lista paginada de alimentos' })
  @Get()
  findAll(@Query() filters: FilterAlimentosDto, @Tenant() tenantId: string) {
    return this.alimentosService.findAllPaginated(tenantId, filters);
  }

  @ApiOperation({ summary: 'Obtener detalle de un alimento' })
  @ApiParam({ name: 'id', description: 'pk_id_alimento', example: 'ALI001' })
  @Get(':id')
  findOne(@Param('id') id: string, @Tenant() tenantId: string) {
    return this.alimentosService.findOne(id, tenantId);
  }

  @ApiOperation({ summary: 'Actualizar un alimento' })
  @ApiParam({ name: 'id', description: 'pk_id_alimento', example: 'ALI001' })
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateAlimentoDto, @Tenant() tenantId: string, @CurrentUser() user: JwtUserPayload) {
    return this.alimentosService.update(id, dto, tenantId, user.sub);
  }

  @ApiOperation({ summary: 'Soft delete de un alimento' })
  @ApiParam({ name: 'id', description: 'pk_id_alimento', example: 'ALI001' })
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  remove(@Param('id') id: string, @Tenant() tenantId: string) {
    return this.alimentosService.remove(id, tenantId);
  }
}
