import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Alimento } from './entities/alimento.entity';
import { BaseRepository } from '../common/repositories/base.repository';

@Injectable()
export class AlimentosService {
  protected baseRepo: BaseRepository<Alimento>;

  constructor(
    @InjectRepository(Alimento)
    private readonly alimentoRepository: Repository<Alimento>,
  ) {
    this.baseRepo = new BaseRepository(alimentoRepository);
  }

  // CORRECCIÓN DE VIOLACIÓN: filtrado por tenant_id obligatorio.
  // tenantId proviene de @Tenant() en el controller (guard-injected desde JWT).
  findAll(tenantId: string): Promise<Alimento[]> {
    return this.baseRepo.findAll(tenantId);
  }
}
