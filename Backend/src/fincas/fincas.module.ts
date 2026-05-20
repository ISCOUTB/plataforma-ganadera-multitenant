import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Finca } from './entities/finca.entity';
import { Animal } from '../animales/entities/animal.entity';
import { Potrero } from '../potreros/entities/potrero.entity';
import { FincasService } from './fincas.service';
import { FincasController } from './fincas.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Finca, Animal, Potrero])],
  controllers: [FincasController],
  providers: [FincasService],
  exports: [FincasService],
})
export class FincasModule {}
