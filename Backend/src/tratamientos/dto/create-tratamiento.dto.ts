import { IsString, IsOptional, IsNumber, IsDateString, IsEnum } from 'class-validator';
import { EstadoTratamiento } from '../entities/tratamiento.entity';

export class CreateTratamientoDto {
  @IsNumber()
  fk_id_bovino: number;

  @IsString()
  diagnostico: string;

  @IsDateString()
  fecha_inicio: string;

  @IsOptional()
  @IsDateString()
  fecha_fin_estimada?: string;

  @IsNumber()
  fk_id_veterinario: number;

  @IsOptional()
  @IsEnum(EstadoTratamiento)
  estado?: EstadoTratamiento;
}

export class CreateSeguimientoDto {
  @IsString()
  observacion: string;

  @IsOptional()
  @IsString()
  registrado_por?: string;
}
