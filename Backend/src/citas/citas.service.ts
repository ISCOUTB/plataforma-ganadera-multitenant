import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Cita } from './entities/cita.entity';
import { CreateCitaDto } from './dto/create-cita.dto';
import { UpdateCitaDto } from './dto/update-cita.dto';

@Injectable()
export class CitasService {
  constructor(
    @InjectRepository(Cita)
    private readonly repo: Repository<Cita>,
  ) {}

  async findAll(tenantId: string) {
    return this.repo.find({
      where: { tenant_id: tenantId, deleted_at: IsNull() },
      relations: ['veterinario'],
      order: { fecha_hora: 'ASC' },
    });
  }

  async findOne(id: number, tenantId: string) {
    const cita = await this.repo.findOne({
      where: { id, tenant_id: tenantId, deleted_at: IsNull() },
      relations: ['veterinario'],
    });
    if (!cita) throw new NotFoundException('Cita no encontrada');
    return cita;
  }

  async create(dto: CreateCitaDto, tenantId: string) {
    const cita = this.repo.create({ ...dto, tenant_id: tenantId });
    return this.repo.save(cita);
  }

  async update(id: number, dto: UpdateCitaDto, tenantId: string) {
    const cita = await this.findOne(id, tenantId);
    Object.assign(cita, dto);
    return this.repo.save(cita);
  }

  async remove(id: number, tenantId: string) {
    await this.findOne(id, tenantId);
    await this.repo.softDelete(id);
    return { message: 'Cita eliminada' };
  }

  async findProximas(tenantId: string, dias: number = 7) {
    const hoy = new Date();
    const limite = new Date();
    limite.setDate(hoy.getDate() + dias);
    return this.repo
      .createQueryBuilder('cita')
      .leftJoinAndSelect('cita.veterinario', 'veterinario')
      .where('cita.tenant_id = :tenantId', { tenantId })
      .andWhere('cita.deleted_at IS NULL')
      .andWhere('cita.estado = :estado', { estado: 'pendiente' })
      .andWhere('cita.fecha_hora BETWEEN :hoy AND :limite', { hoy, limite })
      .orderBy('cita.fecha_hora', 'ASC')
      .getMany();
  }
}
