import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Animal } from './entities/animal.entity';
import { AnimalesService } from './animales.service';
import { AnimalesController } from './animales.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Animal])],
  controllers: [AnimalesController],
  providers: [AnimalesService],
  exports: [AnimalesService],
})
export class AnimalesModule {}
