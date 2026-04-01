import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { DashboardService } from './dashboard.service';
import { Tenant } from '../common/decorators/tenant.decorator';

@ApiTags('dashboard')
@ApiBearerAuth('access-token')
@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @ApiOperation({ summary: 'Métricas agregadas del tenant: inventario, finanzas, alertas' })
  @ApiResponse({ status: 200, description: 'Dashboard con métricas de decisión' })
  @Get()
  getMetrics(@Tenant() tenantId: string) {
    return this.dashboardService.getMetrics(tenantId);
  }
}
