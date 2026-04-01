import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Animal } from './entities/animal.entity';
import { Finca } from '../fincas/entities/finca.entity';
import { Potrero } from '../potreros/entities/potrero.entity';
import { AnimalesService } from './animales.service';
import { AnimalesController } from './animales.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Animal, Finca, Potrero])],
  controllers: [AnimalesController],
  providers: [AnimalesService],
  exports: [AnimalesService],
})
export class AnimalesModule {}
