import { Module } from '@nestjs/common';
import { FincasService } from './fincas.service';

@Module({
  providers: [FincasService]
})
export class FincasModule {}
