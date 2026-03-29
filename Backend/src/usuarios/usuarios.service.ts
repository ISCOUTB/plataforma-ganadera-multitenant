import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Usuario } from './entities/usuario.entity';
import { BaseRepository } from '../common/repositories/base.repository';

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
}
