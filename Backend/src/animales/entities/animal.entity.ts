import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { Finca } from '../../fincas/entities/finca.entity';
import { Potrero } from '../../potreros/entities/potrero.entity';

@Entity('bovinos')  // Nombre de tabla como en tu esquema
export class Animal {
  @PrimaryGeneratedColumn()
  pk_id_bovino: number;  // Cambiar nombre para coincidir

  @Column()
  numero_identificacion: string;

  @Column({ nullable: true })
  metodo_identificacion: string;

  @Column('date')
  fecha_nacimiento: Date;

  @Column({ nullable: true })
  edad_actual: number;

  @Column({ type: 'enum', enum: ['m', 'h', 'n'] })
  genero: string;

  @Column('decimal', { precision: 7, scale: 2 })
  peso: number;

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  altura: number;

  @Column()
  raza: string;

  @Column({ nullable: true })
  origen: string;

  @Column('date', { nullable: true })
  fecha_ingreso: Date;

  @Column('date', { nullable: true })
  fecha_salida: Date;

  @Column({ nullable: true })
  relacion_genealogica: string;

  // Relaciones
  @ManyToOne(() => Finca, finca => finca.animales)
  finca: Finca;

  @ManyToOne(() => Potrero, potrero => potrero.animales, { nullable: true })
  potrero: Potrero;

  @CreateDateColumn()
  creado_en: Date;

  @UpdateDateColumn()
  actualizado_en: Date;
    reproducciones: any;
}