import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource, IsNull } from 'typeorm';
import { MovimientoAnimal } from './entities/movimiento-animal.entity';
import { Animal } from '../animales/entities/animal.entity';
import { Potrero } from '../potreros/entities/potrero.entity';
import { BaseRepository } from '../common/repositories/base.repository';
import { CreateMovimientoDto } from './dto/create-movimiento.dto';
import { UpdateMovimientoDto } from './dto/update-movimiento.dto';
import { FilterMovimientosDto } from './dto/filter-movimientos.dto';
import { PaginatedResult } from '../common/interfaces/paginated-result.interface';

@Injectable()
export class MovimientosService {
  protected baseRepo: BaseRepository<MovimientoAnimal>;

  constructor(
    @InjectRepository(MovimientoAnimal)
    private readonly movimientoRepository: Repository<MovimientoAnimal>,
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
    @InjectRepository(Potrero)
    private readonly potreroRepository: Repository<Potrero>,
    private readonly dataSource: DataSource,
  ) {
    this.baseRepo = new BaseRepository(movimientoRepository);
  }

  /**
   * Mover un animal a otro potrero — TRANSACCIONAL.
   * Valida: animal existe, potrero destino existe, capacidad disponible.
   * Crea registro de movimiento + actualiza potrero del animal atómicamente.
   */
  async moverAnimal(
    dto: CreateMovimientoDto,
    tenantId: string,
    userId: number,
  ): Promise<MovimientoAnimal> {
    return this.dataSource.transaction(async (manager) => {
      // Validar animal
      const animal = await manager.findOne(Animal, {
        where: { id: dto.animalId, tenant_id: tenantId, deleted_at: IsNull() },
        relations: ['potrero'],
      });
      if (!animal)
        throw new NotFoundException(`Animal #${dto.animalId} no encontrado`);

      // Validar potrero origen si se especifica
      if (dto.potreroOrigenId) {
        const origen = await manager.findOne(Potrero, {
          where: {
            pk_id_potrero: dto.potreroOrigenId,
            tenant_id: tenantId,
            deleted_at: IsNull(),
          },
        });
        if (!origen)
          throw new BadRequestException(
            `Potrero origen "${dto.potreroOrigenId}" no encontrado`,
          );
      }

      // Validar potrero destino
      const destino = await manager.findOne(Potrero, {
        where: {
          pk_id_potrero: dto.potreroDestinoId,
          tenant_id: tenantId,
          deleted_at: IsNull(),
        },
      });
      if (!destino)
        throw new BadRequestException(
          `Potrero destino "${dto.potreroDestinoId}" no encontrado`,
        );

      // Validar capacidad del potrero destino
      const ocupacion = await manager.count(Animal, {
        where: {
          potrero: { pk_id_potrero: dto.potreroDestinoId },
          tenant_id: tenantId,
          deleted_at: IsNull(),
        },
      });
      if (ocupacion >= destino.capacidad_animales) {
        throw new BadRequestException(
          `Potrero "${dto.potreroDestinoId}" está lleno (${ocupacion}/${destino.capacidad_animales})`,
        );
      }

      // Registrar el movimiento
      const movimiento = manager.create(MovimientoAnimal, {
        animal: { id: dto.animalId },
        potreroOrigen: dto.potreroOrigenId
          ? { pk_id_potrero: dto.potreroOrigenId }
          : null,
        potreroDestino: { pk_id_potrero: dto.potreroDestinoId },
        fecha: dto.fecha,
        motivo: dto.motivo,
        tenant_id: tenantId,
        created_by: userId,
        updated_by: userId,
      } as any);
      await manager.save(MovimientoAnimal, movimiento);

      // Actualizar el potrero actual del animal
      await manager.update(Animal, { id: dto.animalId, tenant_id: tenantId }, {
        potrero: { pk_id_potrero: dto.potreroDestinoId },
        updated_by: userId,
      } as any);

      return movimiento;
    });
  }

  /**
   * Editar un movimiento existente — TRANSACCIONAL.
   * Si el movimiento es el más reciente del animal y cambia el potrero destino,
   * sincroniza también `Animal.potrero`.
   */
  async update(
    id: number,
    dto: UpdateMovimientoDto,
    tenantId: string,
    userId: number,
  ): Promise<MovimientoAnimal> {
    return this.dataSource.transaction(async (manager) => {
      const movimiento = await manager.findOne(MovimientoAnimal, {
        where: { id, tenant_id: tenantId, deleted_at: IsNull() },
        relations: ['animal', 'potreroDestino'],
      });
      if (!movimiento)
        throw new NotFoundException(`Movimiento #${id} no encontrado`);

      let nuevoDestino: Potrero | null = null;
      if (
        dto.potreroDestinoId &&
        dto.potreroDestinoId !== movimiento.potreroDestino?.pk_id_potrero
      ) {
        nuevoDestino = await manager.findOne(Potrero, {
          where: {
            pk_id_potrero: dto.potreroDestinoId,
            tenant_id: tenantId,
            deleted_at: IsNull(),
          },
        });
        if (!nuevoDestino) {
          throw new BadRequestException(
            `Potrero destino "${dto.potreroDestinoId}" no encontrado`,
          );
        }
      }

      const ultimo = await manager.findOne(MovimientoAnimal, {
        where: {
          animal: { id: movimiento.animal.id },
          tenant_id: tenantId,
          deleted_at: IsNull(),
        },
        order: { fecha: 'DESC', id: 'DESC' },
      });
      const esElUltimo = ultimo?.id === movimiento.id;

      const patch: Record<string, unknown> = { updated_by: userId };
      if (dto.fecha !== undefined) patch.fecha = new Date(dto.fecha);
      if (dto.motivo !== undefined) patch.motivo = dto.motivo;
      if (nuevoDestino) {
        patch.potreroDestino = { pk_id_potrero: nuevoDestino.pk_id_potrero };
      }
      await manager.update(
        MovimientoAnimal,
        { id, tenant_id: tenantId },
        patch as any,
      );

      if (esElUltimo && nuevoDestino) {
        await manager.update(
          Animal,
          { id: movimiento.animal.id, tenant_id: tenantId },
          {
            potrero: { pk_id_potrero: nuevoDestino.pk_id_potrero },
            updated_by: userId,
          } as any,
        );
      }

      const fresco = await manager.findOne(MovimientoAnimal, {
        where: { id, tenant_id: tenantId },
        relations: ['animal', 'potreroOrigen', 'potreroDestino'],
      });
      return fresco!;
    });
  }

  /** Historial de movimientos de un animal */
  async findByAnimal(
    animalId: number,
    tenantId: string,
  ): Promise<MovimientoAnimal[]> {
    return this.movimientoRepository.find({
      where: {
        animal: { id: animalId },
        tenant_id: tenantId,
        deleted_at: IsNull(),
      },
      relations: ['potreroOrigen', 'potreroDestino'],
      order: { fecha: 'DESC' },
    });
  }

  /** Todos los movimientos del tenant */
  findAll(tenantId: string): Promise<MovimientoAnimal[]> {
    return this.baseRepo.findAll(tenantId);
  }

  findAllPaginated(
    tenantId: string,
    filters: FilterMovimientosDto,
  ): Promise<PaginatedResult<MovimientoAnimal>> {
    const { page, limit, sortBy, sortOrder, motivo } = filters;
    const extraWhere: any = {};
    if (motivo) extraWhere.motivo = motivo;
    return this.baseRepo.findAllPaginated(
      tenantId,
      { page, limit, sortBy, sortOrder },
      extraWhere,
    );
  }
}
