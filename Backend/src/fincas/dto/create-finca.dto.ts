import { IsString, IsOptional, IsNumber, IsDateString, MaxLength, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateFincaDto {
  // pk_id_finca es asignado manualmente (hasta 15 chars) — el cliente lo provee.
  // Ej: "FINCA001", "HACIENDA-3"
  @ApiProperty({ example: 'FINCA001', maxLength: 15, description: 'Identificador único manual de la finca' })
  @IsString()
  @MaxLength(15)
  pk_id_finca: string;

  @ApiProperty({ example: 'Hacienda El Paraíso', maxLength: 100 })
  @IsString()
  @MaxLength(100)
  nombre_finca: string;

  @ApiPropertyOptional({ example: 'Córdoba, Colombia', maxLength: 150 })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  ubicacion?: string;

  @ApiPropertyOptional({ example: 'Juan Pérez', maxLength: 100 })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  propietario?: string;

  @ApiPropertyOptional({ example: 250.5, minimum: 0, description: 'Área total en hectáreas' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  area_total?: number;

  @ApiPropertyOptional({ example: '2024-01-15', description: 'Fecha en formato ISO 8601' })
  @IsOptional()
  @IsDateString()
  fecha_registro?: string;

  // tenant_id NO se acepta aquí — siempre se toma del JWT (@Tenant()).
}
