import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Alimento } from './entities/alimento.entity';
import { BaseRepository } from '../common/repositories/base.repository';
import { CreateAlimentoDto } from './dto/create-alimento.dto';
import { UpdateAlimentoDto } from './dto/update-alimento.dto';
import { FilterAlimentosDto } from './dto/filter-alimentos.dto';
import { PaginatedResult } from '../common/interfaces/paginated-result.interface';

@Injectable()
export class AlimentosService {
  protected baseRepo: BaseRepository<Alimento>;

  constructor(
    @InjectRepository(Alimento)
    private readonly alimentoRepository: Repository<Alimento>,
  ) {
    this.baseRepo = new BaseRepository(alimentoRepository);
  }

  create(dto: CreateAlimentoDto, tenantId: string, userId: number): Promise<Alimento> {
    return this.baseRepo.createWithTenant(dto as any, tenantId, userId);
  }

  findAll(tenantId: string): Promise<Alimento[]> {
    return this.baseRepo.findAll(tenantId);
  }

  findAllPaginated(
    tenantId: string,
    filters: FilterAlimentosDto,
  ): Promise<PaginatedResult<Alimento>> {
    const { page, limit, sortBy, sortOrder, tipo_alimento } = filters;
    const extraWhere: any = {};
    if (tipo_alimento) extraWhere.tipo_alimento = tipo_alimento;
    return this.baseRepo.findAllPaginated(
      tenantId,
      { page, limit, sortBy, sortOrder },
      extraWhere,
    );
  }

  async findOne(id: string, tenantId: string): Promise<Alimento> {
    const alimento = await this.baseRepo.findOneById(id, tenantId);
    if (!alimento) throw new NotFoundException(`Alimento "${id}" no encontrado`);
    return alimento;
  }

  async update(id: string, dto: UpdateAlimentoDto, tenantId: string, userId: number): Promise<Alimento> {
    await this.findOne(id, tenantId);
    const updated = await this.baseRepo.updateWithTenant(id, dto as any, tenantId, userId);
    if (!updated) throw new NotFoundException(`Alimento "${id}" no encontrado`);
    return updated;
  }

  async remove(id: string, tenantId: string): Promise<{ message: string }> {
    await this.findOne(id, tenantId);
    await this.baseRepo.softDelete(id, tenantId);
    return { message: `Alimento "${id}" eliminado correctamente` };
  }
}
