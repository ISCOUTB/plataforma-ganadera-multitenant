import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Animal } from '../animales/entities/animal.entity';
import { Finca } from '../fincas/entities/finca.entity';
import { Potrero } from '../potreros/entities/potrero.entity';
import { Salud } from '../salud/entities/salud.entity';
import { Finanza } from '../finanzas/entities/finanza.entity';
import { Reproduccion } from '../reproduccion/entities/reproduccion.entity';
import { BovinoAlimento } from '../bovino-alimento/entities/bovino-alimento.entity';
import { Alimento } from '../alimentos/entities/alimento.entity';
import { MovimientoAnimal } from '../movimientos/entities/movimiento-animal.entity';
import { DashboardService } from './dashboard.service';
import { DashboardController } from './dashboard.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([Animal, Finca, Potrero, Salud, Finanza, Reproduccion, BovinoAlimento, Alimento, MovimientoAnimal]),
  ],
  providers: [DashboardService],
  controllers: [DashboardController],
})
export class DashboardModule {}
