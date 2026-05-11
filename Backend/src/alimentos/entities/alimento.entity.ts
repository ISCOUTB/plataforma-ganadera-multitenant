import {
  Entity,
  Column,
  PrimaryColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

// Alimento — PK string manual (Grupo B): conserva pk_id_alimento.
// Columnas de auditoría y tenant agregadas inline.
@Entity('alimento')
export class Alimento {
  @PrimaryColumn({ length: 15 })
  pk_id_alimento: string;

  @Column({ length: 100 })
  tipo_alimento: string;

  @Column('decimal', { nullable: true })
  cantidad_total: number;

  @Column({ length: 50, nullable: true })
  frecuencia: string;

  @Column('date', { nullable: true })
  fecha_inicio: Date;

  @Column('date', { nullable: true })
  fecha_fin_estimada: Date;

  @Column('decimal', { nullable: true })
  costo: number;

  // --- Multitenant & Auditoría ---
  @Column({ type: 'varchar', nullable: true })
  tenant_id: string | null;

  @Column({ type: 'timestamp', nullable: true, default: null })
  deleted_at: Date | null;

  @Column({ type: 'int', nullable: true, default: null })
  created_by: number | null;

  @Column({ type: 'int', nullable: true, default: null })
  updated_by: number | null;

  @CreateDateColumn()
  creado_en: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updated_at: Date;
}
