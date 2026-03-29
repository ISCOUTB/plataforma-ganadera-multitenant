import { Entity, Column, ManyToOne } from 'typeorm';
import { Finca } from '../../fincas/entities/finca.entity';
import { Potrero } from '../../potreros/entities/potrero.entity';
import { BaseEntity } from '../../common/entities/base.entity';

// Animal extiende BaseEntity (Grupo A):
//   - PK: id (number, auto-gen) — sustituye a pk_id_bovino
//   - Auditoría + tenant: tenant_id, created_at, updated_at, deleted_at, created_by, updated_by
//   - creado_en y actualizado_en ELIMINADOS (reemplazados por created_at/updated_at de BaseEntity)
@Entity('bovinos')
export class Animal extends BaseEntity {
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
  @ManyToOne(() => Finca, (finca) => finca.animales)
  finca: Finca;

  @ManyToOne(() => Potrero, (potrero) => potrero.animales, { nullable: true })
  potrero: Potrero;
}
