import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { AnimalesService } from './animales.service';
import { CreateAnimalDto } from './dto/create-animal.dto';
import { UpdateAnimalDto } from './dto/update-animal.dto';
import { VenderAnimalDto } from './dto/vender-animal.dto';
import { FilterAnimalesDto } from './dto/filter-animales.dto';
import { Tenant } from '../common/decorators/tenant.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { JwtUserPayload } from '../common/interfaces/request-with-user.interface';

@ApiTags('animales')
@ApiBearerAuth('access-token')
@Controller('animales')
export class AnimalesController {
  constructor(private readonly animalesService: AnimalesService) {}

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

  @ApiOperation({ summary: 'Listar bovinos del tenant (paginado, con filtros opcionales)' })
  @ApiResponse({ status: 200, description: 'Lista paginada de bovinos' })
  @Get()
  findAll(@Query() filters: FilterAnimalesDto, @Tenant() tenantId: string) {
    return this.animalesService.findAllPaginated(tenantId, filters);
  }

  @ApiOperation({ summary: 'Costos acumulados del animal: salud + alimentación' })
  @ApiParam({ name: 'id', description: 'ID numérico del bovino', type: Number })
  @ApiResponse({ status: 200, description: 'Desglose de costos del animal' })
  @ApiResponse({ status: 404, description: 'Bovino no encontrado' })
  @Get(':id/costos')
  getCostos(
    @Param('id', ParseIntPipe) id: number,
    @Tenant() tenantId: string,
  ) {
    return this.animalesService.getCostos(id, tenantId);
  }

  @ApiOperation({ summary: 'Registrar venta de un animal + crear ingreso financiero' })
  @ApiParam({ name: 'id', description: 'ID numérico del bovino', type: Number })
  @ApiResponse({ status: 200, description: 'Animal vendido y finanza creada' })
  @ApiResponse({ status: 400, description: 'Animal ya vendido o datos inválidos' })
  @ApiResponse({ status: 404, description: 'Bovino no encontrado' })
  @Post(':id/vender')
  vender(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: VenderAnimalDto,
    @Tenant() tenantId: string,
    @CurrentUser() user: JwtUserPayload,
  ) {
    return this.animalesService.vender(id, dto, tenantId, user.sub);
  }

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
