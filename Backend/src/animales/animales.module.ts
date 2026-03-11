import { Module } from '@nestjs/common';
import { AnimalesService } from './animales.service';

@Module({
  providers: [AnimalesService]
})
export class AnimalesModule {}
