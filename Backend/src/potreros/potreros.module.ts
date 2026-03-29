import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Potrero } from './entities/potrero.entity';
import { PotrerosService } from './potreros.service';

@Module({
  imports: [TypeOrmModule.forFeature([Potrero])],
  providers: [PotrerosService],
  exports: [PotrerosService],
})
export class PotrerosModule {}
