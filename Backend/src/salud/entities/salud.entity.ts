import { Entity, Column } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';

// Salud extiende BaseEntity (Grupo A):
//   - PK: id (number, auto-gen) — sustituye a pk_id_salud
//   - Auditoría + tenant: tenant_id, created_at, updated_at, deleted_at, created_by, updated_by
//   - creado_en ELIMINADO (reemplazado por created_at de BaseEntity)
// TODO (Fase 4): agregar @ManyToOne(() => Animal) para ligar cada registro
// de salud al animal correspondiente.
@Entity('salud')
export class Salud extends BaseEntity {
  @Column({
    type: 'enum',
    enum: ['vacunacion', 'vitaminas', 'desparasitacion', 'enfermedad'],
  })
  tipo_intervencion: string;

  @Column({ length: 255, nullable: true })
  descripcion_enfermedad: string;

  @Column({ length: 100, nullable: true })
  producto_aplicado: string;

  @Column({ length: 50, nullable: true })
  dosis: string;

  @Column('date', { nullable: true })
  fecha_aplicacion: Date;

  @Column('date', { nullable: true })
  fecha_proxima_aplicacion: Date;

  @Column('decimal', { nullable: true })
  costo: number;
}
