import { IsNumber, IsOptional, IsString, IsDateString, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class VenderAnimalDto {
  @ApiProperty({ example: 2500000, minimum: 0, description: 'Precio de venta en moneda local' })
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  precio_venta: number;

  @ApiPropertyOptional({ example: 'Juan Pérez', description: 'Nombre del comprador' })
  @IsOptional()
  @IsString()
  comprador?: string;

  @ApiProperty({ example: '2025-03-15', description: 'Fecha de venta (ISO 8601)' })
  @IsDateString()
  fecha_venta: string;

  @ApiPropertyOptional({ example: 'FINCA001', description: 'ID de la finca para la finanza asociada' })
  @IsOptional()
  @IsString()
  fincaId?: string;
}
