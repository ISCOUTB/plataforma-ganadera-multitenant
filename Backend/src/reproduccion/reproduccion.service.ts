import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, IsNull } from 'typeorm';
import { Reproduccion } from './entities/reproduccion.entity';
import { BaseRepository } from '../common/repositories/base.repository';
import { CreateReproduccionDto } from './dto/create-reproduccion.dto';
import { UpdateReproduccionDto } from './dto/update-reproduccion.dto';
import { FilterReproduccionDto } from './dto/filter-reproduccion.dto';
import { PaginatedResult } from '../common/interfaces/paginated-result.interface';

@Injectable()
export class ReproduccionService {
  protected baseRepo: BaseRepository<Reproduccion>;

  constructor(
    @InjectRepository(Reproduccion)
    private readonly reproduccionRepository: Repository<Reproduccion>,
  ) {
    this.baseRepo = new BaseRepository(reproduccionRepository);
  }

  create(dto: CreateReproduccionDto, tenantId: string, userId: number): Promise<Reproduccion> {
    return this.baseRepo.createWithTenant(dto as any, tenantId, userId);
  }

  findAll(tenantId: string): Promise<Reproduccion[]> {
    return this.baseRepo.findAll(tenantId);
  }

  findAllPaginated(
    tenantId: string,
    filters: FilterReproduccionDto,
  ): Promise<PaginatedResult<Reproduccion>> {
    const { page, limit, sortBy, sortOrder, prepiada, en_celo, fincaId } =
      filters;
    // Cuando NO se pide filtro por finca conservamos el path optimizado
    // de baseRepo (sin JOIN). El filtro por finca requiere JOIN con bovino.
    if (fincaId) {
      return this.findAllPaginatedByFinca(tenantId, filters);
    }
    const extraWhere: any = {};
    if (prepiada !== undefined) extraWhere.preñada = prepiada;
    if (en_celo !== undefined) extraWhere.en_celo = en_celo;
    return this.baseRepo.findAllPaginated(
      tenantId,
      { page, limit, sortBy, sortOrder },
      extraWhere,
    );
  }

  private async findAllPaginatedByFinca(
    tenantId: string,
    filters: FilterReproduccionDto,
  ): Promise<PaginatedResult<Reproduccion>> {
    const pageNum = Math.max(filters.page ?? 1, 1);
    const limitNum = Math.min(Math.max(filters.limit ?? 10, 1), 100);
    const qb = this.reproduccionRepository
      .createQueryBuilder('r')
      .innerJoin('r.bovino', 'b')
      .where('r.tenant_id = :tenantId', { tenantId })
      .andWhere('r.deleted_at IS NULL')
      .andWhere('b."fincaPkIdFinca" = :fincaId', { fincaId: filters.fincaId });
    if (filters.prepiada !== undefined) {
      qb.andWhere('r."preñada" = :prepiada', { prepiada: filters.prepiada });
    }
    if (filters.en_celo !== undefined) {
      qb.andWhere('r.en_celo = :enCelo', { enCelo: filters.en_celo });
    }
    if (filters.sortBy) {
      qb.orderBy(`r.${filters.sortBy}`, filters.sortOrder ?? 'ASC');
    }
    qb.skip((pageNum - 1) * limitNum).take(limitNum);
    const [data, total] = await qb.getManyAndCount();
    return {
      data,
      total,
      page: pageNum,
      lastPage: Math.ceil(total / limitNum) || 1,
    };
  }

  async findOne(id: string, tenantId: string): Promise<Reproduccion> {
    const registro = await this.baseRepo.findOneByIdWithRelations(id, tenantId, ['bovino']);
    if (!registro) throw new NotFoundException(`Reproduccion "${id}" no encontrada`);
    return registro;
  }

  async update(id: string, dto: UpdateReproduccionDto, tenantId: string, userId: number): Promise<Reproduccion> {
    await this.findOne(id, tenantId);
    const updated = await this.baseRepo.updateWithTenant(id, dto as any, tenantId, userId);
    if (!updated) throw new NotFoundException(`Reproduccion "${id}" no encontrada`);
    return updated;
  }

  async remove(id: string, tenantId: string): Promise<{ message: string }> {
    await this.findOne(id, tenantId);
    await this.baseRepo.softDelete(id, tenantId);
    return { message: `Reproduccion "${id}" eliminada correctamente` };
  }

  /**
   * Alertas reproductivas: partos próximos (30 días) y vacas en celo.
   * Ayuda al ganadero a planificar asistencia de partos y programar montas/inseminación.
   */
  async getAlertas(tenantId: string): Promise<{
    partos_proximos: Reproduccion[];
    en_celo: Reproduccion[];
    partos_vencidos: Reproduccion[];
  }> {
    const hoy = new Date();
    const en30dias = new Date();
    en30dias.setDate(hoy.getDate() + 30);

    // Vacas preñadas con parto próximo
    const preñadas = await this.reproduccionRepository.find({
      where: {
        tenant_id: tenantId,
        deleted_at: IsNull(),
        preñada: true,
        fecha_estimado_parto: LessThanOrEqual(en30dias),
      },
      relations: ['bovino'],
      order: { fecha_estimado_parto: 'ASC' },
    });

    const partos_vencidos = preñadas.filter(
      (r) => r.fecha_estimado_parto && new Date(r.fecha_estimado_parto) < hoy,
    );
    const partos_proximos = preñadas.filter(
      (r) => r.fecha_estimado_parto && new Date(r.fecha_estimado_parto) >= hoy,
    );

    // Vacas en celo — ventana de oportunidad para inseminación
    const en_celo = await this.reproduccionRepository.find({
      where: {
        tenant_id: tenantId,
        deleted_at: IsNull(),
        en_celo: true,
      },
      relations: ['bovino'],
    });

    return { partos_proximos, en_celo, partos_vencidos };
  }
}
