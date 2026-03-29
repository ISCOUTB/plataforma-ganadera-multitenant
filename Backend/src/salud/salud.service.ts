import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Salud } from './entities/salud.entity';
import { BaseRepository } from '../common/repositories/base.repository';

@Injectable()
export class SaludService {
  // Salud extiende BaseEntity → id: number.
  protected baseRepo: BaseRepository<Salud>;

  constructor(
    @InjectRepository(Salud)
    private readonly saludRepository: Repository<Salud>,
  ) {
    this.baseRepo = new BaseRepository(saludRepository);
  }
}
