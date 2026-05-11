import { Entity, Column, ManyToOne } from 'typeorm';
import { Finca } from '../../fincas/entities/finca.entity';
import { Potrero } from '../../potreros/entities/potrero.entity';
import { BaseEntity } from '../../common/entities/base.entity';

export enum EstadoAnimal {
  ACTIVO = 'activo',
  VENDIDO = 'vendido',
  MUERTO = 'muerto',
}

/**
 * Etapa productiva del bovino dentro del ciclo ganadero.
 *   - produccion   = vacas en edad productiva (hembras ≥ 2 años lactando)
 *   - crecimiento  = terneros / novillas en levante (< 2 años)
 *   - seca         = machos adultos o vacas no lactantes
 *   - sin_clasificar = valor por defecto para registros legacy sin migrar
 *
 * Usado por el BFF `GET /dashboard/summary` para la card "Demografía"
 * del Bento Box via `COUNT GROUP BY`.
 */
export enum EtapaProductiva {
  PRODUCCION = 'produccion',
  CRECIMIENTO = 'crecimiento',
  SECA = 'seca',
  ENGORDE = 'engorde',     
  REPRODUCTOR = 'reproductor',
  SIN_CLASIFICAR = 'sin_clasificar',
}

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

  // --- Etapa productiva ---
  // Alimenta la card "Demografía" del BFF. Auto-inferido en el service
  // al crear si el DTO no especifica uno. Los registros legacy se
  // migran en `AnimalesService.onModuleInit()`.
  @Column({
    type: 'enum',
    enum: EtapaProductiva,
    default: EtapaProductiva.SIN_CLASIFICAR,
  })
  etapa_productiva: EtapaProductiva;

  // --- Estado y venta ---
  @Column({ type: 'enum', enum: EstadoAnimal, default: EstadoAnimal.ACTIVO })
  estado: EstadoAnimal;

  @Column('decimal', { precision: 12, scale: 2, nullable: true })
  precio_venta: number;

  @Column({ length: 150, nullable: true })
  comprador: string;

  // Relaciones
  @ManyToOne(() => Finca, (finca) => finca.animales)
  finca: Finca;

  @ManyToOne(() => Potrero, (potrero) => potrero.animales, { nullable: true })
  potrero: Potrero;
}
