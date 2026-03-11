import { Entity, Column, PrimaryColumn, ManyToOne, OneToMany, CreateDateColumn } from 'typeorm';
import { Finca } from '../../fincas/entities/finca.entity';
import { Animal } from '../../animales/entities/animal.entity';

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

  // Relaciones
  @ManyToOne(() => Finca, finca => finca.potreros)
  finca: Finca;

  @OneToMany(() => Animal, animal => animal.potrero)
  animales: Animal[];

  @CreateDateColumn()
  creado_en: Date;
}