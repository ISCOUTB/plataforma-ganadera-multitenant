import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AiController } from './ai.controller';
import { AiService } from './ai.service';
import { Animal } from '../animales/entities/animal.entity';
import { Salud } from '../salud/entities/salud.entity';
import { Reproduccion } from '../reproduccion/entities/reproduccion.entity';
import { Finanza } from '../finanzas/entities/finanza.entity';
import { Potrero } from '../potreros/entities/potrero.entity';
import { AnimalesModule } from '../animales/animales.module';
import { SaludModule } from '../salud/salud.module';
import { ReproduccionModule } from '../reproduccion/reproduccion.module';
import { FinanzasModule } from '../finanzas/finanzas.module';
import { PotrerosModule } from '../potreros/potreros.module';

@Module({
  imports: [
    HttpModule,
    TypeOrmModule.forFeature([Animal, Salud, Reproduccion, Finanza, Potrero]),
    AnimalesModule,
    SaludModule,
    ReproduccionModule,
    FinanzasModule,
    PotrerosModule,
  ],
  controllers: [AiController],
  providers: [AiService],
  exports: [AiService],
})
export class AiModule {}
