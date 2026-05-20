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
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { FincasService } from './fincas.service';
import { CreateFincaDto } from './dto/create-finca.dto';
import { UpdateFincaDto } from './dto/update-finca.dto';
import { FilterFincasDto } from './dto/filter-fincas.dto';
import { Tenant } from '../common/decorators/tenant.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { JwtUserPayload } from '../common/interfaces/request-with-user.interface';

// Todas las rutas están protegidas por defecto (JwtAuthGuard global).
// pk_id_finca es la PK string manual (ej: "FINCA001").
@ApiTags('fincas')
@ApiBearerAuth('access-token')
@Controller('fincas')
export class FincasController {
  constructor(private readonly fincasService: FincasService) {}

  // POST /fincas — crea una finca en el tenant del usuario autenticado.
  @ApiOperation({ summary: 'Crear una finca en el tenant del usuario autenticado' })
  @ApiResponse({ status: 201, description: 'Finca creada correctamente' })
  @ApiResponse({ status: 400, description: 'Datos inválidos o campos extra' })
  @Post()
  create(
    @Body() dto: CreateFincaDto,
    @Tenant() tenantId: string,
    @CurrentUser() user: JwtUserPayload,
  ) {
    return this.fincasService.create(dto, tenantId, user.sub);
  }

  // GET /fincas — lista fincas activas del tenant con paginación y filtros.
  @ApiOperation({
    summary: 'Listar fincas del tenant (paginado, con filtros opcionales)',
  })
  @ApiResponse({ status: 200, description: 'Lista paginada de fincas: { data, total, page, lastPage }' })
  @Get()
  findAll(@Query() filters: FilterFincasDto, @Tenant() tenantId: string) {
    return this.fincasService.findAllPaginated(tenantId, filters);
  }

  @ApiOperation({ summary: 'Listar animales de una finca' })
  @ApiParam({ name: 'id', description: 'pk_id_finca', example: 'FINCA001' })
  @ApiResponse({ status: 200, description: 'Lista de animales de la finca' })
  @ApiResponse({ status: 404, description: 'Finca no encontrada' })
  @Get(':id/animales')
  findAnimales(@Param('id') id: string, @Tenant() tenantId: string) {
    return this.fincasService.findAnimalesByFinca(id, tenantId);
  }

  @ApiOperation({ summary: 'Listar potreros de una finca' })
  @ApiParam({ name: 'id', description: 'pk_id_finca', example: 'FINCA001' })
  @ApiResponse({ status: 200, description: 'Lista de potreros de la finca' })
  @ApiResponse({ status: 404, description: 'Finca no encontrada' })
  @Get(':id/potreros')
  findPotreros(@Param('id') id: string, @Tenant() tenantId: string) {
    return this.fincasService.findPotrerosByFinca(id, tenantId);
  }

  @ApiOperation({ summary: 'Obtener detalle de una finca con relaciones' })
  @ApiParam({ name: 'id', description: 'pk_id_finca (ej: FINCA001)', example: 'FINCA001' })
  @ApiResponse({ status: 200, description: 'Detalle de la finca' })
  @ApiResponse({ status: 404, description: 'Finca no encontrada' })
  @Get(':id')
  findOne(
    @Param('id') id: string,
    @Tenant() tenantId: string,
  ) {
    return this.fincasService.findOne(id, tenantId);
  }

  // PATCH /fincas/:id — actualiza campos de la finca (pk_id_finca no modificable).
  @ApiOperation({ summary: 'Actualizar campos de una finca' })
  @ApiParam({ name: 'id', description: 'pk_id_finca', example: 'FINCA001' })
  @ApiResponse({ status: 200, description: 'Finca actualizada correctamente' })
  @ApiResponse({ status: 404, description: 'Finca no encontrada' })
  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() dto: UpdateFincaDto,
    @Tenant() tenantId: string,
    @CurrentUser() user: JwtUserPayload,
  ) {
    return this.fincasService.update(id, dto, tenantId, user.sub);
  }

  // DELETE /fincas/:id — soft delete de la finca.
  @ApiOperation({ summary: 'Soft delete de una finca (deleted_at = NOW())' })
  @ApiParam({ name: 'id', description: 'pk_id_finca', example: 'FINCA001' })
  @ApiResponse({ status: 200, description: 'Finca eliminada correctamente' })
  @ApiResponse({ status: 404, description: 'Finca no encontrada' })
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  remove(
    @Param('id') id: string,
    @Tenant() tenantId: string,
  ) {
    return this.fincasService.remove(id, tenantId);
  }
}
