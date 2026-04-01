import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BovinoAlimento } from './entities/bovino-alimento.entity';
import { Animal } from '../animales/entities/animal.entity';
import { Alimento } from '../alimentos/entities/alimento.entity';
import { BovinoAlimentoService } from './bovino-alimento.service';
import { BovinoAlimentoController } from './bovino-alimento.controller';

@Module({
  imports: [TypeOrmModule.forFeature([BovinoAlimento, Animal, Alimento])],
  providers: [BovinoAlimentoService],
  controllers: [BovinoAlimentoController],
  exports: [BovinoAlimentoService],
})
export class BovinoAlimentoModule {}
