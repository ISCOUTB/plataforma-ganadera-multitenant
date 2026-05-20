import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Veterinario } from './entities/veterinario.entity';
import { CreateVeterinarioDto } from './dto/create-veterinario.dto';
import { UpdateVeterinarioDto } from './dto/update-veterinario.dto';

@Injectable()
export class VeterinariosService {
  constructor(
    @InjectRepository(Veterinario)
    private readonly repo: Repository<Veterinario>,
  ) {}

  async findAll(tenantId: string) {
    return this.repo.find({
      where: { tenant_id: tenantId, deleted_at: IsNull() },
      order: { nombre: 'ASC' },
    });
  }

  async findOne(id: number, tenantId: string) {
    const vet = await this.repo.findOne({
      where: { id, tenant_id: tenantId, deleted_at: IsNull() },
    });
    if (!vet) throw new NotFoundException('Veterinario no encontrado');
    return vet;
  }

  async create(dto: CreateVeterinarioDto, tenantId: string) {
    const vet = this.repo.create({ ...dto, tenant_id: tenantId });
    return this.repo.save(vet);
  }

  async update(id: number, dto: UpdateVeterinarioDto, tenantId: string) {
    const vet = await this.findOne(id, tenantId);
    Object.assign(vet, dto);
    return this.repo.save(vet);
  }

  async remove(id: number, tenantId: string) {
    const vet = await this.findOne(id, tenantId);
    await this.repo.softDelete(id);
    return { message: 'Veterinario eliminado' };
  }
}
