import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { Usuario } from '../usuarios/entities/usuario.entity';
import { JwtStrategy } from './strategies/jwt.strategy';
import { JwtRefreshStrategy } from './strategies/jwt-refresh.strategy';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';

// AuthModule es completamente independiente de UsuariosModule.
// AuthService inyecta Repository<Usuario> directamente para evitar
// dependencia circular (AuthModule ↔ UsuariosModule).
//
// Árbol de dependencias:
//   AppModule → AuthModule       (registra JwtStrategy globalmente en Passport)
//   AppModule → UsuariosModule → AuthModule (para obtener AuthService en los stubs)
@Module({
  imports: [
    PassportModule,
    // ConfigModule es global (isGlobal: true en AppModule) → ConfigService inyectable
    // sin importar ConfigModule aquí de nuevo.
    JwtModule.registerAsync({
      useFactory: (configService: ConfigService) => ({
        // Secret y expiración del ACCESS token (JWT_SECRET, JWT_EXPIRES_IN)
        secret: configService.get<string>('JWT_SECRET') as string,
        signOptions: {
          expiresIn: (configService.get<string>('JWT_EXPIRES_IN') || '1d') as any,
        },
      }),
      inject: [ConfigService],
    }),
    // Repository<Usuario> necesario para AuthService (registro, login, refresh, logout)
    // TypeORM permite forFeature([Usuario]) en múltiples módulos sin conflicto.
    TypeOrmModule.forFeature([Usuario]),
  ],
  providers: [JwtStrategy, JwtRefreshStrategy, AuthService],
  controllers: [AuthController],
  // JwtModule exportado para que módulos que importen AuthModule puedan
  // usar JwtService si lo necesitan.
  // AuthService exportado para los stubs de compatibilidad en UsuariosController.
  exports: [JwtModule, AuthService],
})
export class AuthModule {}
