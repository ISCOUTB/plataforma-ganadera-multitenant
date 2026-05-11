import { IsString, IsOptional, IsBoolean, IsNumber, IsDateString, MaxLength, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateReproduccionDto {
  @ApiProperty({ example: 'REP001', maxLength: 15 })
  @IsString()
  @MaxLength(15)
  pk_id_reproduccion: string;

  @ApiPropertyOptional({ example: 'BOV001', maxLength: 15, description: 'ID del padre' })
  @IsOptional()
  @IsString()
  @MaxLength(15)
  fk_id_padre?: string;

  @ApiPropertyOptional({ example: 'BOV002', maxLength: 15, description: 'ID de la madre' })
  @IsOptional()
  @IsString()
  @MaxLength(15)
  fk_id_madre?: string;

  @ApiPropertyOptional({ example: 'monta_natural', maxLength: 30 })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  metodo_reproduccion?: string;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  @Type(() => Boolean)
  en_celo?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  @Type(() => Boolean)
  preñada?: boolean;

  @ApiPropertyOptional({ example: 1, minimum: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  numero_crias?: number;

  @ApiPropertyOptional({ example: '2024-12-01', description: 'Fecha estimada de parto' })
  @IsOptional()
  @IsDateString()
  fecha_estimado_parto?: string;
}
