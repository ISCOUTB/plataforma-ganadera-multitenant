import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { Usuario } from '../usuarios/entities/usuario.entity';
import { LoginDto } from './dto/login.dto';
import { RegistroDto } from './dto/registro.dto';

// Payload que viaja firmado dentro del JWT.
// tenant_id viaja en el token → no se consulta la BD en cada request.
interface JwtPayload {
  sub: number;
  email: string;
  tenant_id: string;
  rol: string;
}

@Injectable()
export class AuthService {
  constructor(
    // AuthService inyecta el repositorio directamente para evitar
    // dependencia circular con UsuariosModule.
    @InjectRepository(Usuario)
    private usuariosRepository: Repository<Usuario>,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  // Crea un nuevo usuario. Devuelve el usuario sin password ni refresh_token_hash.
  async registro(data: RegistroDto): Promise<Partial<Usuario>> {
    const existe = await this.usuariosRepository.findOne({
      where: { email: data.email },
    });
    if (existe) throw new ConflictException('El email ya está registrado');

    // Hashear la contraseña antes de persistir
    const hashedPassword = await bcrypt.hash(data.password, 10);

    const usuario = this.usuariosRepository.create({
      ...data,
      password: hashedPassword,
    });

    const savedUser = (await this.usuariosRepository.save(usuario)) as Usuario;

    // Excluir campos sensibles de la respuesta manualmente
    // (@Exclude() en la entidad maneja el caso de instancias de clase devueltas por otros métodos)
    const { password, refresh_token_hash, ...result } = savedUser;
    return result;
  }

  // Valida credenciales y devuelve access_token + refresh_token + user profile.
  async login(
    email: string,
    password: string,
  ): Promise<{
    access_token: string;
    refresh_token: string;
    user: { id: number; nombre: string; email: string; rol: string; tenant_id: string };
  }> {
    const usuario = await this.usuariosRepository.findOne({ where: { email } });

    // Comparar la contraseña recibida contra el hash almacenado
    const isMatch = usuario && (await bcrypt.compare(password, usuario.password));
    if (!isMatch) throw new UnauthorizedException('Credenciales inválidas');

    const payload: JwtPayload = {
      sub: usuario.id,
      email: usuario.email,
      tenant_id: usuario.tenant_id,
      rol: usuario.rol,
    };

    const tokens = this.generateTokens(payload);

    // Guardar hash bcrypt del refresh token para validación futura.
    // Nunca guardar el refresh token en texto plano.
    const refreshHash = await bcrypt.hash(tokens.refresh_token, 10);
    await this.usuariosRepository.update(usuario.id, {
      refresh_token_hash: refreshHash,
    });

    return {
      ...tokens,
      user: {
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
        rol: usuario.rol,
        tenant_id: usuario.tenant_id,
      },
    };
  }

  // Retorna el perfil del usuario autenticado a partir del JWT.
  async getProfile(userId: number): Promise<{
    id: number;
    nombre: string;
    email: string;
    rol: string;
    tenant_id: string;
    telefono: string | null;
  }> {
    const usuario = await this.usuariosRepository.findOne({
      where: { id: userId },
    });
    if (!usuario) throw new UnauthorizedException('Usuario no encontrado');

    return {
      id: usuario.id,
      nombre: usuario.nombre,
      email: usuario.email,
      rol: usuario.rol,
      tenant_id: usuario.tenant_id,
      telefono: usuario.telefono ?? null,
    };
  }

  // Valida el refresh token actual, genera nuevos tokens y rota el hash en DB.
  // Patrón de rotación: cada uso del refresh token genera uno nuevo e invalida el anterior.
  async refreshTokens(
    userId: number,
    rawRefreshToken: string,
  ): Promise<{ access_token: string; refresh_token: string }> {
    const usuario = await this.usuariosRepository.findOne({
      where: { id: userId },
    });

    // Si no hay usuario o no tiene refresh token activo → sesión inválida
    if (!usuario || !usuario.refresh_token_hash) {
      throw new ForbiddenException('Acceso denegado');
    }

    // Comparar el token recibido contra el hash almacenado
    const matches = await bcrypt.compare(
      rawRefreshToken,
      usuario.refresh_token_hash,
    );
    if (!matches) throw new ForbiddenException('Refresh token inválido');

    const payload: JwtPayload = {
      sub: usuario.id,
      email: usuario.email,
      tenant_id: usuario.tenant_id,
      rol: usuario.rol,
    };

    const tokens = this.generateTokens(payload);

    // Rotar: guardar el nuevo hash, invalidando el refresh token anterior
    const newRefreshHash = await bcrypt.hash(tokens.refresh_token, 10);
    await this.usuariosRepository.update(userId, {
      refresh_token_hash: newRefreshHash,
    });

    return tokens;
  }

  // Invalida la sesión limpiando el refresh token de la BD.
  async logout(userId: number): Promise<{ message: string }> {
    await this.usuariosRepository.update(userId, { refresh_token_hash: null });
    return { message: 'Sesión cerrada correctamente' };
  }

  // Genera access token (JWT_SECRET) y refresh token (JWT_REFRESH_SECRET) de forma síncrona.
  // Separados en dos firmas para poder invalidarlos de forma independiente.
  private generateTokens(payload: JwtPayload): {
    access_token: string;
    refresh_token: string;
  } {
    const access_token = this.jwtService.sign(payload);
    // El refresh token usa su propio secreto y expiración — override de los defaults del módulo
    const refresh_token = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_REFRESH_SECRET') as string,
      expiresIn: (
        this.configService.get<string>('JWT_REFRESH_EXPIRES_IN') || '7d'
      ) as any,
    });

    return { access_token, refresh_token };
  }
}
