import { IsString, IsOptional, IsNumber, IsDateString, IsIn, MaxLength, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateSaludDto {
  @ApiProperty({ example: 'vacunacion', enum: ['vacunacion', 'vitaminas', 'desparasitacion', 'enfermedad'] })
  @IsIn(['vacunacion', 'vitaminas', 'desparasitacion', 'enfermedad'])
  tipo_intervencion: string;

  @ApiPropertyOptional({ example: 'Fiebre aftosa detectada', maxLength: 255 })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  descripcion_enfermedad?: string;

  @ApiPropertyOptional({ example: 'Ivermectina', maxLength: 100 })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  producto_aplicado?: string;

  @ApiPropertyOptional({ example: '5ml', maxLength: 50 })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  dosis?: string;

  @ApiPropertyOptional({ example: '2024-06-15' })
  @IsOptional()
  @IsDateString()
  fecha_aplicacion?: string;

  @ApiPropertyOptional({ example: '2024-12-15', description: 'Fecha de próxima aplicación' })
  @IsOptional()
  @IsDateString()
  fecha_proxima_aplicacion?: string;

  @ApiPropertyOptional({ example: 25000, minimum: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  costo?: number;

  @ApiPropertyOptional({ example: 1, description: 'ID del animal asociado' })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  animalId?: number;
}
