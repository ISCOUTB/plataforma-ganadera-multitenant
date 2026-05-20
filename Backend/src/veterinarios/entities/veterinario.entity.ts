import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, DeleteDateColumn, OneToMany } from 'typeorm';

@Entity('veterinarios')
export class Veterinario {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 150 })
  nombre: string;

  @Column({ length: 100, nullable: true })
  especialidad: string;

  @Column({ length: 20, nullable: true })
  telefono: string;

  @Column({ length: 150, nullable: true })
  email: string;

  @Column({ type: 'text', nullable: true })
  notas: string;

  @Column({ nullable: true })
  tenant_id: string;

  @DeleteDateColumn()
  deleted_at: Date;

  @CreateDateColumn()
  creado_en: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
