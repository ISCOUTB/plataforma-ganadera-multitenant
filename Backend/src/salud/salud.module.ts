import { Module } from '@nestjs/common';
import { SaludService } from './salud.service';
import { SaludController } from './salud.controller';

@Module({
  providers: [SaludService],
  controllers: [SaludController]
})
export class SaludModule {}
