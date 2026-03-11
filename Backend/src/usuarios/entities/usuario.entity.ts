import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('usuarios')
export class Usuario {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;

  @Column()
  nombre: string;

  @Column({ nullable: true })
  telefono: string;

  @Column({ default: 'admin' })
  rol: string;

  @Column()
  tenant_id: string; // Para multitenant

  @CreateDateColumn()
  creado_en: Date;
}