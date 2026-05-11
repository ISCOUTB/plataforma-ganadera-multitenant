import { Entity, PrimaryColumn, Column, ManyToOne } from 'typeorm';
import { Animal } from '../../animales/entities/animal.entity';
import { Alimento } from '../../alimentos/entities/alimento.entity';

// BovinoAlimento — tabla de unión N:N entre Animal y Alimento.
// PK compuesta: fk_id_bovino (number) + fk_id_alimento (string).
// No extiende BaseEntity (composite PK incompatible con id: number auto-gen).
// Solo se agrega tenant_id para filtrado — deleted_at/auditing no aplican
// a tablas de unión (se gestionan a través de las entidades padre).
@Entity('bovino_alimento')
export class BovinoAlimento {
  @PrimaryColumn()
  fk_id_bovino: number;

  @PrimaryColumn({ length: 15 })
  fk_id_alimento: string;

  @Column('decimal')
  cantidad: number;

  @Column('date')
  fecha: Date;

  // tenant_id: propagado desde Animal para permitir queries tenant-safe
  // sin necesidad de join con bovinos en cada consulta.
  @Column({ type: 'varchar', nullable: true })
  tenant_id: string | null;

  @ManyToOne(() => Animal)
  bovino: Animal;

  @ManyToOne(() => Alimento)
  alimento: Alimento;
}
