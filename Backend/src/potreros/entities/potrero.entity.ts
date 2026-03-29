import {
  Entity,
  Column,
  PrimaryColumn,
  ManyToOne,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Finca } from '../../fincas/entities/finca.entity';
import { Animal } from '../../animales/entities/animal.entity';

// Potrero — PK string manual (Grupo B): conserva pk_id_potrero.
// Columnas de auditoría y tenant agregadas inline.
@Entity('potreros')
export class Potrero {
  @PrimaryColumn({ length: 15 })
  pk_id_potrero: string;

  @Column({ length: 100 })
  nombre_potrero: string;

  @Column('decimal', { nullable: true })
  area: number;

  @Column('int')
  capacidad_animales: number;

  @Column({ length: 30, nullable: true })
  estado: string;

  @Column('date', { nullable: true })
  fecha_rotacion: Date;

  @Column('date', { nullable: true })
  fecha_proxima_rotacion: Date;

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

  // Relaciones
  @ManyToOne(() => Finca, (finca) => finca.potreros)
  finca: Finca;

  @OneToMany(() => Animal, (animal) => animal.potrero)
  animales: Animal[];
}
