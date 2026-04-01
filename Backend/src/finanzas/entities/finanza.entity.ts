import {
  Entity,
  Column,
  PrimaryColumn,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Finca } from '../../fincas/entities/finca.entity';
import { Animal } from '../../animales/entities/animal.entity';

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

  @ManyToOne(() => Finca, { nullable: true })
  @JoinColumn({ name: 'fk_id_finca' })
  finca: Finca;

  @ManyToOne(() => Animal, { nullable: true })
  @JoinColumn({ name: 'fk_id_bovino' })
  animal: Animal;
}
