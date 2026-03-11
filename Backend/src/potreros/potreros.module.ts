import { Module } from '@nestjs/common';
import { PotrerosService } from './potreros.service';

@Module({
  providers: [PotrerosService]
})
export class PotrerosModule {}
