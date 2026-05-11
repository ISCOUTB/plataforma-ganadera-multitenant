import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Potrero } from './entities/potrero.entity';
import { Animal, EstadoAnimal } from '../animales/entities/animal.entity';
import { Finca } from '../fincas/entities/finca.entity';
import { BaseRepository } from '../common/repositories/base.repository';
import { CreatePotreroDto } from './dto/create-potrero.dto';
import { UpdatePotreroDto } from './dto/update-potrero.dto';
import { FilterPotrerosDto } from './dto/filter-potreros.dto';
import { PaginatedResult } from '../common/interfaces/paginated-result.interface';

@Injectable()
export class PotrerosService {
  protected baseRepo: BaseRepository<Potrero>;

  constructor(
    @InjectRepository(Potrero)
    private readonly potreroRepository: Repository<Potrero>,
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
    @InjectRepository(Finca)
    private readonly fincaRepository: Repository<Finca>,
  ) {
    this.baseRepo = new BaseRepository(potreroRepository);
  }

  async create(
    dto: CreatePotreroDto,
    tenantId: string,
    userId: number,
  ): Promise<Potrero> {
    if (dto.fincaId) {
      const finca = await this.fincaRepository.findOne({
        where: { pk_id_finca: dto.fincaId, tenant_id: tenantId, deleted_at: IsNull() },
      });
      if (!finca) throw new BadRequestException(`Finca "${dto.fincaId}" no encontrada en este tenant`);
    }
    const payload = this.toEntityPayload(dto);
    return this.baseRepo.createWithTenant(payload as any, tenantId, userId);
  }

  findAll(tenantId: string): Promise<Potrero[]> {
    return this.baseRepo.findAll(tenantId);
  }

  findAllPaginated(
    tenantId: string,
    filters: FilterPotrerosDto,
  ): Promise<PaginatedResult<Potrero>> {
    const { page, limit, sortBy, sortOrder, estado, fincaId } = filters;
    const extraWhere: any = {};
    if (estado) extraWhere.estado = estado;
    if (fincaId) extraWhere.finca = { pk_id_finca: fincaId };
    return this.baseRepo.findAllPaginated(
      tenantId,
      { page, limit, sortBy, sortOrder },
      extraWhere,
    );
  }

  async findOne(id: string, tenantId: string): Promise<Potrero> {
    const potrero = await this.baseRepo.findOneByIdWithRelations(
      id, tenantId, ['finca', 'animales'],
    );
    if (!potrero) {
      throw new NotFoundException(`Potrero "${id}" no encontrado`);
    }
    return potrero;
  }

  async getOccupancy(potreroId: string, tenantId: string) {
    const potrero = await this.findOne(potreroId, tenantId);
    const ocupacion_actual = await this.animalRepository.count({
      where: {
        potrero: { pk_id_potrero: potreroId },
        tenant_id: tenantId,
        deleted_at: IsNull(),
        estado: EstadoAnimal.ACTIVO,
      },
    });
    const capacidad = potrero.capacidad_animales;
    const porcentaje = capacidad > 0 ? Math.round((ocupacion_actual / capacidad) * 100) : 0;
    let estado_ocupacion: string;
    if (ocupacion_actual > capacidad) estado_ocupacion = 'sobrecargado';
    else if (porcentaje < 30) estado_ocupacion = 'subutilizado';
    else estado_ocupacion = 'normal';

    return {
      pk_id_potrero: potreroId,
      nombre_potrero: potrero.nombre_potrero,
      capacidad_animales: capacidad,
      ocupacion_actual,
      porcentaje_ocupacion: porcentaje,
      estado_ocupacion,
    };
  }

  async validateCapacity(potreroId: string, tenantId: string): Promise<void> {
    const { ocupacion_actual, capacidad_animales } = await this.getOccupancy(potreroId, tenantId);
    if (ocupacion_actual >= capacidad_animales) {
      throw new BadRequestException(
        `Potrero "${potreroId}" está lleno (${ocupacion_actual}/${capacidad_animales})`,
      );
    }
  }

  async update(
    id: string,
    dto: UpdatePotreroDto,
    tenantId: string,
    userId: number,
  ): Promise<Potrero> {
    await this.findOne(id, tenantId);
    const payload = this.toEntityPayload(dto as any);
    const updated = await this.baseRepo.updateWithTenant(
      id,
      payload as any,
      tenantId,
      userId,
    );
    if (!updated) throw new NotFoundException(`Potrero "${id}" no encontrado`);
    return updated;
  }

  /**
   * Transforma un DTO con `fincaId` plano en un payload que TypeORM
   * mapea correctamente a la relación @ManyToOne con Finca.
   */
  private toEntityPayload(dto: { fincaId?: string } & Record<string, any>): any {
    const { fincaId, ...rest } = dto;
    const payload: any = { ...rest };
    if (fincaId !== undefined) {
      payload.finca = fincaId ? { pk_id_finca: fincaId } : null;
    }
    return payload;
  }

  async remove(id: string, tenantId: string): Promise<{ message: string }> {
    await this.findOne(id, tenantId);
    await this.baseRepo.softDelete(id, tenantId);
    return { message: `Potrero "${id}" eliminado correctamente` };
  }

  async findAnimalsByPotrero(
    potreroId: string,
    tenantId: string,
  ): Promise<Animal[]> {
    await this.findOne(potreroId, tenantId);
    return this.animalRepository.find({
      where: {
        potrero: { pk_id_potrero: potreroId },
        tenant_id: tenantId,
        deleted_at: IsNull(),
        estado: EstadoAnimal.ACTIVO,
      },
    });
  }
}
