import {
  Injectable,
  NotFoundException,
  BadRequestException,
  OnModuleInit,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource, IsNull } from 'typeorm';
import { Animal, EstadoAnimal, EtapaProductiva } from './entities/animal.entity';
import { Finca } from '../fincas/entities/finca.entity';
import { Potrero } from '../potreros/entities/potrero.entity';
import { Finanza } from '../finanzas/entities/finanza.entity';
import { BaseRepository } from '../common/repositories/base.repository';
import { CreateAnimalDto } from './dto/create-animal.dto';
import { UpdateAnimalDto } from './dto/update-animal.dto';
import { VenderAnimalDto } from './dto/vender-animal.dto';
import { FilterAnimalesDto } from './dto/filter-animales.dto';
import { PaginatedResult } from '../common/interfaces/paginated-result.interface';

@Injectable()
export class AnimalesService implements OnModuleInit {
  private readonly logger = new Logger(AnimalesService.name);
  protected baseRepo: BaseRepository<Animal>;

  constructor(
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
    @InjectRepository(Finca)
    private readonly fincaRepository: Repository<Finca>,
    @InjectRepository(Potrero)
    private readonly potreroRepository: Repository<Potrero>,
    private readonly dataSource: DataSource,
  ) {
    this.baseRepo = new BaseRepository(animalRepository);
  }

  /**
   * Backfill one-shot de `etapa_productiva` para registros legacy.
   * Corre al arrancar el módulo y sólo actualiza filas con valor
   * `sin_clasificar` — idempotente. Una sola query SQL clasifica todo
   * el hato histórico aplicando la misma heurística que usa `create()`.
   */
  async onModuleInit(): Promise<void> {
    // Los literales se castean al tipo enum de Postgres
    // (`bovinos_etapa_productiva_enum`) para evitar
    // `column is of type enum but expression is of type text`.
    const result = await this.animalRepository.query(`
      UPDATE bovinos
      SET etapa_productiva = CASE
        WHEN fecha_nacimiento > CURRENT_DATE - INTERVAL '2 years'
          THEN 'crecimiento'::bovinos_etapa_productiva_enum
        WHEN genero = 'h'
          THEN 'produccion'::bovinos_etapa_productiva_enum
        ELSE 'seca'::bovinos_etapa_productiva_enum
      END
      WHERE etapa_productiva = 'sin_clasificar'::bovinos_etapa_productiva_enum
        AND deleted_at IS NULL
    `);
    // PG driver devuelve [rows, rowCount] en `query()`
    const affected = Array.isArray(result) ? result[1] : 0;
    if (affected && affected > 0) {
      this.logger.log(
        `Backfill etapa_productiva: ${affected} animales clasificados`,
      );
    }
  }

  async create(dto: CreateAnimalDto, tenantId: string, userId: number): Promise<Animal> {
    await this.validateFkReferences(dto, tenantId);
    // Auto-clasifica la etapa productiva si el cliente no la envía.
    if (!dto.etapa_productiva) {
      dto.etapa_productiva = this.inferEtapa(dto.genero, dto.fecha_nacimiento);
    }
    // TypeORM no mapea `fincaId`/`potreroId` planos a las relaciones @ManyToOne.
    // Debemos transformarlos en objetos parciales que TypeORM reconoce como FK.
    const payload = this.toEntityPayload(dto);
    return this.baseRepo.createWithTenant(payload as any, tenantId, userId);
  }

  /**
   * Heurística de clasificación automática — se aplica cuando el
   * cliente no especifica `etapa_productiva` en el DTO. Refleja la
   * convención ganadera estándar usada por el BFF.
   */
  private inferEtapa(
    genero: string,
    fechaNacimiento: Date | string,
  ): EtapaProductiva {
    const birth = new Date(fechaNacimiento);
    const ageMs = Date.now() - birth.getTime();
    const ageYears = ageMs / (1000 * 60 * 60 * 24 * 365.25);
    if (ageYears < 2) return EtapaProductiva.CRECIMIENTO;
    if (genero === 'h') return EtapaProductiva.PRODUCCION;
    return EtapaProductiva.SECA;
  }

  findAll(tenantId: string): Promise<Animal[]> {
    return this.baseRepo.findAll(tenantId);
  }

  findAllPaginated(
    tenantId: string,
    filters: FilterAnimalesDto,
  ): Promise<PaginatedResult<Animal>> {
    const { page, limit, sortBy, sortOrder, raza, genero, estado, fincaId } = filters;
    const extraWhere: any = {};
    if (raza) extraWhere.raza = raza;
    if (genero) extraWhere.genero = genero;
    if (estado) extraWhere.estado = estado;
    // TypeORM mapea filtros sobre relaciones con FindOptionsWhere anidado.
    if (fincaId) extraWhere.finca = { pk_id_finca: fincaId };
    return this.baseRepo.findAllPaginated(
      tenantId,
      { page, limit, sortBy, sortOrder },
      extraWhere,
    );
  }

  async findOne(id: number, tenantId: string): Promise<Animal> {
    const animal = await this.baseRepo.findOneByIdWithRelations(
      id, tenantId, ['finca', 'potrero'],
    );
    if (!animal) {
      throw new NotFoundException(`Animal #${id} no encontrado`);
    }
    return animal;
  }

  async update(
    id: number,
    dto: UpdateAnimalDto,
    tenantId: string,
    userId: number,
  ): Promise<Animal> {
    await this.findOne(id, tenantId);
    if ((dto as any).fincaId || (dto as any).potreroId) {
      await this.validateFkReferences(dto as any, tenantId);
    }
    const payload = this.toEntityPayload(dto as any);
    const updated = await this.baseRepo.updateWithTenant(id, payload as any, tenantId, userId);
    if (!updated) throw new NotFoundException(`Animal #${id} no encontrado`);
    return updated;
  }

  /**
   * Transforma un DTO con `fincaId`/`potreroId` planos en un payload
   * que TypeORM mapea correctamente a las relaciones @ManyToOne.
   *
   * Sin esta transformación los FK strings se ignoran en `repo.save()` y
   * los animales quedan huérfanos (problema reportado por el dashboard
   * como `animales_sin_potrero`).
   */
  private toEntityPayload(dto: { fincaId?: string; potreroId?: string } & Record<string, any>): any {
    const { fincaId, potreroId, ...rest } = dto;
    const payload: any = { ...rest };
    if (fincaId !== undefined) {
      payload.finca = fincaId ? { pk_id_finca: fincaId } : null;
    }
    if (potreroId !== undefined) {
      payload.potrero = potreroId ? { pk_id_potrero: potreroId } : null;
    }
    return payload;
  }

  async remove(id: number, tenantId: string): Promise<{ message: string }> {
    await this.findOne(id, tenantId);
    await this.baseRepo.softDelete(id, tenantId);
    return { message: `Animal #${id} eliminado correctamente` };
  }

  /**
   * Costos acumulados de un animal: salud + alimentación.
   * Usa SQL aggregation para eficiencia.
   */
  async getCostos(animalId: number, tenantId: string): Promise<{
    animal_id: number;
    costo_salud: number;
    costo_alimentacion: number;
    costo_total: number;
  }> {
    await this.findOne(animalId, tenantId);

    const [saludResult, alimentacionResult] = await Promise.all([
      this.dataSource
        .createQueryBuilder()
        .select('COALESCE(SUM(COALESCE(s.costo, 0)), 0)', 'total')
        .from('salud', 's')
        .where('s.fk_id_bovino = :animalId', { animalId })
        .andWhere('s.tenant_id = :tenantId', { tenantId })
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
        .where('ba.fk_id_bovino = :animalId', { animalId })
        .andWhere('ba.tenant_id = :tenantId', { tenantId })
        .andWhere('a.deleted_at IS NULL')
        .getRawOne(),
    ]);

    const costo_salud = parseFloat(saludResult?.total) || 0;
    const costo_alimentacion = parseFloat(alimentacionResult?.total) || 0;

    return {
      animal_id: animalId,
      costo_salud,
      costo_alimentacion,
      costo_total: costo_salud + costo_alimentacion,
    };
  }

  /**
   * Registrar venta de un animal.
   * - Valida: no soft-deleted, no ya vendido
   * - Marca estado=vendido, registra precio_venta, comprador, fecha_salida
   * - Crea Finanza de ingreso automáticamente
   * - TODO dentro de una única transacción con manager
   */
  async vender(
    animalId: number,
    dto: VenderAnimalDto,
    tenantId: string,
    userId: number,
  ): Promise<{ animal: Animal; finanza: Finanza }> {
    return this.dataSource.transaction(async (manager) => {
      // 1. Load animal via manager (not external repository)
      const animal = await manager.findOne(Animal, {
        where: { id: animalId, tenant_id: tenantId, deleted_at: IsNull() },
        relations: ['finca', 'potrero'],
      });

      // 2. Validate: exists (deleted_at IS NULL already enforced above)
      if (!animal) {
        throw new NotFoundException(`Animal #${animalId} no encontrado`);
      }

      // 3. Validate: not already sold
      if (animal.estado === EstadoAnimal.VENDIDO) {
        throw new BadRequestException(`Animal #${animalId} ya fue vendido`);
      }

      // 4. Update animal via manager
      await manager.update(
        Animal,
        { id: animalId, tenant_id: tenantId },
        {
          estado: EstadoAnimal.VENDIDO,
          precio_venta: dto.precio_venta,
          comprador: dto.comprador ?? null,
          fecha_salida: dto.fecha_venta,
          updated_by: userId,
        } as any,
      );

      // 5. Generate Finanza PK (max 15 chars)
      const finanzaId = `VTA${animalId}T${Date.now() % 1e8}`.substring(0, 15);

      // 6. Create Finanza record via manager
      const finanza = manager.create(Finanza, {
        pk_id_finanza: finanzaId,
        tipo_movimiento: 'ingreso',
        concepto: `Venta animal #${animalId} (${animal.numero_identificacion})`,
        categoria: 'venta_ganado',
        monto: dto.precio_venta,
        fecha: dto.fecha_venta,
        tenant_id: tenantId,
        created_by: userId,
        updated_by: userId,
        finca: animal.finca ?? (dto.fincaId ? ({ pk_id_finca: dto.fincaId } as any) : null),
        animal: { id: animalId } as any,
      } as any);
      await manager.save(Finanza, finanza);

      // 7. Reload updated animal via manager
      const updatedAnimal = await manager.findOne(Animal, {
        where: { id: animalId, tenant_id: tenantId },
        relations: ['finca', 'potrero'],
      });

      return { animal: updatedAnimal!, finanza };
    });
  }

  private async validateFkReferences(
    dto: { fincaId?: string; potreroId?: string },
    tenantId: string,
  ): Promise<void> {
    if (dto.fincaId) {
      const finca = await this.fincaRepository.findOne({
        where: { pk_id_finca: dto.fincaId, tenant_id: tenantId, deleted_at: IsNull() },
      });
      if (!finca) throw new BadRequestException(`Finca "${dto.fincaId}" no encontrada en este tenant`);
    }
    if (dto.potreroId) {
      const potrero = await this.potreroRepository.findOne({
        where: { pk_id_potrero: dto.potreroId, tenant_id: tenantId, deleted_at: IsNull() },
      });
      if (!potrero) throw new BadRequestException(`Potrero "${dto.potreroId}" no encontrado en este tenant`);
    }
  }

  /**
   * Timeline cronológico de un animal: agrega eventos de salud,
   * movimientos entre potreros y movimientos financieros en una sola
   * lista ordenada por fecha DESC. Cada evento tiene un `type` y
   * `description` genéricos para que el frontend los renderice en
   * una línea de tiempo unificada.
   */
  async getTimeline(
    animalId: number,
    tenantId: string,
  ): Promise<{ type: string; date: string; description: string; metadata: any }[]> {
    await this.findOne(animalId, tenantId);

    const [saludEvents, movimientoEvents, finanzaEvents] = await Promise.all([
      // Eventos de salud
      this.dataSource.query(
        `SELECT 'salud' AS type,
                COALESCE(fecha_aplicacion, created_at)::text AS date,
                CONCAT(tipo_intervencion, ': ', COALESCE(producto_aplicado, descripcion_enfermedad, 'Sin detalle')) AS description,
                json_build_object('id', id, 'tipo', tipo_intervencion, 'producto', producto_aplicado, 'costo', costo) AS metadata
         FROM salud
         WHERE fk_id_bovino = $1 AND tenant_id = $2 AND deleted_at IS NULL
         ORDER BY COALESCE(fecha_aplicacion, created_at) DESC`,
        [animalId, tenantId],
      ),
      // Movimientos entre potreros
      this.dataSource.query(
        `SELECT 'movimiento' AS type,
                m.fecha::text AS date,
                CONCAT('Traslado: ', COALESCE(po.nombre_potrero, '—'), ' → ', COALESCE(pd.nombre_potrero, '—')) AS description,
                json_build_object('id', m.id, 'motivo', m.motivo, 'origen', po.nombre_potrero, 'destino', pd.nombre_potrero) AS metadata
         FROM movimientos_animal m
         LEFT JOIN potreros po ON po.pk_id_potrero = m.fk_potrero_origen
         LEFT JOIN potreros pd ON pd.pk_id_potrero = m.fk_potrero_destino
         WHERE m.fk_id_bovino = $1 AND m.tenant_id = $2 AND m.deleted_at IS NULL
         ORDER BY m.fecha DESC`,
        [animalId, tenantId],
      ),
      // Movimientos financieros asociados
      this.dataSource.query(
        `SELECT 'finanza' AS type,
                COALESCE(fecha, creado_en)::text AS date,
                CONCAT(tipo_movimiento, ': ', concepto, ' ($', monto, ')') AS description,
                json_build_object('id', pk_id_finanza, 'tipo', tipo_movimiento, 'monto', monto, 'concepto', concepto) AS metadata
         FROM finanzas
         WHERE fk_id_bovino = $1 AND tenant_id = $2 AND deleted_at IS NULL
         ORDER BY COALESCE(fecha, creado_en) DESC`,
        [animalId, tenantId],
      ),
    ]);

    // Unir y ordenar por fecha DESC
    const all = [
      ...saludEvents,
      ...movimientoEvents,
      ...finanzaEvents,
    ];

    all.sort((a: any, b: any) => {
      const da = new Date(a.date).getTime();
      const db = new Date(b.date).getTime();
      return db - da;
    });

    return all;
  }
}
