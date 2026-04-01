import { Controller, Get, Post, Body, Param, Query, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { MovimientosService } from './movimientos.service';
import { CreateMovimientoDto } from './dto/create-movimiento.dto';
import { FilterMovimientosDto } from './dto/filter-movimientos.dto';
import { Tenant } from '../common/decorators/tenant.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { JwtUserPayload } from '../common/interfaces/request-with-user.interface';

@ApiTags('movimientos')
@ApiBearerAuth('access-token')
@Controller('movimientos')
export class MovimientosController {
  constructor(private readonly movimientosService: MovimientosService) {}

  @ApiOperation({ summary: 'Mover un animal a otro potrero (con validación de capacidad)' })
  @ApiResponse({ status: 201, description: 'Movimiento registrado y animal actualizado' })
  @Post()
  moverAnimal(@Body() dto: CreateMovimientoDto, @Tenant() tenantId: string, @CurrentUser() user: JwtUserPayload) {
    return this.movimientosService.moverAnimal(dto, tenantId, user.sub);
  }

  @ApiOperation({ summary: 'Listar todos los movimientos del tenant (paginado)' })
  @ApiResponse({ status: 200, description: 'Lista paginada de movimientos' })
  @Get()
  findAll(@Query() filters: FilterMovimientosDto, @Tenant() tenantId: string) {
    return this.movimientosService.findAllPaginated(tenantId, filters);
  }

  @ApiOperation({ summary: 'Historial de movimientos de un animal' })
  @ApiParam({ name: 'animalId', description: 'ID del animal', example: 1 })
  @Get('animal/:animalId')
  findByAnimal(@Param('animalId', ParseIntPipe) animalId: number, @Tenant() tenantId: string) {
    return this.movimientosService.findByAnimal(animalId, tenantId);
  }
}
