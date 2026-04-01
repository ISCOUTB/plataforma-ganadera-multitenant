import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';
import { RolesGuard } from './common/guards/roles.guard';
import { TenantGuard } from './common/guards/tenant.guard';
import { Usuario } from './usuarios/entities/usuario.entity';
import { Finca } from './fincas/entities/finca.entity';
import { Animal } from './animales/entities/animal.entity';
import { Potrero } from './potreros/entities/potrero.entity';
import { Alimento } from './alimentos/entities/alimento.entity';
import { Salud } from './salud/entities/salud.entity';
import { Reproduccion } from './reproduccion/entities/reproduccion.entity';
import { Finanza } from './finanzas/entities/finanza.entity';
import { BovinoAlimento } from './bovino-alimento/entities/bovino-alimento.entity';
import { FincasModule } from './fincas/fincas.module';
import { AnimalesModule } from './animales/animales.module';
import { PotrerosModule } from './potreros/potreros.module';
import { AlimentosModule } from './alimentos/alimentos.module';
import { SaludModule } from './salud/salud.module';
import { ReproduccionModule } from './reproduccion/reproduccion.module';
import { FinanzasModule } from './finanzas/finanzas.module';
import { UsuariosModule } from './usuarios/usuarios.module';
import { AuthModule } from './auth/auth.module';
import { BovinoAlimentoModule } from './bovino-alimento/bovino-alimento.module';
import { MovimientoAnimal } from './movimientos/entities/movimiento-animal.entity';
import { MovimientosModule } from './movimientos/movimientos.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { AlertasModule } from './alertas/alertas.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST'),
        // ConfigService devuelve string desde .env — TypeORM espera number para port.
        // El prefijo '+' convierte '5433' → 5433.
        port: +configService.get<string>('DB_PORT', '5433'),
        username: configService.get('DB_USERNAME'),
        password: configService.get('DB_PASSWORD'),
        database: configService.get('DB_DATABASE'),
        // Lista global de entidades para que TypeORM conozca el esquema.
        // Cada módulo de dominio registra su propio Repository vía
        // TypeOrmModule.forFeature([...]) dentro de su propio módulo.
        entities: [
          Usuario, Finca, Animal, Potrero,
          Alimento, Salud, Reproduccion, Finanza,
          BovinoAlimento,
          MovimientoAnimal
        ],
        // NOTA: synchronize:true aplica cambios de esquema automáticamente al
        // arrancar. Conveniente en desarrollo, peligroso en producción.
        // Se reemplazará por migraciones explícitas en Fase 2.
        synchronize: true,
      }),
      inject: [ConfigService],
    }),
    // NOTA (Fase 0 - saneamiento): Se eliminó el bloque TypeOrmModule.forFeature([...])
    // que existía aquí. Ese bloque registraba repositories en AppModule sin que
    // ningún service los consumiera directamente en este nivel. Cada módulo de
    // dominio (FincasModule, AnimalesModule, etc.) debe registrar sus propios
    // repositories con forFeature() dentro de su propio archivo *.module.ts.
    // AuthModule registra JwtStrategy globalmente para todos los módulos
    AuthModule,
    FincasModule,
    AnimalesModule,
    PotrerosModule,
    AlimentosModule,
    SaludModule,
    ReproduccionModule,
    FinanzasModule,
    UsuariosModule,
    BovinoAlimentoModule,
    MovimientosModule,
    DashboardModule,
    AlertasModule,
  ],
  // APP_GUARD registra guards globalmente — se ejecutan en orden de declaración
  // en TODAS las rutas. Las rutas públicas usan @Public() para eximirse.
  //
  // Orden garantizado:
  //   1. JwtAuthGuard  — valida el access token y puebla request.user
  //   2. RolesGuard    — verifica @Roles() usando request.user.rol
  //   3. TenantGuard   — inyecta req.tenantId y valida aislamiento multitenant
  providers: [
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
    { provide: APP_GUARD, useClass: TenantGuard },
  ],
})
export class AppModule {}
