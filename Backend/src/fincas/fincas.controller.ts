import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { FincasService } from './fincas.service';
import { CreateFincaDto } from './dto/create-finca.dto';
import { UpdateFincaDto } from './dto/update-finca.dto';
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

  // GET /fincas — lista fincas activas del tenant.
  @ApiOperation({ summary: 'Listar todas las fincas activas del tenant' })
  @ApiResponse({ status: 200, description: 'Lista de fincas del tenant' })
  @Get()
  findAll(@Tenant() tenantId: string) {
    return this.fincasService.findAll(tenantId);
  }

  // GET /fincas/:id — detalle de una finca del tenant.
  @ApiOperation({ summary: 'Obtener detalle de una finca' })
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
