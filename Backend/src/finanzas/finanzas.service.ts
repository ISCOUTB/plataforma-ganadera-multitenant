import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Finanza } from './entities/finanza.entity';
import { BaseRepository } from '../common/repositories/base.repository';

@Injectable()
export class FinanzasService {
  protected baseRepo: BaseRepository<Finanza>;

  constructor(
    @InjectRepository(Finanza)
    private readonly finanzaRepository: Repository<Finanza>,
  ) {
    this.baseRepo = new BaseRepository(finanzaRepository);
  }
}
