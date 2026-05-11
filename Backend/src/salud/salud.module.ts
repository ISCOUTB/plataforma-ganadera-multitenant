import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Salud } from './entities/salud.entity';
import { Animal } from '../animales/entities/animal.entity';
import { SaludService } from './salud.service';
import { SaludController } from './salud.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Salud, Animal])],
  providers: [SaludService],
  controllers: [SaludController],
  exports: [SaludService],
})
export class SaludModule {}
