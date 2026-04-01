import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MovimientoAnimal } from './entities/movimiento-animal.entity';
import { Animal } from '../animales/entities/animal.entity';
import { Potrero } from '../potreros/entities/potrero.entity';
import { MovimientosService } from './movimientos.service';
import { MovimientosController } from './movimientos.controller';

@Module({
  imports: [TypeOrmModule.forFeature([MovimientoAnimal, Animal, Potrero])],
  providers: [MovimientosService],
  controllers: [MovimientosController],
  exports: [MovimientosService],
})
export class MovimientosModule {}
