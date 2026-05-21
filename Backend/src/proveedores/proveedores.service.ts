import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Proveedor } from './entities/proveedor.entity';
import { ProveedorPrecio } from './entities/proveedor-precio.entity';
import { CreateProveedorDto, CreatePrecioDto } from './dto/create-proveedor.dto';
import { UpdateProveedorDto } from './dto/update-proveedor.dto';

@Injectable()
export class ProveedoresService {
  constructor(
    @InjectRepository(Proveedor)
    private readonly repo: Repository<Proveedor>,
    @InjectRepository(ProveedorPrecio)
    private readonly precioRepo: Repository<ProveedorPrecio>,
  ) {}

  async findAll(tenantId: string) {
    return this.repo.find({
      where: { tenant_id: tenantId, deleted_at: IsNull() },
      relations: ['precios'],
      order: { creado_en: 'DESC' },
    });
  }

  async findOne(id: number, tenantId: string) {
    const p = await this.repo.findOne({
      where: { id, tenant_id: tenantId, deleted_at: IsNull() },
      relations: ['precios'],
    });
    if (!p) throw new NotFoundException('Proveedor no encontrado');
    return p;
  }

  async create(dto: CreateProveedorDto, tenantId: string) {
    const p = this.repo.create({ ...dto, tenant_id: tenantId });
    return this.repo.save(p);
  }

  async update(id: number, dto: UpdateProveedorDto, tenantId: string) {
    const p = await this.findOne(id, tenantId);
    Object.assign(p, dto);
    return this.repo.save(p);
  }

  async remove(id: number, tenantId: string) {
    await this.findOne(id, tenantId);
    await this.repo.softDelete(id);
    return { message: 'Proveedor eliminado' };
  }

  async addPrecio(id: number, dto: CreatePrecioDto, tenantId: string) {
    await this.findOne(id, tenantId);
    const existing = await this.precioRepo.findOne({
      where: { fk_id_proveedor: id, fk_id_alimento: dto.fk_id_alimento },
    });
    if (existing) {
      existing.precio = dto.precio;
      if (dto.unidad) existing.unidad = dto.unidad;
      existing.actualizado_en = new Date();
      return this.precioRepo.save(existing);
    }
    const precio = this.precioRepo.create({ ...dto, fk_id_proveedor: id });
    return this.precioRepo.save(precio);
  }

  async removePrecio(precioId: number) {
    const p = await this.precioRepo.findOne({ where: { id: precioId } });
    if (!p) throw new NotFoundException('Precio no encontrado');
    await this.precioRepo.remove(p);
    return { message: 'Precio eliminado' };
  }

  async getComparador(fkIdAlimento: string, tenantId: string) {
    const precios = await this.precioRepo
      .createQueryBuilder('pp')
      .innerJoinAndSelect('pp.proveedor', 'prov')
      .where('pp.fk_id_alimento = :fkIdAlimento', { fkIdAlimento })
      .andWhere('prov.tenant_id = :tenantId', { tenantId })
      .andWhere('prov.deleted_at IS NULL')
      .orderBy('pp.precio', 'ASC')
      .getMany();
    return precios;
  }
}