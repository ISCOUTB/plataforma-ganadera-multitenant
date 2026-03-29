import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Potrero } from './entities/potrero.entity';
import { BaseRepository } from '../common/repositories/base.repository';

@Injectable()
export class PotrerosService {
  protected baseRepo: BaseRepository<Potrero>;

  constructor(
    @InjectRepository(Potrero)
    private readonly potreroRepository: Repository<Potrero>,
  ) {
    this.baseRepo = new BaseRepository(potreroRepository);
  }
}
