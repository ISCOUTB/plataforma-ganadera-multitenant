import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Alimento } from './entities/alimento.entity';

@Injectable()
export class AlimentosService {
  constructor(
    @InjectRepository(Alimento)
    private alimentoRepository: Repository<Alimento>,
  ) {}

  findAll() {
    return this.alimentoRepository.find();
  }
}