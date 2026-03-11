import { Entity, Column, PrimaryColumn, ManyToOne, CreateDateColumn } from 'typeorm';
import { Animal } from '../../animales/entities/animal.entity';

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

  // Relación con Animal
  @ManyToOne(() => Animal, animal => animal.reproducciones)
  bovino: Animal;

  @CreateDateColumn()
  creado_en: Date;
}