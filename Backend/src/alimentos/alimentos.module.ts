import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AlimentosController } from './alimentos.controller';
import { AlimentosService } from './alimentos.service';
import { Alimento } from './entities/alimento.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Alimento])],
  controllers: [AlimentosController],  // ✅ ESTO DEBE ESTAR
  providers: [AlimentosService],
})
export class AlimentosModule {}