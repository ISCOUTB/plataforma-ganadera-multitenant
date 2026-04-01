import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { Animal } from '../../animales/entities/animal.entity';
import { Potrero } from '../../potreros/entities/potrero.entity';

@Entity('movimientos_animal')
export class MovimientoAnimal extends BaseEntity {
  @ManyToOne(() => Animal)
  @JoinColumn({ name: 'fk_id_bovino' })
  animal: Animal;

  @ManyToOne(() => Potrero, { nullable: true })
  @JoinColumn({ name: 'fk_potrero_origen' })
  potreroOrigen: Potrero;

  @ManyToOne(() => Potrero)
  @JoinColumn({ name: 'fk_potrero_destino' })
  potreroDestino: Potrero;

  @Column('date')
  fecha: Date;

  @Column({ length: 200, nullable: true })
  motivo: string;
}
