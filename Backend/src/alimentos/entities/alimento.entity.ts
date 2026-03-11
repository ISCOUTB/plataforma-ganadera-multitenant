import { Entity, Column, PrimaryColumn, CreateDateColumn } from 'typeorm';

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

  @CreateDateColumn()
  creado_en: Date;
}