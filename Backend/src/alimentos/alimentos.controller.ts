import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AlimentosService } from './alimentos.service';
import { Tenant } from '../common/decorators/tenant.decorator';

@ApiTags('alimentos')
@ApiBearerAuth('access-token')
@Controller('alimentos')
export class AlimentosController {
  constructor(private readonly alimentosService: AlimentosService) {}

  // CORRECCIÓN DE VIOLACIÓN: @Tenant() extrae el tenant_id del JWT (guard-injected).
  // NUNCA se acepta tenant_id del body o query params.
  @ApiOperation({ summary: 'Listar todos los alimentos activos del tenant' })
  @ApiResponse({ status: 200, description: 'Lista de alimentos del tenant' })
  @Get()
  findAll(@Tenant() tenantId: string) {
    return this.alimentosService.findAll(tenantId);
  }
}
