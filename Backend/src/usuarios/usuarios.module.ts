import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Usuario } from './entities/usuario.entity';
import { UsuariosService } from './usuarios.service';
import { UsuariosController } from './usuarios.controller';
import { AuthModule } from '../auth/auth.module';

// UsuariosModule — gestión de usuarios (CRUD).
// La autenticación (login, tokens, refresh) vive en AuthModule.
//
// UsuariosModule importa AuthModule (sin dependencia recíproca) para:
//   1. Exponer AuthService en UsuariosController (stubs de compatibilidad hacia /usuarios/login)
//   2. Usar JwtAuthGuard en GET /usuarios (la estrategia se registra en Passport via AuthModule)
@Module({
  imports: [
    TypeOrmModule.forFeature([Usuario]),
    // AuthModule exporta AuthService → disponible para inyectar en UsuariosController.
    // No circular: AuthModule NO importa UsuariosModule.
    AuthModule,
  ],
  controllers: [UsuariosController],
  providers: [UsuariosService],
  exports: [UsuariosService],
})
export class UsuariosModule {}
