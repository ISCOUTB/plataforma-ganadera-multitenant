import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AlertasService } from './alertas.service';
import { Tenant } from '../common/decorators/tenant.decorator';

@ApiTags('alertas')
@ApiBearerAuth('access-token')
@Controller('alertas')
export class AlertasController {
  constructor(private readonly alertasService: AlertasService) {}

  @ApiOperation({ summary: 'Alertas centralizadas: salud + reproducción' })
  @ApiResponse({ status: 200, description: 'Todas las alertas del tenant agrupadas por módulo' })
  @Get()
  getAll(@Tenant() tenantId: string) {
    return this.alertasService.getAll(tenantId);
  }
}
