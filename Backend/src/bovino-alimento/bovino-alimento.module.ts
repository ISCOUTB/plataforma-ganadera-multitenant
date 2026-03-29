import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BovinoAlimento } from './entities/bovino-alimento.entity';

// BovinoAlimentoModule — registra la entidad de unión N:N para que
// otros módulos puedan inyectar Repository<BovinoAlimento> si lo necesitan.
// Fase 4 agregará servicio y controller para gestionar raciones de alimento.
@Module({
  imports: [TypeOrmModule.forFeature([BovinoAlimento])],
  exports: [TypeOrmModule],
})
export class BovinoAlimentoModule {}
