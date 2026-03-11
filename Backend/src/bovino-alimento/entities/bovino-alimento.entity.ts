import { Entity, PrimaryColumn, Column, ManyToOne } from 'typeorm';
import { Animal } from '../../animales/entities/animal.entity';
import { Alimento } from '../../alimentos/entities/alimento.entity';

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

  @ManyToOne(() => Animal)
  bovino: Animal;

  @ManyToOne(() => Alimento)
  alimento: Alimento;
}