import { IsNumber, IsOptional, IsString, IsDateString, MaxLength } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateMovimientoDto {
  @ApiProperty({ example: 1, description: 'ID del animal a mover' })
  @IsNumber()
  @Type(() => Number)
  animalId: number;

  @ApiPropertyOptional({ example: 'POT001', description: 'Potrero de origen (null si ingreso nuevo)' })
  @IsOptional()
  @IsString()
  potreroOrigenId?: string;

  @ApiProperty({ example: 'POT002', description: 'Potrero de destino' })
  @IsString()
  potreroDestinoId: string;

  @ApiProperty({ example: '2024-06-15' })
  @IsDateString()
  fecha: string;

  @ApiPropertyOptional({ example: 'Rotación de pastoreo', maxLength: 200 })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  motivo?: string;
}
