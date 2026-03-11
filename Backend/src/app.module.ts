import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
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
        port: configService.get('DB_PORT'),
        username: configService.get('DB_USERNAME'),
        password: configService.get('DB_PASSWORD'),
        database: configService.get('DB_DATABASE'),
        entities: [
          Usuario, Finca, Animal, Potrero, 
          Alimento, Salud, Reproduccion, Finanza,
          BovinoAlimento
        ],
        synchronize: true,
      }),
      inject: [ConfigService],
    }),
    // Importar módulos de cada entidad
    TypeOrmModule.forFeature([
      Finca, Animal, Potrero, Alimento, 
      Salud, Reproduccion, Finanza, BovinoAlimento
    ]),
    FincasModule,
    AnimalesModule,
    PotrerosModule,
    AlimentosModule,
    SaludModule,
    ReproduccionModule,
    FinanzasModule,
    UsuariosModule,
  ],
})
export class AppModule {}