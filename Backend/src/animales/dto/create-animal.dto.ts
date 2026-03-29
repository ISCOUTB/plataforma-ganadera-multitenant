import {
  IsString,
  IsDateString,
  IsNumber,
  IsEnum,
  IsOptional,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

// Género de bovino: m = macho, h = hembra, n = no definido
enum Genero {
  MACHO = 'm',
  HEMBRA = 'h',
  NO_DEFINIDO = 'n',
}

export class CreateAnimalDto {
  @ApiProperty({ example: 'BOV-2024-001', description: 'Número de identificación del bovino (arete, chip, etc.)' })
  @IsString()
  numero_identificacion: string;

  @ApiPropertyOptional({ example: 'arete_electronico', description: 'Método de identificación usado' })
  @IsOptional()
  @IsString()
  metodo_identificacion?: string;

  @ApiProperty({ example: '2022-03-15', description: 'Fecha de nacimiento en formato ISO 8601' })
  @IsDateString()
  fecha_nacimiento: string;

  @ApiPropertyOptional({ example: 24, description: 'Edad en meses' })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  edad_actual?: number;

  @ApiProperty({ example: 'm', enum: ['m', 'h', 'n'], description: 'm=macho, h=hembra, n=no definido' })
  @IsEnum(Genero)
  genero: string;

  @ApiProperty({ example: 450.5, minimum: 0, description: 'Peso en kilogramos' })
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  peso: number;

  @ApiPropertyOptional({ example: 1.35, minimum: 0, description: 'Altura en metros' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  altura?: number;

  @ApiProperty({ example: 'Brahman', description: 'Raza del bovino' })
  @IsString()
  raza: string;

  @ApiPropertyOptional({ example: 'compra', description: 'Origen del animal (nacimiento, compra, donación)' })
  @IsOptional()
  @IsString()
  origen?: string;

  @ApiPropertyOptional({ example: '2023-06-01', description: 'Fecha de ingreso a la finca' })
  @IsOptional()
  @IsDateString()
  fecha_ingreso?: string;

  @ApiPropertyOptional({ example: '2025-01-10', description: 'Fecha de salida de la finca (venta, muerte)' })
  @IsOptional()
  @IsDateString()
  fecha_salida?: string;

  @ApiPropertyOptional({ example: 'hijo de BOV-2020-003', description: 'Relación genealógica' })
  @IsOptional()
  @IsString()
  relacion_genealogica?: string;

  // fincaId es el PK de la Finca (string) a la que pertenece este animal.
  // tenant_id NO se acepta aquí — siempre se toma del JWT.
  @ApiPropertyOptional({ example: 'FINCA001', description: 'pk_id_finca — finca a la que pertenece' })
  @IsOptional()
  @IsString()
  fincaId?: string;

  @ApiPropertyOptional({ example: 'POT-001', description: 'pk_id_potrero — potrero actual del animal' })
  @IsOptional()
  @IsString()
  potreroId?: string;
}
