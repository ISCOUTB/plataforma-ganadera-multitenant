import { Controller, Get, Query, ParseIntPipe } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { DashboardService } from './dashboard.service';
import { Tenant } from '../common/decorators/tenant.decorator';

@ApiTags('dashboard')
@ApiBearerAuth('access-token')
@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @ApiOperation({
    summary: 'Métricas de inteligencia (costos, top animales, estimación de ganancia)',
  })
  @ApiQuery({ name: 'fincaId', required: false, description: 'Filtra inteligencia a una finca; si se omite, devuelve global del tenant' })
  @ApiQuery({ name: 'month', required: false, example: 4 })
  @ApiQuery({ name: 'year', required: false, example: 2026 })
  @ApiResponse({ status: 200, description: 'Bloque inteligencia para carga lazy' })
  @Get('inteligencia')
  getInteligencia(
    @Tenant() tenantId: string,
    @Query('fincaId') fincaId?: string,
    @Query('month', new ParseIntPipe({ optional: true })) month?: number,
    @Query('year', new ParseIntPipe({ optional: true })) year?: number,
  ) {
    return this.dashboardService.getIntelligenceMetrics(
      tenantId,
      fincaId,
      month,
      year,
    );
  }

  /**
   * BFF (Backend For Frontend) — endpoint único para la UI del Dashboard
   * tipo "Bento Box". Agrupa demografía, ocupación, alertas críticas y
   * movimientos recientes en una sola respuesta para evitar N roundtrips
   * desde el móvil y permitir caché offline en el cliente.
   */
  @ApiOperation({
    summary: 'BFF Bento — demografía, ocupación, alertas críticas y movimientos recientes',
  })
  @ApiQuery({ name: 'fincaId', required: false, description: 'Filtra el payload a una finca; si se omite, devuelve el global del tenant' })
  @ApiResponse({
    status: 200,
    description: 'Payload agrupado para la UI del dashboard',
  })
  @Get('summary')
  getSummary(
    @Tenant() tenantId: string,
    @Query('fincaId') fincaId?: string,
  ) {
    return this.dashboardService.getSummary(tenantId, fincaId);
  }
}
