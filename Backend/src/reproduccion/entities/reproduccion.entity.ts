import {
  Entity,
  Column,
  PrimaryColumn,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Animal } from '../../animales/entities/animal.entity';

// Reproduccion — PK string manual (Grupo B): conserva pk_id_reproduccion.
// Columnas de auditoría y tenant agregadas inline.
// NOTA: La relación ManyToOne a Animal usa solo la referencia directa (sin
// inverse) porque Animal.reproducciones no está decorado con @OneToMany.
@Entity('reproduccion')
export class Reproduccion {
  @PrimaryColumn({ length: 15 })
  pk_id_reproduccion: string;

  @Column({ length: 15, nullable: true })
  fk_id_padre: string;

  @Column({ length: 15, nullable: true })
  fk_id_madre: string;

  @Column({ length: 30, nullable: true })
  metodo_reproduccion: string;

  @Column({ default: false })
  en_celo: boolean;

  @Column({ default: false })
  preñada: boolean;

  @Column('int', { nullable: true })
  numero_crias: number;

  @Column('date', { nullable: true })
  fecha_estimado_parto: Date;

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

  // Relación con Animal (sin inverse — Animal no declara @OneToMany a Reproduccion)
  @ManyToOne(() => Animal)
  bovino: Animal;
}
