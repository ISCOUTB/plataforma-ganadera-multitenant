import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { Animal } from '../animales/entities/animal.entity';
import { Finca } from '../fincas/entities/finca.entity';
import { Potrero } from '../potreros/entities/potrero.entity';
import { Salud } from '../salud/entities/salud.entity';
import { Finanza } from '../finanzas/entities/finanza.entity';
import { Reproduccion } from '../reproduccion/entities/reproduccion.entity';

@Injectable()
export class DashboardService {
  constructor(
    @InjectRepository(Animal) private readonly animalRepo: Repository<Animal>,
    @InjectRepository(Finca) private readonly fincaRepo: Repository<Finca>,
    @InjectRepository(Potrero) private readonly potreroRepo: Repository<Potrero>,
    @InjectRepository(Salud) private readonly saludRepo: Repository<Salud>,
    @InjectRepository(Finanza) private readonly finanzaRepo: Repository<Finanza>,
    @InjectRepository(Reproduccion) private readonly reproduccionRepo: Repository<Reproduccion>,
    private readonly dataSource: DataSource,
  ) {}

  async getMetrics(tenantId: string) {
    const [
      inventario,
      finanzas,
      alertas,
      costoTotal,
      top5Costosos,
      top5Potreros,
      animalesSinPotrero,
      estimacionGanancia,
    ] = await Promise.all([
      this.getInventarioMetrics(tenantId),
      this.getFinanzasMetrics(tenantId),
      this.getAlertasMetrics(tenantId),
      this.getCostoTotalAnimales(tenantId),
      this.getTop5AnimalesCostosos(tenantId),
      this.getTop5PotrerosActivos(tenantId),
      this.getAnimalesSinPotrero(tenantId),
      this.getEstimacionGanancia(tenantId),
    ]);

    return {
      inventario,
      finanzas,
      alertas_pendientes: alertas,
      inteligencia: {
        costo_total_animales: costoTotal,
        top_5_animales_costosos: top5Costosos,
        top_5_potreros_activos: top5Potreros,
        animales_sin_potrero: animalesSinPotrero,
        estimacion_ganancia: estimacionGanancia,
      },
    };
  }

  private async getInventarioMetrics(tenantId: string) {
    const result = await this.animalRepo
      .createQueryBuilder('a')
      .select('COUNT(*)', 'total_animales')
      .addSelect("SUM(CASE WHEN a.genero = 'm' THEN 1 ELSE 0 END)", 'machos')
      .addSelect("SUM(CASE WHEN a.genero = 'h' THEN 1 ELSE 0 END)", 'hembras')
      .where('a.tenant_id = :tenantId', { tenantId })
      .andWhere('a.deleted_at IS NULL')
      .getRawOne();

    const [totalFincas, totalPotreros] = await Promise.all([
      this.fincaRepo.createQueryBuilder('f')
        .where('f.tenant_id = :tenantId', { tenantId })
        .andWhere('f.deleted_at IS NULL')
        .getCount(),
      this.potreroRepo.createQueryBuilder('p')
        .where('p.tenant_id = :tenantId', { tenantId })
        .andWhere('p.deleted_at IS NULL')
        .getCount(),
    ]);

    return {
      total_animales: parseInt(result.total_animales, 10) || 0,
      machos: parseInt(result.machos, 10) || 0,
      hembras: parseInt(result.hembras, 10) || 0,
      total_fincas: totalFincas,
      total_potreros: totalPotreros,
    };
  }

  private async getFinanzasMetrics(tenantId: string) {
    const result = await this.finanzaRepo
      .createQueryBuilder('f')
      .select("COALESCE(SUM(CASE WHEN f.tipo_movimiento = 'ingreso' THEN f.monto ELSE 0 END), 0)", 'total_ingresos')
      .addSelect("COALESCE(SUM(CASE WHEN f.tipo_movimiento = 'gasto' THEN f.monto ELSE 0 END), 0)", 'total_gastos')
      .where('f.tenant_id = :tenantId', { tenantId })
      .andWhere('f.deleted_at IS NULL')
      .getRawOne();

    const total_ingresos = parseFloat(result.total_ingresos) || 0;
    const total_gastos = parseFloat(result.total_gastos) || 0;

    return {
      total_ingresos,
      total_gastos,
      balance: total_ingresos - total_gastos,
    };
  }

  private async getAlertasMetrics(tenantId: string) {
    const en7dias = new Date();
    en7dias.setDate(en7dias.getDate() + 7);

    const [saludProximas, vacasPreñadas] = await Promise.all([
      this.saludRepo
        .createQueryBuilder('s')
        .where('s.tenant_id = :tenantId', { tenantId })
        .andWhere('s.deleted_at IS NULL')
        .andWhere('s.fecha_proxima_aplicacion <= :fecha', { fecha: en7dias })
        .getCount(),
      this.reproduccionRepo
        .createQueryBuilder('r')
        .where('r.tenant_id = :tenantId', { tenantId })
        .andWhere('r.deleted_at IS NULL')
        .andWhere('r.preñada = true')
        .getCount(),
    ]);

    return {
      salud_proxima_7_dias: saludProximas,
      vacas_preñadas: vacasPreñadas,
    };
  }

  private async getCostoTotalAnimales(tenantId: string) {
    const [saludResult, alimentacionResult] = await Promise.all([
      this.dataSource
        .createQueryBuilder()
        .select('COALESCE(SUM(COALESCE(s.costo, 0)), 0)', 'total')
        .from('salud', 's')
        .where('s.tenant_id = :tenantId', { tenantId })
        .andWhere('s.deleted_at IS NULL')
        .getRawOne(),

      this.dataSource
        .createQueryBuilder()
        .select(
          `COALESCE(SUM(
            CASE WHEN a.cantidad_total IS NOT NULL AND a.cantidad_total > 0 AND a.costo IS NOT NULL
            THEN (ba.cantidad / a.cantidad_total) * a.costo ELSE 0 END
          ), 0)`,
          'total',
        )
        .from('bovino_alimento', 'ba')
        .innerJoin('alimento', 'a', 'a.pk_id_alimento = ba.fk_id_alimento')
        .where('ba.tenant_id = :tenantId', { tenantId })
        .andWhere('a.deleted_at IS NULL')
        .getRawOne(),
    ]);

    const costo_salud = parseFloat(saludResult?.total) || 0;
    const costo_alimentacion = parseFloat(alimentacionResult?.total) || 0;

    return {
      costo_salud,
      costo_alimentacion,
      costo_total: costo_salud + costo_alimentacion,
    };
  }

  private async getTop5AnimalesCostosos(tenantId: string) {
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
        INNER JOIN alimento a ON a.pk_id_alimento = ba.fk_id_alimento AND a.deleted_at IS NULL
        WHERE ba.tenant_id = $1
        GROUP BY ba.fk_id_bovino
      ) fc ON fc.fk_id_bovino = b.id
      WHERE b.tenant_id = $1 AND b.deleted_at IS NULL
      ORDER BY costo_total DESC
      LIMIT 5`,
      [tenantId],
    );

    return results.map((r: any) => ({
      id: r.id,
      numero_identificacion: r.numero_identificacion,
      costo_total: parseFloat(r.costo_total) || 0,
      costo_salud: parseFloat(r.costo_salud) || 0,
      costo_alimentacion: parseFloat(r.costo_alimentacion) || 0,
    }));
  }

  private async getTop5PotrerosActivos(tenantId: string) {
    const results = await this.potreroRepo
      .createQueryBuilder('p')
      .leftJoin('p.animales', 'a', 'a.deleted_at IS NULL')
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
      .limit(5)
      .getRawMany();

    return results.map((r: any) => ({
      pk_id_potrero: r.pk_id_potrero,
      nombre_potrero: r.nombre_potrero,
      capacidad_animales: parseInt(r.capacidad_animales, 10) || 0,
      cantidad_animales: parseInt(r.cantidad_animales, 10) || 0,
    }));
  }

  private async getAnimalesSinPotrero(tenantId: string): Promise<number> {
    return this.animalRepo
      .createQueryBuilder('a')
      .where('a.tenant_id = :tenantId', { tenantId })
      .andWhere('a.deleted_at IS NULL')
      .andWhere('a.potrero IS NULL')
      .getCount();
  }

  /**
   * Estimación de ganancia: SOLO animales vendidos.
   * Revenue = SUM(precio_venta) de vendidos
   * Costs = salud + alimentación de vendidos solamente
   */
  private async getEstimacionGanancia(tenantId: string) {
    const [ventasResult, costoSaludResult, costoAlimentacionResult] = await Promise.all([
      // Revenue from sold animals
      this.animalRepo
        .createQueryBuilder('b')
        .select('COALESCE(SUM(b.precio_venta), 0)', 'total_ventas')
        .addSelect('COUNT(*)', 'animales_vendidos')
        .where('b.tenant_id = :tenantId', { tenantId })
        .andWhere('b.deleted_at IS NULL')
        .andWhere("b.estado = 'vendido'")
        .getRawOne(),

      // Health costs of SOLD animals only
      this.dataSource
        .createQueryBuilder()
        .select('COALESCE(SUM(COALESCE(s.costo, 0)), 0)', 'total')
        .from('salud', 's')
        .innerJoin('bovinos', 'b', 'b.id = s.fk_id_bovino')
        .where('s.tenant_id = :tenantId', { tenantId })
        .andWhere('s.deleted_at IS NULL')
        .andWhere("b.estado = 'vendido'")
        .andWhere('b.deleted_at IS NULL')
        .getRawOne(),

      // Feeding costs of SOLD animals only
      this.dataSource
        .createQueryBuilder()
        .select(
          `COALESCE(SUM(
            CASE WHEN a.cantidad_total IS NOT NULL AND a.cantidad_total > 0 AND a.costo IS NOT NULL
            THEN (ba.cantidad / a.cantidad_total) * a.costo ELSE 0 END
          ), 0)`,
          'total',
        )
        .from('bovino_alimento', 'ba')
        .innerJoin('alimento', 'a', 'a.pk_id_alimento = ba.fk_id_alimento AND a.deleted_at IS NULL')
        .innerJoin('bovinos', 'b', 'b.id = ba.fk_id_bovino')
        .where('ba.tenant_id = :tenantId', { tenantId })
        .andWhere("b.estado = 'vendido'")
        .andWhere('b.deleted_at IS NULL')
        .getRawOne(),
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
}
