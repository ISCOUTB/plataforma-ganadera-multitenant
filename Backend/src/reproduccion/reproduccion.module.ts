import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Reproduccion } from './entities/reproduccion.entity';
import { ReproduccionService } from './reproduccion.service';
import { ReproduccionController } from './reproduccion.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Reproduccion])],
  providers: [ReproduccionService],
  controllers: [ReproduccionController],
  exports: [ReproduccionService],
})
export class ReproduccionModule {}
