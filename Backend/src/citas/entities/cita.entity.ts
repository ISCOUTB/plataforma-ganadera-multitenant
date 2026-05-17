import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, DeleteDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Veterinario } from '../../veterinarios/entities/veterinario.entity';

export enum TipoCita {
  REVISION_GENERAL = 'revision_general',
  VACUNACION = 'vacunacion',
  DESPARASITACION = 'desparasitacion',
  PARTO_ASISTIDO = 'parto_asistido',
  EMERGENCIA = 'emergencia',
  OTRO = 'otro',
}

export enum EstadoCita {
  PENDIENTE = 'pendiente',
  COMPLETADA = 'completada',
  CANCELADA = 'cancelada',
}

export enum AlcanceCita {
  ANIMAL = 'animal',
  POTRERO = 'potrero',
}

@Entity('citas')
export class Cita {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'enum', enum: TipoCita })
  tipo: TipoCita;

  @Column({ type: 'enum', enum: EstadoCita, default: EstadoCita.PENDIENTE })
  estado: EstadoCita;

  @Column({ type: 'enum', enum: AlcanceCita })
  alcance: AlcanceCita;

  @Column({ type: 'timestamp' })
  fecha_hora: Date;

  @Column({ nullable: true })
  fk_id_bovino: number;

  @Column({ length: 15, nullable: true })
  fk_id_potrero: string;

  @Column({ type: 'text', nullable: true })
  notas: string;

  @Column({ nullable: true })
  recordatorio_dias: number;

  @ManyToOne(() => Veterinario)
  @JoinColumn({ name: 'fk_id_veterinario' })
  veterinario: Veterinario;

  @Column({ nullable: true })
  fk_id_veterinario: number;

  @Column({ nullable: true })
  tenant_id: string;

  @DeleteDateColumn()
  deleted_at: Date;

  @CreateDateColumn()
  creado_en: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
