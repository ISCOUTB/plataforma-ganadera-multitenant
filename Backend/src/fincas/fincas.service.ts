import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Finca } from './entities/finca.entity';
import { BaseRepository } from '../common/repositories/base.repository';
import { CreateFincaDto } from './dto/create-finca.dto';
import { UpdateFincaDto } from './dto/update-finca.dto';

// FincasService — usa BaseRepository exclusivamente.
// Finca tiene PK string manual (pk_id_finca), que BaseRepository detecta
// dinámicamente vía TypeORM metadata (primaryColumns[0].propertyName).
@Injectable()
export class FincasService {
  protected baseRepo: BaseRepository<Finca>;

  constructor(
    @InjectRepository(Finca)
    private readonly fincaRepository: Repository<Finca>,
  ) {
    this.baseRepo = new BaseRepository(fincaRepository);
  }

  // Crea una finca asociada al tenant del usuario autenticado.
  // pk_id_finca viene del DTO (código manual de la finca).
  // tenant_id y created_by vienen del JWT — nunca del cliente.
  create(dto: CreateFincaDto, tenantId: string, userId: number): Promise<Finca> {
    return this.baseRepo.createWithTenant(dto as any, tenantId, userId);
  }

  // Retorna todas las fincas activas del tenant.
  findAll(tenantId: string): Promise<Finca[]> {
    return this.baseRepo.findAll(tenantId);
  }

  // Busca finca por su PK string + tenant. Lanza 404 si no existe.
  async findOne(id: string, tenantId: string): Promise<Finca> {
    const finca = await this.baseRepo.findOneById(id, tenantId);
    if (!finca) {
      throw new NotFoundException(`Finca "${id}" no encontrada`);
    }
    return finca;
  }

  // Actualiza finca del tenant. Lanza 404 si no existe.
  async update(
    id: string,
    dto: UpdateFincaDto,
    tenantId: string,
    userId: number,
  ): Promise<Finca> {
    await this.findOne(id, tenantId);
    const updated = await this.baseRepo.updateWithTenant(id, dto as any, tenantId, userId);
    if (!updated) throw new NotFoundException(`Finca "${id}" no encontrada`);
    return updated;
  }

  // Soft delete de la finca. Lanza 404 si no existe.
  async remove(id: string, tenantId: string): Promise<{ message: string }> {
    await this.findOne(id, tenantId);
    await this.baseRepo.softDelete(id, tenantId);
    return { message: `Finca "${id}" eliminada correctamente` };
  }
}
