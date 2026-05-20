import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { BovinoAlimento } from './entities/bovino-alimento.entity';
import { Animal } from '../animales/entities/animal.entity';
import { Alimento } from '../alimentos/entities/alimento.entity';
import { AsignarAlimentoDto } from './dto/asignar-alimento.dto';
import { FilterBovinoAlimentoDto } from './dto/filter-bovino-alimento.dto';
import { PaginatedResult } from '../common/interfaces/paginated-result.interface';

@Injectable()
export class BovinoAlimentoService {
  constructor(
    @InjectRepository(BovinoAlimento)
    private readonly bovinoAlimentoRepository: Repository<BovinoAlimento>,
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
    @InjectRepository(Alimento)
    private readonly alimentoRepository: Repository<Alimento>,
  ) {}

  /** Asignar un alimento a un animal */
  async asignar(dto: AsignarAlimentoDto, tenantId: string): Promise<BovinoAlimento> {
    // Validar animal
    const animal = await this.animalRepository.findOne({
      where: { id: dto.animalId, tenant_id: tenantId, deleted_at: IsNull() },
    });
    if (!animal) throw new NotFoundException(`Animal #${dto.animalId} no encontrado`);

    // Validar alimento
    const alimento = await this.alimentoRepository.findOne({
      where: { pk_id_alimento: dto.alimentoId, tenant_id: tenantId, deleted_at: IsNull() },
    });
    if (!alimento) throw new NotFoundException(`Alimento "${dto.alimentoId}" no encontrado`);

    const registro = this.bovinoAlimentoRepository.create({
      fk_id_bovino: dto.animalId,
      fk_id_alimento: dto.alimentoId,
      cantidad: dto.cantidad,
      fecha: dto.fecha as any,
      tenant_id: tenantId,
    });

    return this.bovinoAlimentoRepository.save(registro);
  }

  async findAllPaginated(
    tenantId: string,
    filters: FilterBovinoAlimentoDto,
  ): Promise<PaginatedResult<BovinoAlimento>> {
    const page = Math.max(filters.page ?? 1, 1);
    const limit = Math.min(Math.max(filters.limit ?? 10, 1), 100);

    const where: any = { tenant_id: tenantId };
    if (filters.animalId) where.fk_id_bovino = filters.animalId;

    const order: any = {};
    if (filters.sortBy) {
      order[filters.sortBy] = filters.sortOrder ?? 'ASC';
    } else {
      order.fecha = 'DESC';
    }

    const [data, total] = await this.bovinoAlimentoRepository.findAndCount({
      where,
      relations: ['alimento'],
      skip: (page - 1) * limit,
      take: limit,
      order,
    });

    return {
      data,
      total,
      page,
      lastPage: Math.ceil(total / limit) || 1,
    };
  }

  /** Consumo de alimentos de un animal */
  async findByAnimal(animalId: number, tenantId: string): Promise<BovinoAlimento[]> {
    return this.bovinoAlimentoRepository.find({
      where: { fk_id_bovino: animalId, tenant_id: tenantId },
      relations: ['alimento'],
      order: { fecha: 'DESC' },
    });
  }

  /** Quitar asignación de alimento a un animal */
  async removeAsignacion(animalId: number, alimentoId: string, tenantId: string): Promise<{ message: string }> {
    const registro = await this.bovinoAlimentoRepository.findOne({
      where: { fk_id_bovino: animalId, fk_id_alimento: alimentoId, tenant_id: tenantId },
    });
    if (!registro) throw new NotFoundException('Asignación no encontrada');
    await this.bovinoAlimentoRepository.remove(registro);
    return { message: 'Asignación eliminada correctamente' };
  }
}
