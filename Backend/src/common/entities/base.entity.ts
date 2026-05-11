import {
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

// BaseEntity — abstract base para entidades con PK numérica auto-generada.
// NO lleva @Entity() → no crea tabla propia; TypeORM hereda sus columnas
// en cada entidad concreta que la extienda.
//
// Entidades que extienden esto (Grupo A): Animal, Salud.
// Entidades con PK string manual (Finca, Potrero, etc.) agregan estas
// columnas inline para evitar conflicto de tipo en la PK.
//
// Columnas incluidas:
//   id           — PK auto-generada
//   tenant_id    — aislamiento multitenant; se puebla desde el JWT (NUNCA del cliente)
//   created_at   — timestamp de creación (automático)
//   updated_at   — timestamp de última modificación (automático)
//   deleted_at   — soft delete; null = activo, timestamp = eliminado
//   created_by   — userId del creador (se pasa desde el controller vía @CurrentUser)
//   updated_by   — userId del último editor
export abstract class BaseEntity {
  @PrimaryGeneratedColumn()
  id: number;

  // nullable: true — en Fase 0-2 el tenant aún no es obligatorio en todos los flujos.
  // Fase 4 lo hará NOT NULL con FK a Finca.
  @Column({ type: 'varchar', nullable: true })
  tenant_id: string | null;

  @CreateDateColumn({ name: 'created_at' })
  created_at: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updated_at: Date;

  // Soft delete: BaseRepository.softDelete() pone deleted_at = NOW().
  // BaseRepository.findAll() y findOneById() siempre filtran deleted_at IS NULL.
  @Column({ type: 'timestamp', nullable: true, default: null })
  deleted_at: Date | null;

  // Auditoría — quién creó/modificó el registro.
  // Se puebla en BaseRepository.createWithTenant() y updateWithTenant().
  @Column({ type: 'int', nullable: true, default: null })
  created_by: number | null;

  @Column({ type: 'int', nullable: true, default: null })
  updated_by: number | null;
}
