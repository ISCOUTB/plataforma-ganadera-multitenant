import { Injectable, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { Usuario, Rol } from '../usuarios/entities/usuario.entity';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(Usuario)
    private readonly usuarioRepo: Repository<Usuario>,
  ) {}

  /**
   * Lista todos los tenant_ids distintos que existen en el sistema.
   * Solo accesible para superadmin.
   */
  async listTenants(): Promise<
    { tenant_id: string; user_count: number }[]
  > {
    const rows = await this.usuarioRepo
      .createQueryBuilder('u')
      .select('u.tenant_id', 'tenant_id')
      .addSelect('COUNT(*)', 'user_count')
      .where('u.deleted_at IS NULL')
      .andWhere('u.tenant_id IS NOT NULL')
      .groupBy('u.tenant_id')
      .orderBy('u.tenant_id', 'ASC')
      .getRawMany();

    return rows.map((r) => ({
      tenant_id: r.tenant_id,
      user_count: parseInt(r.user_count, 10) || 0,
    }));
  }

  /**
   * Crea un usuario en cualquier tenant. Solo accesible para superadmin.
   * Útil para onboarding de clientes sin que se auto-registren.
   */
  async createUser(dto: {
    email: string;
    password: string;
    nombre: string;
    tenant_id: string;
    rol?: Rol;
    telefono?: string;
  }): Promise<any> {
    // Verificar email único
    const exists = await this.usuarioRepo.findOne({
      where: { email: dto.email, deleted_at: IsNull() },
    });
    if (exists) {
      throw new ConflictException(`El email ${dto.email} ya está registrado`);
    }

    const hash = await bcrypt.hash(dto.password, 10);
    const entity = new Usuario();
    entity.email = dto.email;
    entity.password = hash;
    entity.nombre = dto.nombre;
    entity.tenant_id = dto.tenant_id;
    entity.rol = dto.rol || Rol.ADMIN;
    entity.telefono = dto.telefono ?? '';

    const saved = await this.usuarioRepo.save(entity);
    // No devolver campos sensibles
    const { password: _p, refresh_token_hash: _r, ...result } = saved;
    return result;
  }

  /**
   * Lista todos los usuarios del sistema (cross-tenant). Solo superadmin.
   */
  async listAllUsers(): Promise<any[]> {
    const users = await this.usuarioRepo.find({
      where: { deleted_at: IsNull() },
      order: { tenant_id: 'ASC', creado_en: 'DESC' },
    });
    return users.map(({ password, refresh_token_hash, ...rest }) => rest);
  }
}
