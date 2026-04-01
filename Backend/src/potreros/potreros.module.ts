import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Potrero } from './entities/potrero.entity';
import { Animal } from '../animales/entities/animal.entity';
import { Finca } from '../fincas/entities/finca.entity';
import { PotrerosService } from './potreros.service';
import { PotrerosController } from './potreros.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Potrero, Animal, Finca])],
  controllers: [PotrerosController],
  providers: [PotrerosService],
  exports: [PotrerosService],
})
export class PotrerosModule {}
