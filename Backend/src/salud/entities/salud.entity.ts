import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('salud')
export class Salud {
  @PrimaryGeneratedColumn()
  pk_id_salud: number;

  @Column({ 
    type: 'enum', 
    enum: ['vacunacion', 'vitaminas', 'desparasitacion', 'enfermedad'],
    
  })
  tipo_intervencion: string;

  @Column({ length: 255, nullable: true })
  descripcion_enfermedad: string;

  @Column({ length: 100, nullable: true })
  producto_aplicado: string;

  @Column({ length: 50, nullable: true })
  dosis: string;

  @Column('date', { nullable: true })
  fecha_aplicacion: Date;

  @Column('date', { nullable: true })
  fecha_proxima_aplicacion: Date;

  @Column('decimal', { nullable: true })
  costo: number;

  @CreateDateColumn()
  creado_en: Date;
}