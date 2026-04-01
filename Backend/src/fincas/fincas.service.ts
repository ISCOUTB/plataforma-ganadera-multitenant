import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Finca } from './entities/finca.entity';
import { Animal } from '../animales/entities/animal.entity';
import { Potrero } from '../potreros/entities/potrero.entity';
import { BaseRepository } from '../common/repositories/base.repository';
import { CreateFincaDto } from './dto/create-finca.dto';
import { UpdateFincaDto } from './dto/update-finca.dto';
import { FilterFincasDto } from './dto/filter-fincas.dto';
import { PaginatedResult } from '../common/interfaces/paginated-result.interface';

@Injectable()
export class FincasService {
  protected baseRepo: BaseRepository<Finca>;

  constructor(
    @InjectRepository(Finca)
    private readonly fincaRepository: Repository<Finca>,
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
    @InjectRepository(Potrero)
    private readonly potreroRepository: Repository<Potrero>,
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

  // Retorna fincas paginadas con filtros opcionales.
  findAllPaginated(
    tenantId: string,
    filters: FilterFincasDto,
  ): Promise<PaginatedResult<Finca>> {
    const { page, limit, sortBy, sortOrder, nombre_finca, ubicacion } = filters;
    const extraWhere: any = {};
    if (nombre_finca) extraWhere.nombre_finca = nombre_finca;
    if (ubicacion) extraWhere.ubicacion = ubicacion;
    return this.baseRepo.findAllPaginated(
      tenantId,
      { page, limit, sortBy, sortOrder },
      extraWhere,
    );
  }

  async findOne(id: string, tenantId: string): Promise<Finca> {
    const finca = await this.baseRepo.findOneByIdWithRelations(
      id, tenantId, ['animales', 'potreros'],
    );
    if (!finca) {
      throw new NotFoundException(`Finca "${id}" no encontrada`);
    }
    return finca;
  }

  async findAnimalesByFinca(fincaId: string, tenantId: string): Promise<Animal[]> {
    await this.findOne(fincaId, tenantId);
    return this.animalRepository.find({
      where: { finca: { pk_id_finca: fincaId }, tenant_id: tenantId, deleted_at: IsNull() },
    });
  }

  async findPotrerosByFinca(fincaId: string, tenantId: string): Promise<Potrero[]> {
    await this.findOne(fincaId, tenantId);
    return this.potreroRepository.find({
      where: { finca: { pk_id_finca: fincaId }, tenant_id: tenantId, deleted_at: IsNull() },
    });
  }

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
