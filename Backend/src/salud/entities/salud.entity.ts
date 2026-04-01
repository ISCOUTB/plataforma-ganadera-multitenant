import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { Animal } from '../../animales/entities/animal.entity';

@Entity('salud')
export class Salud extends BaseEntity {
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

  @ManyToOne(() => Animal, { nullable: true })
  @JoinColumn({ name: 'fk_id_bovino' })
  animal: Animal;
}
