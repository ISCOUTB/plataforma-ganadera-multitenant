import {
  Entity,
  Column,
  PrimaryColumn,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Animal } from '../../animales/entities/animal.entity';
import { Potrero } from '../../potreros/entities/potrero.entity';

// Finca — PK string manual (Grupo B): conserva pk_id_finca para no romper FKs.
// Columnas de auditoría y tenant agregadas inline.
@Entity('finca')
export class Finca {
  @PrimaryColumn({ length: 15 })
  pk_id_finca: string;

  @Column({ length: 100 })
  nombre_finca: string;

  @Column({ length: 150, nullable: true })
  ubicacion: string;

  @Column({ length: 100, nullable: true })
  propietario: string;

  @Column('decimal', { nullable: true })
  area_total: number;

  @Column('date', { nullable: true })
  fecha_registro: Date;

  // --- Multitenant & Auditoría ---
  // tenant_id identifica la finca como el tenant raíz. En Fase 4 se añadirá
  // la FK entre Usuario y Finca para completar el aislamiento.
  @Column({ type: 'varchar', nullable: true })
  tenant_id: string | null;

  // Soft delete: BaseRepository.softDelete() pone deleted_at = NOW().
  @Column({ type: 'timestamp', nullable: true, default: null })
  deleted_at: Date | null;

  @Column({ type: 'int', nullable: true, default: null })
  created_by: number | null;

  @Column({ type: 'int', nullable: true, default: null })
  updated_by: number | null;

  // creado_en se conserva (ya existe en DB); updated_at se agrega nuevo.
  @CreateDateColumn()
  creado_en: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updated_at: Date;

  // Relaciones
  @OneToMany(() => Animal, (animal) => animal.finca)
  animales: Animal[];

  @OneToMany(() => Potrero, (potrero) => potrero.finca)
  potreros: Potrero[];
}
