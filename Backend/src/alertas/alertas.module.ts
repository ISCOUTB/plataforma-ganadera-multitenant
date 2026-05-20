import { Module } from '@nestjs/common';
import { SaludModule } from '../salud/salud.module';
import { ReproduccionModule } from '../reproduccion/reproduccion.module';
import { AlertasService } from './alertas.service';
import { AlertasController } from './alertas.controller';

@Module({
  imports: [SaludModule, ReproduccionModule],
  providers: [AlertasService],
  controllers: [AlertasController],
})
export class AlertasModule {}
