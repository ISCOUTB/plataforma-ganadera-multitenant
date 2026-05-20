import { IsEnum, IsOptional, IsString, IsNumber, IsDateString } from 'class-validator';
import { TipoCita, EstadoCita, AlcanceCita } from '../entities/cita.entity';

export class CreateCitaDto {
  @IsEnum(TipoCita)
  tipo: TipoCita;

  @IsEnum(AlcanceCita)
  alcance: AlcanceCita;

  @IsDateString()
  fecha_hora: string;

  @IsNumber()
  fk_id_veterinario: number;

  @IsOptional()
  @IsNumber()
  fk_id_bovino?: number;

  @IsOptional()
  @IsString()
  fk_id_potrero?: string;

  @IsOptional()
  @IsString()
  notas?: string;

  @IsOptional()
  @IsNumber()
  recordatorio_dias?: number;
}
