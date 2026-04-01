import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
} from '@nestjs/swagger';
import { PotrerosService } from './potreros.service';
import { CreatePotreroDto } from './dto/create-potrero.dto';
import { UpdatePotreroDto } from './dto/update-potrero.dto';
import { FilterPotrerosDto } from './dto/filter-potreros.dto';
import { Tenant } from '../common/decorators/tenant.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { JwtUserPayload } from '../common/interfaces/request-with-user.interface';

@ApiTags('potreros')
@ApiBearerAuth('access-token')
@Controller('potreros')
export class PotrerosController {
  constructor(private readonly potrerosService: PotrerosService) {}

  @ApiOperation({ summary: 'Crear un potrero en el tenant del usuario autenticado' })
  @ApiResponse({ status: 201, description: 'Potrero creado correctamente' })
  @ApiResponse({ status: 400, description: 'Datos inválidos o campos extra' })
  @Post()
  create(
    @Body() dto: CreatePotreroDto,
    @Tenant() tenantId: string,
    @CurrentUser() user: JwtUserPayload,
  ) {
    return this.potrerosService.create(dto, tenantId, user.sub);
  }

  @ApiOperation({
    summary: 'Listar potreros del tenant (paginado, con filtros opcionales)',
  })
  @ApiResponse({ status: 200, description: 'Lista paginada de potreros: { data, total, page, lastPage }' })
  @Get()
  findAll(@Query() filters: FilterPotrerosDto, @Tenant() tenantId: string) {
    return this.potrerosService.findAllPaginated(tenantId, filters);
  }

  @ApiOperation({ summary: 'Obtener ocupación y estado del potrero' })
  @ApiParam({ name: 'id', description: 'pk_id_potrero', example: 'POT001' })
  @ApiResponse({ status: 200, description: 'Ocupación: actual, capacidad, porcentaje, estado' })
  @Get(':id/ocupacion')
  getOccupancy(@Param('id') id: string, @Tenant() tenantId: string) {
    return this.potrerosService.getOccupancy(id, tenantId);
  }

  @ApiOperation({ summary: 'Listar animales activos asignados a un potrero' })
  @ApiParam({ name: 'id', description: 'pk_id_potrero (ej: POT001)', example: 'POT001' })
  @ApiResponse({ status: 200, description: 'Lista de animales del potrero' })
  @ApiResponse({ status: 404, description: 'Potrero no encontrado' })
  @Get(':id/animales')
  findAnimals(
    @Param('id') id: string,
    @Tenant() tenantId: string,
  ) {
    return this.potrerosService.findAnimalsByPotrero(id, tenantId);
  }

  @ApiOperation({ summary: 'Obtener detalle de un potrero' })
  @ApiParam({ name: 'id', description: 'pk_id_potrero (ej: POT001)', example: 'POT001' })
  @ApiResponse({ status: 200, description: 'Detalle del potrero' })
  @ApiResponse({ status: 404, description: 'Potrero no encontrado' })
  @Get(':id')
  findOne(
    @Param('id') id: string,
    @Tenant() tenantId: string,
  ) {
    return this.potrerosService.findOne(id, tenantId);
  }

  @ApiOperation({ summary: 'Actualizar campos de un potrero' })
  @ApiParam({ name: 'id', description: 'pk_id_potrero (ej: POT001)', example: 'POT001' })
  @ApiResponse({ status: 200, description: 'Potrero actualizado correctamente' })
  @ApiResponse({ status: 404, description: 'Potrero no encontrado' })
  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() dto: UpdatePotreroDto,
    @Tenant() tenantId: string,
    @CurrentUser() user: JwtUserPayload,
  ) {
    return this.potrerosService.update(id, dto, tenantId, user.sub);
  }

  @ApiOperation({ summary: 'Soft delete de un potrero (deleted_at = NOW())' })
  @ApiParam({ name: 'id', description: 'pk_id_potrero (ej: POT001)', example: 'POT001' })
  @ApiResponse({ status: 200, description: 'Potrero eliminado correctamente' })
  @ApiResponse({ status: 404, description: 'Potrero no encontrado' })
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  remove(
    @Param('id') id: string,
    @Tenant() tenantId: string,
  ) {
    return this.potrerosService.remove(id, tenantId);
  }
}
