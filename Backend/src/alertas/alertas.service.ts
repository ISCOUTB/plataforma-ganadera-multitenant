import { Injectable } from '@nestjs/common';
import { SaludService } from '../salud/salud.service';
import { ReproduccionService } from '../reproduccion/reproduccion.service';

export interface AlertaPriorizada {
  tipo: string;
  severity: 'HIGH' | 'MEDIUM' | 'LOW';
  detalle: any;
}

@Injectable()
export class AlertasService {
  constructor(
    private readonly saludService: SaludService,
    private readonly reproduccionService: ReproduccionService,
  ) {}

  /**
   * Alertas centralizadas con priorización por severidad.
   * HIGH: vencidas/partos vencidos — requieren acción inmediata
   * MEDIUM: próximas 7d/partos 30d — planificación necesaria
   * LOW: en celo — informativo, ventana de oportunidad
   */
  async getAll(tenantId: string) {
    const [salud, reproduccion] = await Promise.all([
      this.saludService.getAlertas(tenantId),
      this.reproduccionService.getAlertas(tenantId),
    ]);

    // Build prioritized flat list sorted by severity
    const severityOrder = { HIGH: 0, MEDIUM: 1, LOW: 2 };

    const alertas_priorizadas: AlertaPriorizada[] = [
      ...salud.vencidas.map((s) => ({ tipo: 'salud_vencida', severity: 'HIGH' as const, detalle: s })),
      ...reproduccion.partos_vencidos.map((r) => ({ tipo: 'parto_vencido', severity: 'HIGH' as const, detalle: r })),
      ...salud.proximas.map((s) => ({ tipo: 'salud_proxima', severity: 'MEDIUM' as const, detalle: s })),
      ...reproduccion.partos_proximos.map((r) => ({ tipo: 'parto_proximo', severity: 'MEDIUM' as const, detalle: r })),
      ...reproduccion.en_celo.map((r) => ({ tipo: 'en_celo', severity: 'LOW' as const, detalle: r })),
    ];

    alertas_priorizadas.sort((a, b) => severityOrder[a.severity] - severityOrder[b.severity]);

    const highCount = salud.vencidas.length + reproduccion.partos_vencidos.length;
    const mediumCount = salud.proximas.length + reproduccion.partos_proximos.length;
    const lowCount = reproduccion.en_celo.length;

    return {
      salud: {
        proximas: salud.proximas.length,
        vencidas: salud.vencidas.length,
        detalle_proximas: salud.proximas,
        detalle_vencidas: salud.vencidas,
      },
      reproduccion: {
        partos_proximos: reproduccion.partos_proximos.length,
        partos_vencidos: reproduccion.partos_vencidos.length,
        en_celo: reproduccion.en_celo.length,
        detalle_partos_proximos: reproduccion.partos_proximos,
        detalle_partos_vencidos: reproduccion.partos_vencidos,
        detalle_en_celo: reproduccion.en_celo,
      },
      resumen: {
        total_alertas: highCount + mediumCount + lowCount,
        requiere_atencion_urgente: highCount,
        por_severidad: {
          HIGH: highCount,
          MEDIUM: mediumCount,
          LOW: lowCount,
        },
      },
      alertas_priorizadas,
    };
  }
}
