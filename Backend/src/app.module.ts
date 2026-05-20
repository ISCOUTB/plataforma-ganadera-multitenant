import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
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
import { AdminModule } from './admin/admin.module';
import { VeterinariosModule } from './veterinarios/veterinarios.module';
import { CitasModule } from './citas/citas.module';
import { TratamientosModule } from './tratamientos/tratamientos.module';
import { Veterinario } from './veterinarios/entities/veterinario.entity';
import { Cita } from './citas/entities/cita.entity';
import { Tratamiento, SeguimientoTratamiento } from './tratamientos/entities/tratamiento.entity';
import { AiModule } from './ai/ai.module';

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
        port: +configService.get<string>('DB_PORT', '5433'),
        username: configService.get('DB_USERNAME'),
        password: configService.get('DB_PASSWORD'),
        database: configService.get('DB_DATABASE'),
        entities: [
          Usuario, Finca, Animal, Potrero,
          Alimento, Salud, Reproduccion, Finanza,
          BovinoAlimento, MovimientoAnimal,
          Veterinario, Cita, Tratamiento, SeguimientoTratamiento
        ],
        synchronize: false,
        migrations: ['dist/migrations/*.js'],
        migrationsRun: true,
        migrationsTableName: 'typeorm_migrations',
      }),
      inject: [ConfigService],
    }),
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
    AdminModule,
    VeterinariosModule,
    CitasModule,
    TratamientosModule,
    AiModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
    { provide: APP_GUARD, useClass: TenantGuard },
  ],
})
export class AppModule {}