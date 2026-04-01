import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Finanza } from './entities/finanza.entity';
import { Finca } from '../fincas/entities/finca.entity';
import { BaseRepository } from '../common/repositories/base.repository';
import { CreateFinanzaDto } from './dto/create-finanza.dto';
import { UpdateFinanzaDto } from './dto/update-finanza.dto';
import { FilterFinanzasDto } from './dto/filter-finanzas.dto';
import { PaginatedResult } from '../common/interfaces/paginated-result.interface';

@Injectable()
export class FinanzasService {
  protected baseRepo: BaseRepository<Finanza>;

  constructor(
    @InjectRepository(Finanza)
    private readonly finanzaRepository: Repository<Finanza>,
    @InjectRepository(Finca)
    private readonly fincaRepository: Repository<Finca>,
  ) {
    this.baseRepo = new BaseRepository(finanzaRepository);
  }

  async create(dto: CreateFinanzaDto, tenantId: string, userId: number): Promise<Finanza> {
    if (dto.fincaId) {
      await this.validateFinca(dto.fincaId, tenantId);
    }
    return this.baseRepo.createWithTenant(dto as any, tenantId, userId);
  }

  findAll(tenantId: string): Promise<Finanza[]> {
    return this.baseRepo.findAll(tenantId);
  }

  findAllPaginated(
    tenantId: string,
    filters: FilterFinanzasDto,
  ): Promise<PaginatedResult<Finanza>> {
    const { page, limit, sortBy, sortOrder, tipo_movimiento, categoria } = filters;
    const extraWhere: any = {};
    if (tipo_movimiento) extraWhere.tipo_movimiento = tipo_movimiento;
    if (categoria) extraWhere.categoria = categoria;
    return this.baseRepo.findAllPaginated(
      tenantId,
      { page, limit, sortBy, sortOrder },
      extraWhere,
    );
  }

  async findOne(id: string, tenantId: string): Promise<Finanza> {
    const finanza = await this.baseRepo.findOneByIdWithRelations(id, tenantId, ['finca']);
    if (!finanza) throw new NotFoundException(`Finanza "${id}" no encontrada`);
    return finanza;
  }

  async update(id: string, dto: UpdateFinanzaDto, tenantId: string, userId: number): Promise<Finanza> {
    await this.findOne(id, tenantId);
    if (dto.fincaId) {
      await this.validateFinca(dto.fincaId, tenantId);
    }
    const updated = await this.baseRepo.updateWithTenant(id, dto as any, tenantId, userId);
    if (!updated) throw new NotFoundException(`Finanza "${id}" no encontrada`);
    return updated;
  }

  async remove(id: string, tenantId: string): Promise<{ message: string }> {
    await this.findOne(id, tenantId);
    await this.baseRepo.softDelete(id, tenantId);
    return { message: `Finanza "${id}" eliminada correctamente` };
  }

  /**
   * Resumen financiero: totales de ingresos/gastos y balance.
   * Ayuda al ganadero a entender la salud financiera de su operación.
   */
  async getResumen(tenantId: string): Promise<{
    total_ingresos: number;
    total_gastos: number;
    balance: number;
    cantidad_movimientos: number;
  }> {
    const result = await this.finanzaRepository
      .createQueryBuilder('f')
      .select("COALESCE(SUM(CASE WHEN f.tipo_movimiento = 'ingreso' THEN f.monto ELSE 0 END), 0)", 'total_ingresos')
      .addSelect("COALESCE(SUM(CASE WHEN f.tipo_movimiento = 'gasto' THEN f.monto ELSE 0 END), 0)", 'total_gastos')
      .addSelect('COUNT(*)', 'cantidad_movimientos')
      .where('f.tenant_id = :tenantId', { tenantId })
      .andWhere('f.deleted_at IS NULL')
      .getRawOne();

    const total_ingresos = parseFloat(result.total_ingresos) || 0;
    const total_gastos = parseFloat(result.total_gastos) || 0;

    return {
      total_ingresos,
      total_gastos,
      balance: total_ingresos - total_gastos,
      cantidad_movimientos: parseInt(result.cantidad_movimientos, 10) || 0,
    };
  }

  private async validateFinca(fincaId: string, tenantId: string): Promise<void> {
    const finca = await this.fincaRepository.findOne({
      where: { pk_id_finca: fincaId, tenant_id: tenantId, deleted_at: IsNull() },
    });
    if (!finca) {
      throw new BadRequestException(`Finca "${fincaId}" no encontrada en este tenant`);
    }
  }
}
