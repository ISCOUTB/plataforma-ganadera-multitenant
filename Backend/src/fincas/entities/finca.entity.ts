import { Entity, Column, PrimaryColumn, OneToMany, CreateDateColumn } from 'typeorm';
import { Animal } from '../../animales/entities/animal.entity';
import { Potrero } from '../../potreros/entities/potrero.entity';

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

  // Relaciones
  @OneToMany(() => Animal, animal => animal.finca)
  animales: Animal[];

  @OneToMany(() => Potrero, potrero => potrero.finca)
  potreros: Potrero[];

  @CreateDateColumn()
  creado_en: Date;
}