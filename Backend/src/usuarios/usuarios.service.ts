import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Usuario } from './entities/usuario.entity';

@Injectable()
export class UsuariosService {
  constructor(
    @InjectRepository(Usuario)
    private usuariosRepository: Repository<Usuario>,
  ) {}

  async registro(data: Partial<Usuario>): Promise<Usuario> {
    const existe = await this.usuariosRepository.findOne({ where: { email: data.email } });
    if (existe) throw new ConflictException('El email ya está registrado');
    const usuario = this.usuariosRepository.create(data);
    return this.usuariosRepository.save(usuario);
  }

  async login(email: string, password: string): Promise<Usuario> {
    const usuario = await this.usuariosRepository.findOne({ where: { email } });
    if (!usuario || usuario.password !== password)
      throw new UnauthorizedException('Credenciales inválidas');
    return usuario;
  }

  findAll(): Promise<Usuario[]> {
    return this.usuariosRepository.find();
  }
}
