import { Controller, Get, Post, Delete, Body, Param, Query, ParseIntPipe, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { BovinoAlimentoService } from './bovino-alimento.service';
import { AsignarAlimentoDto } from './dto/asignar-alimento.dto';
import { FilterBovinoAlimentoDto } from './dto/filter-bovino-alimento.dto';
import { Tenant } from '../common/decorators/tenant.decorator';

@ApiTags('bovino-alimento')
@ApiBearerAuth('access-token')
@Controller('bovino-alimento')
export class BovinoAlimentoController {
  constructor(private readonly bovinoAlimentoService: BovinoAlimentoService) {}

  @ApiOperation({ summary: 'Asignar un alimento a un animal' })
  @ApiResponse({ status: 201, description: 'Alimento asignado al animal' })
  @Post()
  asignar(@Body() dto: AsignarAlimentoDto, @Tenant() tenantId: string) {
    return this.bovinoAlimentoService.asignar(dto, tenantId);
  }

  @ApiOperation({ summary: 'Listar asignaciones de alimentos (paginado)' })
  @ApiResponse({ status: 200, description: 'Lista paginada de asignaciones' })
  @Get()
  findAll(@Query() filters: FilterBovinoAlimentoDto, @Tenant() tenantId: string) {
    return this.bovinoAlimentoService.findAllPaginated(tenantId, filters);
  }

  @ApiOperation({ summary: 'Consumo de alimentos de un animal' })
  @ApiParam({ name: 'animalId', description: 'ID del animal', example: 1 })
  @Get('animal/:animalId')
  findByAnimal(@Param('animalId', ParseIntPipe) animalId: number, @Tenant() tenantId: string) {
    return this.bovinoAlimentoService.findByAnimal(animalId, tenantId);
  }

  @ApiOperation({ summary: 'Quitar asignación de alimento a un animal' })
  @ApiParam({ name: 'animalId', description: 'ID del animal', example: 1 })
  @ApiParam({ name: 'alimentoId', description: 'ID del alimento', example: 'ALI001' })
  @Delete(':animalId/:alimentoId')
  @HttpCode(HttpStatus.OK)
  removeAsignacion(
    @Param('animalId', ParseIntPipe) animalId: number,
    @Param('alimentoId') alimentoId: string,
    @Tenant() tenantId: string,
  ) {
    return this.bovinoAlimentoService.removeAsignacion(animalId, alimentoId, tenantId);
  }
}
