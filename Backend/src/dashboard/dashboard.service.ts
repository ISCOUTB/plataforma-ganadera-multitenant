import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { Animal } from '../animales/entities/animal.entity';
import { Finca } from '../fincas/entities/finca.entity';
import { Potrero } from '../potreros/entities/potrero.entity';
import { Salud } from '../salud/entities/salud.entity';
import { Finanza } from '../finanzas/entities/finanza.entity';
import { MovimientoAnimal } from '../movimientos/entities/movimiento-animal.entity';

@Injectable()
export class DashboardService {
  constructor(
    @InjectRepository(Animal) private readonly animalRepo: Repository<Animal>,
    @InjectRepository(Finca) private readonly fincaRepo: Repository<Finca>,
    @InjectRepository(Potrero) private readonly potreroRepo: Repository<Potrero>,
    @InjectRepository(Salud) private readonly saludRepo: Repository<Salud>,
    @InjectRepository(Finanza) private readonly finanzaRepo: Repository<Finanza>,
    @InjectRepository(MovimientoAnimal) private readonly movimientoRepo: Repository<MovimientoAnimal>,
    private readonly dataSource: DataSource,
  ) {}

  /**
   * Verifica que la finca solicitada pertenezca al tenant antes de usarla
   * como filtro. Lanza `NotFoundException` si el id existe pero no pertenece
   * al tenant (o no existe en absoluto). Si `fincaId` viene vacío, no hace
   * nada — la vista global del tenant es legítima.
   */
  private async assertFincaOwnership(
    tenantId: string,
    fincaId?: string,
  ): Promise<void> {
    if (!fincaId) return;
    const exists = await this.fincaRepo
      .createQueryBuilder('f')
      .where('f.pk_id_finca = :fincaId', { fincaId })
      .andWhere('f.tenant_id = :tenantId', { tenantId })
      .andWhere('f.deleted_at IS NULL')
      .getExists();
    if (!exists) {
      throw new NotFoundException('Finca no encontrada');
    }
  }

  /**
   * Bloque "inteligencia" — análisis costoso (5 queries) servido en su
   * propio endpoint para permitir carga lazy desde el cliente y no
   * penalizar el dashboard principal.
   *
   * NOTA: month/year se aceptan en la firma para futura granularidad
   * temporal (estimación de ganancia por período); por ahora las 5
   * subqueries operan sobre el histórico completo.
   */
  async getIntelligenceMetrics(
    tenantId: string,
    fincaId?: string,
    _month?: number,
    _year?: number,
  ) {
    await this.assertFincaOwnership(tenantId, fincaId);

    const [
      costoTotal,
      top5Costosos,
      top5Potreros,
      animalesSinPotrero,
      estimacionGanancia,
    ] = await Promise.all([
      this.getCostoTotalAnimales(tenantId, fincaId),
      this.getTop5AnimalesCostosos(tenantId, fincaId),
      this.getTop5PotrerosActivos(tenantId, fincaId),
      this.getAnimalesSinPotrero(tenantId, fincaId),
      this.getEstimacionGanancia(tenantId, fincaId),
    ]);

    return {
      costo_total_animales: costoTotal,
      top_5_animales_costosos: top5Costosos,
      top_5_potreros_activos: top5Potreros,
      animales_sin_potrero: animalesSinPotrero,
      estimacion_ganancia: estimacionGanancia,
    };
  }

  private async getCostoTotalAnimales(tenantId: string, fincaId?: string) {
    const saludQb = this.dataSource
      .createQueryBuilder()
      .select('COALESCE(SUM(COALESCE(s.costo, 0)), 0)', 'total')
      .from('salud', 's')
      .where('s.tenant_id = :tenantId', { tenantId })
      .andWhere('s.deleted_at IS NULL');

    const alimentacionQb = this.dataSource
      .createQueryBuilder()
      .select(
        `COALESCE(SUM(
            CASE WHEN a.cantidad_total IS NOT NULL AND a.cantidad_total > 0 AND a.costo IS NOT NULL
            THEN (ba.cantidad / a.cantidad_total) * a.costo ELSE 0 END
          ), 0)`,
        'total',
      )
      .from('bovino_alimento', 'ba')
      // SEC-1: el JOIN a `alimento` debe filtrar por tenant_id para evitar
      // que costos de otro tenant se mezclen al compartir un fk_id_alimento.
      .innerJoin(
        'alimento',
        'a',
        'a.pk_id_alimento = ba.fk_id_alimento AND a.tenant_id = :tenantId AND a.deleted_at IS NULL',
        { tenantId },
      )
      .where('ba.tenant_id = :tenantId', { tenantId });

    if (fincaId) {
      saludQb
        .innerJoin('bovinos', 'b', 'b.id = s.fk_id_bovino')
        .andWhere('b."fincaPkIdFinca" = :fincaId', { fincaId });
      alimentacionQb
        .innerJoin('bovinos', 'b', 'b.id = ba.fk_id_bovino')
        .andWhere('b."fincaPkIdFinca" = :fincaId', { fincaId });
    }

    const [saludResult, alimentacionResult] = await Promise.all([
      saludQb.getRawOne(),
      alimentacionQb.getRawOne(),
    ]);

    const costo_salud = parseFloat(saludResult?.total) || 0;
    const costo_alimentacion = parseFloat(alimentacionResult?.total) || 0;

    return {
      costo_salud,
      costo_alimentacion,
      costo_total: costo_salud + costo_alimentacion,
    };
  }

  private async getTop5AnimalesCostosos(tenantId: string, fincaId?: string) {
    const fincaFilter = fincaId ? 'AND b."fincaPkIdFinca" = $2' : '';
    const params: unknown[] = fincaId ? [tenantId, fincaId] : [tenantId];

    const results = await this.dataSource.query(
      `SELECT
        b.id,
        b.numero_identificacion,
        COALESCE(sc.total, 0) + COALESCE(fc.total, 0) as costo_total,
        COALESCE(sc.total, 0) as costo_salud,
        COALESCE(fc.total, 0) as costo_alimentacion
      FROM bovinos b
      LEFT JOIN (
        SELECT s.fk_id_bovino, SUM(COALESCE(s.costo, 0)) as total
        FROM salud s
        WHERE s.tenant_id = $1 AND s.deleted_at IS NULL
        GROUP BY s.fk_id_bovino
      ) sc ON sc.fk_id_bovino = b.id
      LEFT JOIN (
        SELECT ba.fk_id_bovino,
          SUM(CASE WHEN a.cantidad_total IS NOT NULL AND a.cantidad_total > 0 AND a.costo IS NOT NULL
            THEN (ba.cantidad / a.cantidad_total) * a.costo ELSE 0 END) as total
        FROM bovino_alimento ba
        INNER JOIN alimento a
          ON a.pk_id_alimento = ba.fk_id_alimento
         AND a.tenant_id = $1
         AND a.deleted_at IS NULL
        WHERE ba.tenant_id = $1
        GROUP BY ba.fk_id_bovino
      ) fc ON fc.fk_id_bovino = b.id
      WHERE b.tenant_id = $1 AND b.deleted_at IS NULL ${fincaFilter}
      ORDER BY costo_total DESC
      LIMIT 5`,
      params,
    );

    return results.map((r: any) => ({
      id: r.id,
      numero_identificacion: r.numero_identificacion,
      costo_total: parseFloat(r.costo_total) || 0,
      costo_salud: parseFloat(r.costo_salud) || 0,
      costo_alimentacion: parseFloat(r.costo_alimentacion) || 0,
    }));
  }

  private async getTop5PotrerosActivos(tenantId: string, fincaId?: string) {
    const qb = this.potreroRepo
      .createQueryBuilder('p')
      .leftJoin('p.animales', 'a', "a.deleted_at IS NULL AND a.estado = 'activo'")
      .select('p.pk_id_potrero', 'pk_id_potrero')
      .addSelect('p.nombre_potrero', 'nombre_potrero')
      .addSelect('p.capacidad_animales', 'capacidad_animales')
      .addSelect('COUNT(a.id)', 'cantidad_animales')
      .where('p.tenant_id = :tenantId', { tenantId })
      .andWhere('p.deleted_at IS NULL')
      .groupBy('p.pk_id_potrero')
      .addGroupBy('p.nombre_potrero')
      .addGroupBy('p.capacidad_animales')
      .orderBy('cantidad_animales', 'DESC')
      .limit(5);

    if (fincaId) {
      qb.andWhere('p.fk_id_finca = :fincaId', { fincaId });
    }

    const results = await qb.getRawMany();

    return results.map((r: any) => ({
      pk_id_potrero: r.pk_id_potrero,
      nombre_potrero: r.nombre_potrero,
      capacidad_animales: parseInt(r.capacidad_animales, 10) || 0,
      cantidad_animales: parseInt(r.cantidad_animales, 10) || 0,
    }));
  }

  private async getAnimalesSinPotrero(
    tenantId: string,
    fincaId?: string,
  ): Promise<number> {
    const qb = this.animalRepo
      .createQueryBuilder('a')
      .where('a.tenant_id = :tenantId', { tenantId })
      .andWhere('a.deleted_at IS NULL')
      .andWhere('a.potrero IS NULL');
    if (fincaId) {
      qb.andWhere('a."fincaPkIdFinca" = :fincaId', { fincaId });
    }
    return qb.getCount();
  }

  /**
   * Estimación de ganancia: SOLO animales vendidos.
   * Revenue = SUM(precio_venta) de vendidos
   * Costs = salud + alimentación de vendidos solamente
   */
  private async getEstimacionGanancia(tenantId: string, fincaId?: string) {
    const ventasQb = this.animalRepo
      .createQueryBuilder('b')
      .select('COALESCE(SUM(b.precio_venta), 0)', 'total_ventas')
      .addSelect('COUNT(*)', 'animales_vendidos')
      .where('b.tenant_id = :tenantId', { tenantId })
      .andWhere('b.deleted_at IS NULL')
      .andWhere("b.estado = 'vendido'");

    const costoSaludQb = this.dataSource
      .createQueryBuilder()
      .select('COALESCE(SUM(COALESCE(s.costo, 0)), 0)', 'total')
      .from('salud', 's')
      .innerJoin(
        'bovinos',
        'b',
        'b.id = s.fk_id_bovino AND b.tenant_id = :tenantId',
        { tenantId },
      )
      .where('s.tenant_id = :tenantId', { tenantId })
      .andWhere('s.deleted_at IS NULL')
      .andWhere("b.estado = 'vendido'")
      .andWhere('b.deleted_at IS NULL');

    const costoAlimentacionQb = this.dataSource
      .createQueryBuilder()
      .select(
        `COALESCE(SUM(
            CASE WHEN a.cantidad_total IS NOT NULL AND a.cantidad_total > 0 AND a.costo IS NOT NULL
            THEN (ba.cantidad / a.cantidad_total) * a.costo ELSE 0 END
          ), 0)`,
        'total',
      )
      .from('bovino_alimento', 'ba')
      .innerJoin(
        'alimento',
        'a',
        'a.pk_id_alimento = ba.fk_id_alimento AND a.tenant_id = :tenantId AND a.deleted_at IS NULL',
        { tenantId },
      )
      .innerJoin(
        'bovinos',
        'b',
        'b.id = ba.fk_id_bovino AND b.tenant_id = :tenantId',
        { tenantId },
      )
      .where('ba.tenant_id = :tenantId', { tenantId })
      .andWhere("b.estado = 'vendido'")
      .andWhere('b.deleted_at IS NULL');

    if (fincaId) {
      ventasQb.andWhere('b."fincaPkIdFinca" = :fincaId', { fincaId });
      costoSaludQb.andWhere('b."fincaPkIdFinca" = :fincaId', { fincaId });
      costoAlimentacionQb.andWhere('b."fincaPkIdFinca" = :fincaId', { fincaId });
    }

    const [ventasResult, costoSaludResult, costoAlimentacionResult] =
      await Promise.all([
        ventasQb.getRawOne(),
        costoSaludQb.getRawOne(),
        costoAlimentacionQb.getRawOne(),
      ]);

    const total_ventas = parseFloat(ventasResult?.total_ventas) || 0;
    const animales_vendidos = parseInt(ventasResult?.animales_vendidos, 10) || 0;
    const costos_vendidos =
      (parseFloat(costoSaludResult?.total) || 0) +
      (parseFloat(costoAlimentacionResult?.total) || 0);

    return {
      total_ventas,
      costos_vendidos,
      ganancia_neta: total_ventas - costos_vendidos,
      animales_vendidos,
    };
  }

  // =====================================================================
  //  BFF — Endpoint único para la UI "Bento Box"
  //
  //  GET /api/dashboard/summary agrupa 9 bloques de datos en una sola
  //  llamada para evitar N round-trips desde el móvil. Usa Promise.all
  //  para correr las queries en paralelo. Acepta fincaId opcional para
  //  filtrar todas las cards al hato/potreros/finanzas de una finca; sin
  //  fincaId devuelve la vista global del tenant.
  // =====================================================================

  async getSummary(tenantId: string, fincaId?: string) {
    await this.assertFincaOwnership(tenantId, fincaId);

    const [
      demography,
      occupancy,
      criticalAlerts,
      recentMovements,
      genderSplit,
      financesSummary,
      topPotreros,
      allPotreros,
      trends,
    ] = await Promise.all([
      this.getDemographyBreakdown(tenantId, fincaId),
      this.getOccupancyHectares(tenantId, fincaId),
      this.getCriticalAlerts(tenantId, fincaId),
      this.getRecentMovements(tenantId, fincaId),
      this.getGenderSplit(tenantId, fincaId),
      this.getFinancesSummary(tenantId, fincaId),
      this.getTop5PotrerosActivos(tenantId, fincaId),
      this.getAllPotrerosWithOcupacion(tenantId, fincaId),
      this.getTrends(tenantId, fincaId),
    ]);

    return {
      demography,
      occupancy,
      critical_alerts: criticalAlerts,
      recent_movements: recentMovements,
      gender_split: genderSplit,
      finances_summary: financesSummary,
      top_potreros: topPotreros,
      all_potreros: allPotreros,
      trends,
    };
  }

  /**
   * TODOS los potreros del tenant con ocupación calculada.
   * Alimenta el grid visual "Mapa de la finca" en el dashboard.
   * Una sola query SQL con LEFT JOIN + COUNT (no N roundtrips).
   */
  private async getAllPotrerosWithOcupacion(tenantId: string, fincaId?: string) {
    const qb = this.potreroRepo
      .createQueryBuilder('p')
      .select([
        'p.pk_id_potrero AS pk_id_potrero',
        'p.nombre_potrero AS nombre_potrero',
        'p.area AS area',
        'p.capacidad_animales AS capacidad_animales',
        'p.estado AS estado',
      ])
      .addSelect('COUNT(b.id)', 'cantidad_animales')
      .leftJoin(
        'bovinos',
        'b',
        'b."potreroPkIdPotrero" = p.pk_id_potrero AND b.deleted_at IS NULL AND b.estado = \'activo\'',
      )
      .where('p.tenant_id = :tenantId', { tenantId })
      .andWhere('p.deleted_at IS NULL')
      .groupBy('p.pk_id_potrero')
      .orderBy('p.nombre_potrero', 'ASC');

    if (fincaId) {
      qb.andWhere('p.fk_id_finca = :fincaId', { fincaId });
    }

    const rows = await qb.getRawMany();

    return rows.map((r) => ({
      pk_id_potrero: r.pk_id_potrero,
      nombre_potrero: r.nombre_potrero,
      area: parseFloat(r.area) || 0,
      capacidad_animales: parseInt(r.capacidad_animales, 10) || 0,
      cantidad_animales: parseInt(r.cantidad_animales, 10) || 0,
      estado: r.estado || 'activo',
    }));
  }

  /**
   * Distribución por género — alimenta un donut macho/hembra en el Bento.
   */
  private async getGenderSplit(tenantId: string, fincaId?: string) {
    const qb = this.animalRepo
      .createQueryBuilder('a')
      .select("SUM(CASE WHEN a.genero = 'm' THEN 1 ELSE 0 END)", 'machos')
      .addSelect("SUM(CASE WHEN a.genero = 'h' THEN 1 ELSE 0 END)", 'hembras')
      .addSelect("SUM(CASE WHEN a.genero = 'n' THEN 1 ELSE 0 END)", 'otros')
      .addSelect('COUNT(*)', 'total')
      .where('a.tenant_id = :tenantId', { tenantId })
      .andWhere('a.deleted_at IS NULL')
      .andWhere("a.estado = 'activo'");

    if (fincaId) {
      qb.andWhere('a."fincaPkIdFinca" = :fincaId', { fincaId });
    }

    const result = await qb.getRawOne();

    return {
      machos: parseInt(result?.machos, 10) || 0,
      hembras: parseInt(result?.hembras, 10) || 0,
      otros: parseInt(result?.otros, 10) || 0,
      total: parseInt(result?.total, 10) || 0,
    };
  }

  /**
   * Resumen financiero — alimenta el bar chart ingresos vs gastos.
   */
  private async getFinancesSummary(tenantId: string, fincaId?: string) {
    const qb = this.finanzaRepo
      .createQueryBuilder('f')
      .select("COALESCE(SUM(CASE WHEN f.tipo_movimiento = 'ingreso' THEN f.monto ELSE 0 END), 0)", 'total_ingresos')
      .addSelect("COALESCE(SUM(CASE WHEN f.tipo_movimiento = 'gasto' THEN f.monto ELSE 0 END), 0)", 'total_gastos')
      .where('f.tenant_id = :tenantId', { tenantId })
      .andWhere('f.deleted_at IS NULL');

    if (fincaId) {
      qb.andWhere('f.fk_id_finca = :fincaId', { fincaId });
    }

    const result = await qb.getRawOne();

    const ingresos = parseFloat(result?.total_ingresos) || 0;
    const gastos = parseFloat(result?.total_gastos) || 0;

    return {
      total_ingresos: ingresos,
      total_gastos: gastos,
      balance: ingresos - gastos,
    };
  }

  /**
   * Distribución demográfica del hato usando el campo real
   * `etapa_productiva` de la entidad `Animal`.
   */
  private async getDemographyBreakdown(tenantId: string, fincaId?: string) {
    const qb = this.animalRepo
      .createQueryBuilder('a')
      .select('a.etapa_productiva', 'etapa')
      .addSelect('COUNT(*)', 'count')
      .where('a.tenant_id = :tenantId', { tenantId })
      .andWhere('a.deleted_at IS NULL')
      .andWhere("a.estado = 'activo'")
      .groupBy('a.etapa_productiva');

    if (fincaId) {
      qb.andWhere('a."fincaPkIdFinca" = :fincaId', { fincaId });
    }

    const rows = await qb.getRawMany();

    let produccion = 0;
    let crecimiento = 0;
    let secas = 0;
    let total = 0;

    for (const row of rows) {
      const count = parseInt(row.count, 10) || 0;
      total += count;
      switch (row.etapa) {
        case 'produccion':
          produccion = count;
          break;
        case 'crecimiento':
          crecimiento = count;
          break;
        case 'seca':
          secas = count;
          break;
      }
    }

    const pct = (n: number) => (total > 0 ? Math.round((n / total) * 100) : 0);

    return {
      produccion_pct: pct(produccion),
      crecimiento_pct: pct(crecimiento),
      secas_pct: pct(secas),
      total,
    };
  }

  /**
   * Ocupación del terreno:
   *   - total_hectares = suma del área de las fincas (filtradas si fincaId)
   *   - used_hectares  = suma del área de potreros con al menos un animal
   *                      activo (filtrados por finca si fincaId)
   */
  private async getOccupancyHectares(tenantId: string, fincaId?: string) {
    const totalQb = this.fincaRepo
      .createQueryBuilder('f')
      .select('COALESCE(SUM(f.area_total), 0)', 'total')
      .where('f.tenant_id = :tenantId', { tenantId })
      .andWhere('f.deleted_at IS NULL');
    if (fincaId) {
      totalQb.andWhere('f.pk_id_finca = :fincaId', { fincaId });
    }

    const usedQb = this.potreroRepo
      .createQueryBuilder('p')
      .select('COALESCE(SUM(p.area), 0)', 'total')
      .where('p.tenant_id = :tenantId', { tenantId })
      .andWhere('p.deleted_at IS NULL')
      .andWhere((qb) => {
        const sub = qb
          .subQuery()
          .select('1')
          .from('bovinos', 'b')
          .where('b."potreroPkIdPotrero" = p.pk_id_potrero')
          .andWhere('b.deleted_at IS NULL')
          .andWhere("b.estado = 'activo'")
          .getQuery();
        return `EXISTS ${sub}`;
      });
    if (fincaId) {
      usedQb.andWhere('p.fk_id_finca = :fincaId', { fincaId });
    }

    const [totalRow, usedRow] = await Promise.all([
      totalQb.getRawOne(),
      usedQb.getRawOne(),
    ]);

    return {
      total_hectares: Math.round(parseFloat(totalRow?.total) || 0),
      used_hectares: Math.round(parseFloat(usedRow?.total) || 0),
    };
  }

  /**
   * Alertas críticas de salud para mostrar en la card del BFF.
   * Cuando se filtra por finca, el join con `s.animal` se vuelve INNER
   * para descartar registros huérfanos (sin animal no hay finca).
   */
  private async getCriticalAlerts(tenantId: string, fincaId?: string) {
    const qb = this.saludRepo
      .createQueryBuilder('s')
      .select([
        's.id AS id',
        's.tipo_intervencion AS tipo_intervencion',
        's.producto_aplicado AS producto_aplicado',
        's.descripcion_enfermedad AS descripcion_enfermedad',
        's.fecha_proxima_aplicacion AS fecha_proxima_aplicacion',
        'a.numero_identificacion AS numero_identificacion',
      ])
      .where('s.tenant_id = :tenantId', { tenantId })
      .andWhere('s.deleted_at IS NULL')
      .andWhere('s.fecha_proxima_aplicacion IS NOT NULL')
      .andWhere(
        "s.fecha_proxima_aplicacion <= CURRENT_DATE + INTERVAL '7 days'",
      )
      .orderBy('s.fecha_proxima_aplicacion', 'ASC')
      .limit(5);

    if (fincaId) {
      qb.innerJoin('s.animal', 'a').andWhere(
        'a."fincaPkIdFinca" = :fincaId',
        { fincaId },
      );
    } else {
      qb.leftJoin('s.animal', 'a');
    }

    const rows = await qb.getRawMany();

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    return rows.map((r) => {
      const due = new Date(r.fecha_proxima_aplicacion);
      const isOverdue = due < today;
      const label =
        r.producto_aplicado || r.descripcion_enfermedad || 'Pendiente';
      const tipoCap = this.capitalize(r.tipo_intervencion ?? '');
      const numId = r.numero_identificacion ?? '—';
      return {
        id: String(r.id),
        animal_id: `Bovino #${numId}`,
        reason: isOverdue
          ? `${tipoCap}: ${label} (vencida)`
          : `${tipoCap}: ${label}`,
        urgency: isOverdue ? 'high' : 'medium',
      };
    });
  }

  /**
   * Últimos 5 movimientos entre potreros, con nombres de origen/destino
   * y hora legible. Si fincaId, filtra por la finca del potrero destino.
   */
  private async getRecentMovements(tenantId: string, fincaId?: string) {
    const qb = this.movimientoRepo
      .createQueryBuilder('m')
      .leftJoin('m.potreroOrigen', 'po')
      .leftJoin('m.potreroDestino', 'pd')
      .select([
        'm.id AS id',
        'm.created_at AS created_at',
        'po.nombre_potrero AS origen_nombre',
        'pd.nombre_potrero AS destino_nombre',
      ])
      .where('m.tenant_id = :tenantId', { tenantId })
      .andWhere('m.deleted_at IS NULL')
      .orderBy('m.created_at', 'DESC')
      .limit(5);

    if (fincaId) {
      qb.andWhere('pd.fk_id_finca = :fincaId', { fincaId });
    }

    const rows = await qb.getRawMany();

    return rows.map((r) => ({
      id: String(r.id),
      time: this.formatTime(r.created_at),
      origin: r.origen_nombre ?? '—',
      destination: r.destino_nombre ?? '—',
    }));
  }

  private capitalize(s: string): string {
    if (!s) return '';
    return s.charAt(0).toUpperCase() + s.slice(1);
  }

  private formatTime(raw: Date | string | null): string {
    if (!raw) return '—';
    const d = raw instanceof Date ? raw : new Date(raw);
    return d.toLocaleTimeString('es-CO', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true,
    });
  }

  /**
   * Tendencias semanales de los últimos 30 días para sparklines.
   * Si fincaId, todas las series se filtran por finca correspondiente.
   */
  private async getTrends(tenantId: string, fincaId?: string) {
    const params: unknown[] = fincaId ? [tenantId, fincaId] : [tenantId];
    const bovinosFincaFilter = fincaId ? 'AND b."fincaPkIdFinca" = $2' : '';
    const finanzasFincaFilter = fincaId ? 'AND fk_id_finca = $2' : '';

    const [animales, ingresos, gastos, salud] = await Promise.all([
      this.dataSource.query(
        `SELECT date_trunc('week', b.created_at) AS week, COUNT(*) AS count
         FROM bovinos b
         WHERE b.tenant_id = $1 AND b.deleted_at IS NULL
           ${bovinosFincaFilter}
           AND b.created_at >= CURRENT_DATE - INTERVAL '30 days'
         GROUP BY week ORDER BY week`,
        params,
      ),
      this.dataSource.query(
        `SELECT date_trunc('week', fecha) AS week, COALESCE(SUM(monto), 0) AS total
         FROM finanzas
         WHERE tenant_id = $1 AND deleted_at IS NULL AND tipo_movimiento = 'ingreso'
           ${finanzasFincaFilter}
           AND fecha >= CURRENT_DATE - INTERVAL '30 days'
         GROUP BY week ORDER BY week`,
        params,
      ),
      this.dataSource.query(
        `SELECT date_trunc('week', fecha) AS week, COALESCE(SUM(monto), 0) AS total
         FROM finanzas
         WHERE tenant_id = $1 AND deleted_at IS NULL AND tipo_movimiento = 'gasto'
           ${finanzasFincaFilter}
           AND fecha >= CURRENT_DATE - INTERVAL '30 days'
         GROUP BY week ORDER BY week`,
        params,
      ),
      this.dataSource.query(
        `SELECT date_trunc('week', s.fecha_aplicacion) AS week, COUNT(*) AS count
         FROM salud s
         INNER JOIN bovinos b
           ON b.id = s.fk_id_bovino
          AND b.tenant_id = $1
          AND b.deleted_at IS NULL
         WHERE s.tenant_id = $1 AND s.deleted_at IS NULL
           ${bovinosFincaFilter}
           AND s.fecha_aplicacion >= CURRENT_DATE - INTERVAL '30 days'
         GROUP BY week ORDER BY week`,
        params,
      ),
    ]);

    const mapWeekly = (rows: any[], field = 'count') =>
      rows.map((r: any) => ({
        week: r.week,
        value: parseFloat(r[field]) || parseInt(r[field], 10) || 0,
      }));

    return {
      animales: mapWeekly(animales),
      ingresos: mapWeekly(ingresos, 'total'),
      gastos: mapWeekly(gastos, 'total'),
      salud: mapWeekly(salud),
    };
  }
}
