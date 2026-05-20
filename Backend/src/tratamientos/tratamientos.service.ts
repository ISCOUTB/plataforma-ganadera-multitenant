import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Tratamiento, SeguimientoTratamiento } from './entities/tratamiento.entity';
import { CreateTratamientoDto, CreateSeguimientoDto } from './dto/create-tratamiento.dto';
import { UpdateTratamientoDto } from './dto/update-tratamiento.dto';

@Injectable()
export class TratamientosService {
  constructor(
    @InjectRepository(Tratamiento)
    private readonly repo: Repository<Tratamiento>,
    @InjectRepository(SeguimientoTratamiento)
    private readonly seguimientoRepo: Repository<SeguimientoTratamiento>,
  ) {}

  async findAll(tenantId: string) {
    return this.repo.find({
      where: { tenant_id: tenantId, deleted_at: IsNull() },
      relations: ['veterinario', 'seguimientos'],
      order: { creado_en: 'DESC' },
    });
  }

  async findByAnimal(bovinoId: number, tenantId: string) {
    return this.repo.find({
      where: { fk_id_bovino: bovinoId, tenant_id: tenantId, deleted_at: IsNull() },
      relations: ['veterinario', 'seguimientos'],
      order: { creado_en: 'DESC' },
    });
  }

  async findOne(id: number, tenantId: string) {
    const t = await this.repo.findOne({
      where: { id, tenant_id: tenantId, deleted_at: IsNull() },
      relations: ['veterinario', 'seguimientos'],
    });
    if (!t) throw new NotFoundException('Tratamiento no encontrado');
    return t;
  }

  async create(dto: CreateTratamientoDto, tenantId: string) {
    const t = this.repo.create({ ...dto, tenant_id: tenantId });
    return this.repo.save(t);
  }

  async update(id: number, dto: UpdateTratamientoDto, tenantId: string) {
    const t = await this.findOne(id, tenantId);
    Object.assign(t, dto);
    return this.repo.save(t);
  }

  async remove(id: number, tenantId: string) {
    await this.findOne(id, tenantId);
    await this.repo.softDelete(id);
    return { message: 'Tratamiento eliminado' };
  }

  async addSeguimiento(id: number, dto: CreateSeguimientoDto, tenantId: string) {
    await this.findOne(id, tenantId);
    const s = this.seguimientoRepo.create({ ...dto, fk_id_tratamiento: id });
    return this.seguimientoRepo.save(s);
  }
}
