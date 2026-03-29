import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Reproduccion } from './entities/reproduccion.entity';
import { BaseRepository } from '../common/repositories/base.repository';

@Injectable()
export class ReproduccionService {
  protected baseRepo: BaseRepository<Reproduccion>;

  constructor(
    @InjectRepository(Reproduccion)
    private readonly reproduccionRepository: Repository<Reproduccion>,
  ) {
    this.baseRepo = new BaseRepository(reproduccionRepository);
  }
}
