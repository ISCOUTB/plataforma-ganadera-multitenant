import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, DeleteDateColumn, ManyToOne, JoinColumn, OneToMany } from 'typeorm';
import { Veterinario } from '../../veterinarios/entities/veterinario.entity';

export enum EstadoTratamiento {
  EN_CURSO = 'en_curso',
  COMPLETADO = 'completado',
  ABANDONADO = 'abandonado',
}

@Entity('tratamientos')
export class Tratamiento {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  fk_id_bovino: number;

  @Column({ length: 255 })
  diagnostico: string;

  @Column({ type: 'date' })
  fecha_inicio: Date;

  @Column({ type: 'date', nullable: true })
  fecha_fin_estimada: Date;

  @Column({ type: 'enum', enum: EstadoTratamiento, default: EstadoTratamiento.EN_CURSO })
  estado: EstadoTratamiento;

  @ManyToOne(() => Veterinario)
  @JoinColumn({ name: 'fk_id_veterinario' })
  veterinario: Veterinario;

  @Column({ nullable: true })
  fk_id_veterinario: number;

  @OneToMany(() => SeguimientoTratamiento, s => s.tratamiento, { cascade: true })
  seguimientos: SeguimientoTratamiento[];

  @Column({ nullable: true })
  tenant_id: string;

  @DeleteDateColumn()
  deleted_at: Date;

  @CreateDateColumn()
  creado_en: Date;

  @UpdateDateColumn()
  updated_at: Date;
}

@Entity('seguimientos_tratamiento')
export class SeguimientoTratamiento {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  fk_id_tratamiento: number;

  @Column({ type: 'text' })
  observacion: string;

  @Column({ length: 150, nullable: true })
  registrado_por: string;

  @ManyToOne(() => Tratamiento, t => t.seguimientos)
  @JoinColumn({ name: 'fk_id_tratamiento' })
  tratamiento: Tratamiento;

  @CreateDateColumn()
  creado_en: Date;
}
