import { IsString, IsOptional, IsNumber, IsDateString, MaxLength, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateAlimentoDto {
  @ApiProperty({ example: 'ALI001', maxLength: 15 })
  @IsString()
  @MaxLength(15)
  pk_id_alimento: string;

  @ApiProperty({ example: 'Concentrado bovino', maxLength: 100 })
  @IsString()
  @MaxLength(100)
  tipo_alimento: string;

  @ApiPropertyOptional({ example: 500, minimum: 0, description: 'Cantidad total en kg' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  cantidad_total?: number;

  @ApiPropertyOptional({ example: 'diaria', maxLength: 50 })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  frecuencia?: string;

  @ApiPropertyOptional({ example: '2024-01-01' })
  @IsOptional()
  @IsDateString()
  fecha_inicio?: string;

  @ApiPropertyOptional({ example: '2024-06-01' })
  @IsOptional()
  @IsDateString()
  fecha_fin_estimada?: string;

  @ApiPropertyOptional({ example: 150000, minimum: 0, description: 'Costo en moneda local' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  costo?: number;
}
