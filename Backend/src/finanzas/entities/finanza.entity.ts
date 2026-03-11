import { Entity, Column, PrimaryColumn, CreateDateColumn } from 'typeorm';

@Entity('finanzas')
export class Finanza {
  @PrimaryColumn({ length: 15 })
  pk_id_finanza: string;

  @Column({ 
    type: 'enum', 
    enum: ['ingreso', 'gasto'],
  })
  tipo_movimiento: string;

  @Column({ length: 200, nullable: true })
  concepto: string;

  @Column({ length: 50, nullable: true })
  categoria: string;

  @Column('decimal')
  monto: number;

  @Column('date')
  fecha: Date;

  @Column({ length: 100, nullable: true })
  factura: string;

  @Column({ length: 30, nullable: true })
  metodo_pago: string;

  @CreateDateColumn()
  creado_en: Date;
}