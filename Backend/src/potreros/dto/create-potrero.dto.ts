import {
  IsString,
  IsOptional,
  IsNumber,
  IsInt,
  IsDateString,
  MaxLength,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreatePotreroDto {
  @ApiProperty({
    example: 'POT001',
    maxLength: 15,
    description: 'Identificador único manual del potrero',
  })
  @IsString()
  @MaxLength(15)
  pk_id_potrero: string;

  @ApiProperty({ example: 'Potrero Norte', maxLength: 100 })
  @IsString()
  @MaxLength(100)
  nombre_potrero: string;

  @ApiPropertyOptional({
    example: 12.5,
    minimum: 0,
    description: 'Área en hectáreas',
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  area?: number;

  @ApiProperty({
    example: 50,
    minimum: 1,
    description: 'Capacidad máxima de animales',
  })
  @IsInt()
  @Min(1)
  @Type(() => Number)
  capacidad_animales: number;

  @ApiPropertyOptional({
    example: 'activo',
    maxLength: 30,
    description: 'Estado del potrero',
  })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  estado?: string;

  @ApiPropertyOptional({
    example: '2024-06-01',
    description: 'Fecha de última rotación',
  })
  @IsOptional()
  @IsDateString()
  fecha_rotacion?: string;

  @ApiPropertyOptional({
    example: '2024-09-01',
    description: 'Fecha de próxima rotación programada',
  })
  @IsOptional()
  @IsDateString()
  fecha_proxima_rotacion?: string;

  @ApiPropertyOptional({
    example: 'FINCA001',
    description: 'pk_id_finca de la finca asociada',
  })
  @IsOptional()
  @IsString()
  fincaId?: string;
}
