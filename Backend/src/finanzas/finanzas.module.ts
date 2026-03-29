import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Finanza } from './entities/finanza.entity';
import { FinanzasService } from './finanzas.service';
import { FinanzasController } from './finanzas.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Finanza])],
  providers: [FinanzasService],
  controllers: [FinanzasController],
  exports: [FinanzasService],
})
export class FinanzasModule {}
