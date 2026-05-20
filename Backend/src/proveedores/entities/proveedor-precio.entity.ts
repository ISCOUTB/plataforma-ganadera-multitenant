import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Proveedor } from './proveedor.entity';

@Entity('proveedor_precios')
export class ProveedorPrecio {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ type: 'int' })
  fk_id_proveedor!: number;

  @Column({ type: 'varchar', length: 15 })
  fk_id_alimento!: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  precio!: number;

  @Column({ type: 'varchar', length: 50, nullable: true, default: null })
  unidad!: string | null;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  actualizado_en!: Date;

  @ManyToOne(() => Proveedor, (p) => p.precios, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'fk_id_proveedor' })
  proveedor!: Proveedor;

  @CreateDateColumn()
  creado_en!: Date;
}