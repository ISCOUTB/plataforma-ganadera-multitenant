import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Animal } from './entities/animal.entity';
import { BaseRepository } from '../common/repositories/base.repository';
import { CreateAnimalDto } from './dto/create-animal.dto';
import { UpdateAnimalDto } from './dto/update-animal.dto';

// AnimalesService — toda la lógica de negocio pasa por BaseRepository.
// REGLA: NUNCA llamar a animalRepository directamente desde los métodos de dominio.
// El acceso directo al repositorio queda solo en el constructor.
@Injectable()
export class AnimalesService {
  protected baseRepo: BaseRepository<Animal>;

  constructor(
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
  ) {
    this.baseRepo = new BaseRepository(animalRepository);
  }

  // Crea un bovino en el tenant del usuario autenticado.
  // tenant_id y created_by provienen del JWT — el cliente NUNCA los envía.
  create(dto: CreateAnimalDto, tenantId: string, userId: number): Promise<Animal> {
    return this.baseRepo.createWithTenant(dto as any, tenantId, userId);
  }

  // Retorna todos los bovinos activos (deleted_at IS NULL) del tenant.
  findAll(tenantId: string): Promise<Animal[]> {
    return this.baseRepo.findAll(tenantId);
  }

  // Busca un bovino por id verificando que pertenezca al tenant.
  // Lanza 404 si no existe o pertenece a otro tenant.
  async findOne(id: number, tenantId: string): Promise<Animal> {
    const animal = await this.baseRepo.findOneById(id, tenantId);
    if (!animal) {
      throw new NotFoundException(`Animal #${id} no encontrado`);
    }
    return animal;
  }

  // Actualiza un bovino del tenant. Lanza 404 si no existe o pertenece a otro tenant.
  async update(
    id: number,
    dto: UpdateAnimalDto,
    tenantId: string,
    userId: number,
  ): Promise<Animal> {
    // Verificar existencia antes de actualizar
    await this.findOne(id, tenantId);
    const updated = await this.baseRepo.updateWithTenant(id, dto as any, tenantId, userId);
    if (!updated) throw new NotFoundException(`Animal #${id} no encontrado`);
    return updated;
  }

  // Soft delete: pone deleted_at = NOW(). El registro permanece en DB.
  // Lanza 404 si no existe o pertenece a otro tenant.
  async remove(id: number, tenantId: string): Promise<{ message: string }> {
    await this.findOne(id, tenantId);
    await this.baseRepo.softDelete(id, tenantId);
    return { message: `Animal #${id} eliminado correctamente` };
  }
}
