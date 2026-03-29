import {
  Entity,
  Column,
  PrimaryColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

// Finanza — PK string manual (Grupo B): conserva pk_id_finanza.
// Columnas de auditoría y tenant agregadas inline.
// TODO (Fase 4): agregar @ManyToOne(() => Finca) para ligar cada movimiento
// financiero a la finca (tenant) correspondiente.
@Entity('finanzas')
export class Finanza {
  @PrimaryColumn({ length: 15 })
  pk_id_finanza: string;

  @Column({
    type: 'enum',
    enum: ['ingreso', 'gasto'],
  })
  tipo_movimiento: string;

  @Column({ length: 200, nullable: true })
  concepto: string;

  @Column({ length: 50, nullable: true })
  categoria: string;

  @Column('decimal')
  monto: number;

  @Column('date')
  fecha: Date;

  @Column({ length: 100, nullable: true })
  factura: string;

  @Column({ length: 30, nullable: true })
  metodo_pago: string;

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
