import { Module } from '@nestjs/common';
import { ReproduccionService } from './reproduccion.service';
import { ReproduccionController } from './reproduccion.controller';

@Module({
  providers: [ReproduccionService],
  controllers: [ReproduccionController]
})
export class ReproduccionModule {}
