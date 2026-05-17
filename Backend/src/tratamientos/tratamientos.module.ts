import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Tratamiento, SeguimientoTratamiento } from './entities/tratamiento.entity';
import { TratamientosService } from './tratamientos.service';
import { TratamientosController } from './tratamientos.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Tratamiento, SeguimientoTratamiento])],
  controllers: [TratamientosController],
  providers: [TratamientosService],
  exports: [TratamientosService],
})
export class TratamientosModule {}
