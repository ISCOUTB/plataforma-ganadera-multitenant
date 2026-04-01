import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, MoreThanOrEqual, IsNull } from 'typeorm';
import { Salud } from './entities/salud.entity';
import { Animal } from '../animales/entities/animal.entity';
import { BaseRepository } from '../common/repositories/base.repository';
import { CreateSaludDto } from './dto/create-salud.dto';
import { UpdateSaludDto } from './dto/update-salud.dto';
import { FilterSaludDto } from './dto/filter-salud.dto';
import { PaginatedResult } from '../common/interfaces/paginated-result.interface';

@Injectable()
export class SaludService {
  protected baseRepo: BaseRepository<Salud>;

  constructor(
    @InjectRepository(Salud)
    private readonly saludRepository: Repository<Salud>,
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
  ) {
    this.baseRepo = new BaseRepository(saludRepository);
  }

  async create(dto: CreateSaludDto, tenantId: string, userId: number): Promise<Salud> {
    if (dto.animalId) {
      await this.validateAnimal(dto.animalId, tenantId);
    }
    return this.baseRepo.createWithTenant(dto as any, tenantId, userId);
  }

  findAll(tenantId: string): Promise<Salud[]> {
    return this.baseRepo.findAll(tenantId);
  }

  findAllPaginated(
    tenantId: string,
    filters: FilterSaludDto,
  ): Promise<PaginatedResult<Salud>> {
    const { page, limit, sortBy, sortOrder, tipo_intervencion } = filters;
    const extraWhere: any = {};
    if (tipo_intervencion) extraWhere.tipo_intervencion = tipo_intervencion;
    return this.baseRepo.findAllPaginated(
      tenantId,
      { page, limit, sortBy, sortOrder },
      extraWhere,
    );
  }

  async findOne(id: number, tenantId: string): Promise<Salud> {
    const salud = await this.baseRepo.findOneByIdWithRelations(id, tenantId, ['animal']);
    if (!salud) throw new NotFoundException(`Registro de salud #${id} no encontrado`);
    return salud;
  }

  async update(id: number, dto: UpdateSaludDto, tenantId: string, userId: number): Promise<Salud> {
    await this.findOne(id, tenantId);
    if (dto.animalId) {
      await this.validateAnimal(dto.animalId, tenantId);
    }
    const updated = await this.baseRepo.updateWithTenant(id, dto as any, tenantId, userId);
    if (!updated) throw new NotFoundException(`Registro de salud #${id} no encontrado`);
    return updated;
  }

  async remove(id: number, tenantId: string): Promise<{ message: string }> {
    await this.findOne(id, tenantId);
    await this.baseRepo.softDelete(id, tenantId);
    return { message: `Registro de salud #${id} eliminado correctamente` };
  }

  /**
   * Alertas de salud: detecta eventos próximos (7 días) y vencidos.
   * Ayuda al ganadero a no perder vacunaciones ni tratamientos.
   */
  async getAlertas(tenantId: string): Promise<{ proximas: Salud[]; vencidas: Salud[] }> {
    const hoy = new Date();
    const en7dias = new Date();
    en7dias.setDate(hoy.getDate() + 7);

    const proximas = await this.saludRepository.find({
      where: {
        tenant_id: tenantId,
        deleted_at: IsNull(),
        fecha_proxima_aplicacion: LessThanOrEqual(en7dias),
      },
      relations: ['animal'],
      order: { fecha_proxima_aplicacion: 'ASC' },
    });

    // Separar: vencidas (fecha < hoy) vs próximas (hoy <= fecha <= hoy+7)
    const vencidas = proximas.filter(
      (s) => s.fecha_proxima_aplicacion && new Date(s.fecha_proxima_aplicacion) < hoy,
    );
    const proximasFiltradas = proximas.filter(
      (s) => s.fecha_proxima_aplicacion && new Date(s.fecha_proxima_aplicacion) >= hoy,
    );

    return { proximas: proximasFiltradas, vencidas };
  }

  private async validateAnimal(animalId: number, tenantId: string): Promise<void> {
    const animal = await this.animalRepository.findOne({
      where: { id: animalId, tenant_id: tenantId, deleted_at: IsNull() },
    });
    if (!animal) {
      throw new BadRequestException(`Animal #${animalId} no encontrado en este tenant`);
    }
  }
}
