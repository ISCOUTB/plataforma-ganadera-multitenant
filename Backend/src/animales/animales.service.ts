import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource, IsNull } from 'typeorm';
import { Animal, EstadoAnimal } from './entities/animal.entity';
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
export class AnimalesService {
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

  async create(dto: CreateAnimalDto, tenantId: string, userId: number): Promise<Animal> {
    await this.validateFkReferences(dto, tenantId);
    return this.baseRepo.createWithTenant(dto as any, tenantId, userId);
  }

  findAll(tenantId: string): Promise<Animal[]> {
    return this.baseRepo.findAll(tenantId);
  }

  findAllPaginated(
    tenantId: string,
    filters: FilterAnimalesDto,
  ): Promise<PaginatedResult<Animal>> {
    const { page, limit, sortBy, sortOrder, raza, genero, estado } = filters;
    const extraWhere: any = {};
    if (raza) extraWhere.raza = raza;
    if (genero) extraWhere.genero = genero;
    if (estado) extraWhere.estado = estado;
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
    const updated = await this.baseRepo.updateWithTenant(id, dto as any, tenantId, userId);
    if (!updated) throw new NotFoundException(`Animal #${id} no encontrado`);
    return updated;
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
}
