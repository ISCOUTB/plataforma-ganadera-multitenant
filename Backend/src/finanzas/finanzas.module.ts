import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Finanza } from './entities/finanza.entity';
import { Finca } from '../fincas/entities/finca.entity';
import { FinanzasService } from './finanzas.service';
import { FinanzasController } from './finanzas.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Finanza, Finca])],
  providers: [FinanzasService],
  controllers: [FinanzasController],
  exports: [FinanzasService],
})
export class FinanzasModule {}
