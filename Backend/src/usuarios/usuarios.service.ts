import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { Rol, Usuario } from './entities/usuario.entity';
import { BaseRepository } from '../common/repositories/base.repository';
import { CreateUsuarioDto } from './dto/create-usuario.dto';
import { UpdateUsuarioDto } from './dto/update-usuario.dto';

type SafeUsuario = Omit<Usuario, 'password' | 'refresh_token_hash'>;

// UsuariosService — solo responsabilidad de CRUD de usuarios.
// La lógica de autenticación (login, registro, tokens) vive en AuthService.
@Injectable()
export class UsuariosService {
  protected baseRepo: BaseRepository<Usuario>;

  constructor(
    @InjectRepository(Usuario)
    private readonly usuariosRepository: Repository<Usuario>,
  ) {
    this.baseRepo = new BaseRepository(usuariosRepository);
  }

  // CORRECCIÓN DE VIOLACIÓN: filtrado por tenant_id obligatorio.
  // tenantId proviene de @Tenant() en el controller (guard-injected desde JWT).
  // @Exclude() en la entidad oculta password y refresh_token_hash en la respuesta.
  findAll(tenantId: string): Promise<Usuario[]> {
    return this.baseRepo.findAll(tenantId);
  }

  // Búsqueda por email — exenta de tenant filter (operación de autenticación).
  // Usada por AuthService para validar credenciales en login/registro.
  findByEmail(email: string): Promise<Usuario | null> {
    return this.usuariosRepository.findOne({ where: { email } });
  }

  // Actualiza el hash del refresh token — exenta de tenant filter (operación de auth).
  // Usada por AuthService para rotar tokens y cerrar sesión.
  async updateRefreshHash(
    userId: number,
    hash: string | null,
  ): Promise<void> {
    await this.usuariosRepository.update(userId, { refresh_token_hash: hash });
  }

  // Crea un usuario dentro del tenant del actor.
  // tenant_id se inyecta desde el JWT, NUNCA desde el body — previene cross-tenant creation.
  async create(
    dto: CreateUsuarioDto,
    tenantId: string,
    actorId: number,
  ): Promise<SafeUsuario> {
    const exists = await this.usuariosRepository.findOne({
      where: { email: dto.email, deleted_at: IsNull() },
    });
    if (exists) {
      throw new ConflictException(
        `El email ${dto.email} ya está registrado en el sistema`,
      );
    }

    const hash = await bcrypt.hash(dto.password, 10);
    const entity = new Usuario();
    entity.email = dto.email;
    entity.password = hash;
    entity.nombre = dto.nombre;
    entity.telefono = dto.telefono ?? '';
    entity.rol = dto.rol ?? Rol.EMPLEADO;
    entity.tenant_id = tenantId;
    entity.created_by = actorId;
    entity.updated_by = actorId;

    const saved = await this.usuariosRepository.save(entity);
    return this.stripSensitive(saved);
  }

  // Actualiza campos mutables (nombre, telefono, rol) validando pertenencia al tenant.
  async update(
    id: number,
    dto: UpdateUsuarioDto,
    tenantId: string,
    actorId: number,
  ): Promise<SafeUsuario> {
    const target = await this.usuariosRepository.findOne({
      where: { id, tenant_id: tenantId, deleted_at: IsNull() },
    });
    if (!target) {
      throw new NotFoundException('Usuario no encontrado');
    }

    if (dto.nombre !== undefined) target.nombre = dto.nombre;
    if (dto.telefono !== undefined) target.telefono = dto.telefono;
    if (dto.rol !== undefined) target.rol = dto.rol;
    target.updated_by = actorId;

    const saved = await this.usuariosRepository.save(target);
    return this.stripSensitive(saved);
  }

  // Soft delete dentro del tenant. El actor no puede eliminarse a sí mismo.
  async remove(
    id: number,
    tenantId: string,
    actorId: number,
  ): Promise<{ ok: true }> {
    if (id === actorId) {
      throw new BadRequestException('No puedes eliminarte a ti mismo');
    }
    const target = await this.usuariosRepository.findOne({
      where: { id, tenant_id: tenantId, deleted_at: IsNull() },
    });
    if (!target) {
      throw new NotFoundException('Usuario no encontrado');
    }
    await this.baseRepo.softDelete(id, tenantId);
    return { ok: true };
  }

  private stripSensitive(u: Usuario): SafeUsuario {
    const { password: _p, refresh_token_hash: _r, ...rest } = u;
    return rest;
  }
}
