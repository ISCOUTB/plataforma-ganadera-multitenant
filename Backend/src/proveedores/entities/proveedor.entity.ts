import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';

@Entity('proveedores')
export class Proveedor {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ length: 150 })
  nombre!: string;

  @Column({ type: 'varchar', length: 150, nullable: true, default: null })
  contacto!: string | null;

  @Column({ type: 'varchar', length: 20, nullable: true, default: null })
  telefono!: string | null;

  @Column({ type: 'varchar', length: 150, nullable: true, default: null })
  email!: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true, default: null })
  direccion!: string | null;

  @Column({ type: 'text', nullable: true, default: null })
  notas!: string | null;

  @Column({ type: 'varchar', nullable: true, default: null })
  tenant_id!: string | null;

  @Column({ type: 'timestamp', nullable: true, default: null })
  deleted_at!: Date | null;

  @OneToMany('ProveedorPrecio', 'proveedor')
  precios!: any[];

  @CreateDateColumn()
  creado_en!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updated_at!: Date;
}