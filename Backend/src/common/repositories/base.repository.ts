import { Repository, FindOptionsWhere, IsNull, DeepPartial } from 'typeorm';

// Interfaz mínima que debe cumplir cualquier entidad para usar BaseRepository.
// No exige extender BaseEntity, por lo que funciona con:
//   - Grupo A: entidades que extienden BaseEntity (Animal, Salud)
//   - Grupo B: entidades con columnas inline (Finca, Potrero, Alimento, etc.)
export interface TenantAuditableEntity {
  tenant_id: string | null;
  deleted_at: Date | null;
  created_by?: number | null;
  updated_by?: number | null;
}

// BaseRepository — repositorio genérico que garantiza:
//   1. Filtrado automático por tenant_id en todas las operaciones de lectura.
//   2. Exclusión de registros con soft-delete (deleted_at IS NOT NULL).
//   3. Población automática de campos de auditoría (created_by, updated_by).
//   4. Soft delete en lugar de hard delete.
//
// Uso en cada service:
//   protected baseRepo: BaseRepository<Finca>;
//   constructor(@InjectRepository(Finca) repo: Repository<Finca>) {
//     this.baseRepo = new BaseRepository(repo);
//   }
//
// REGLA DE SEGURIDAD: NUNCA llamar a this.repo.find() directamente desde
// un service de dominio. Siempre usar los métodos de BaseRepository para
// que el tenant enforcement sea obligatorio.
export class BaseRepository<T extends TenantAuditableEntity> {
  constructor(protected readonly repo: Repository<T>) {}

  // Retorna todos los registros activos (deleted_at IS NULL) del tenant.
  findAll(tenantId: string): Promise<T[]> {
    return this.repo.find({
      where: { tenant_id: tenantId, deleted_at: IsNull() } as FindOptionsWhere<T>,
    });
  }

  // Busca un registro por su PK + tenant_id.
  // Usa TypeORM metadata para detectar el nombre real de la PK en runtime:
  //   - Grupo A (BaseEntity): propertyName = 'id'
  //   - Grupo B (manual):     propertyName = 'pk_id_finca', 'pk_id_alimento', etc.
  // Esto permite que el método sea genérico sin importar la estrategia de PK.
  findOneById(id: number | string, tenantId: string): Promise<T | null> {
    const pkField = this.repo.metadata.primaryColumns[0].propertyName;
    return this.repo.findOne({
      where: {
        [pkField]: id,
        tenant_id: tenantId,
        deleted_at: IsNull(),
      } as FindOptionsWhere<T>,
    });
  }

  // Crea un registro poblando automáticamente tenant_id y auditing.
  // tenantId proviene del JWT validado (@Tenant() en el controller).
  // userId proviene del payload JWT (@CurrentUser('sub') en el controller).
  createWithTenant(
    data: DeepPartial<T>,
    tenantId: string,
    userId: number,
  ): Promise<T> {
    const entity = this.repo.create({
      ...data,
      tenant_id: tenantId,
      created_by: userId,
      updated_by: userId,
    } as DeepPartial<T>);
    return this.repo.save(entity);
  }

  // Actualiza un registro validando que pertenezca al tenant correcto.
  // Retorna el registro actualizado, o null si no existe o pertenece a otro tenant.
  async updateWithTenant(
    id: number | string,
    data: DeepPartial<T>,
    tenantId: string,
    userId: number,
  ): Promise<T | null> {
    const pkField = this.repo.metadata.primaryColumns[0].propertyName;
    await this.repo.update(
      { [pkField]: id, tenant_id: tenantId } as FindOptionsWhere<T>,
      { ...data, updated_by: userId } as any,
    );
    return this.findOneById(id, tenantId);
  }

  // Soft delete: establece deleted_at = NOW() sin eliminar el registro de la DB.
  // Siempre valida que el registro pertenezca al tenant — previene eliminación cruzada.
  async softDelete(id: number | string, tenantId: string): Promise<void> {
    const pkField = this.repo.metadata.primaryColumns[0].propertyName;
    await this.repo.update(
      { [pkField]: id, tenant_id: tenantId } as FindOptionsWhere<T>,
      { deleted_at: new Date() } as any,
    );
  }
}
