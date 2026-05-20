import { IsString, IsOptional, IsNumber, IsDateString, IsIn, MaxLength, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateFinanzaDto {
  @ApiProperty({ example: 'FIN001', maxLength: 15 })
  @IsString()
  @MaxLength(15)
  pk_id_finanza: string;

  @ApiProperty({ example: 'ingreso', enum: ['ingreso', 'gasto'] })
  @IsIn(['ingreso', 'gasto'])
  tipo_movimiento: string;

  @ApiPropertyOptional({ example: 'Venta de 5 novillos', maxLength: 200 })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  concepto?: string;

  @ApiPropertyOptional({ example: 'venta_ganado', maxLength: 50 })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  categoria?: string;

  @ApiProperty({ example: 5000000, minimum: 0 })
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  monto: number;

  @ApiProperty({ example: '2024-06-15' })
  @IsDateString()
  fecha: string;

  @ApiPropertyOptional({ example: 'FAC-00123', maxLength: 100 })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  factura?: string;

  @ApiPropertyOptional({ example: 'transferencia', maxLength: 30 })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  metodo_pago?: string;

  @ApiPropertyOptional({ example: 'FIN001', description: 'ID de la finca asociada' })
  @IsOptional()
  @IsString()
  fincaId?: string;

  @ApiPropertyOptional({ example: 1, description: 'ID del animal asociado (para ventas)' })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  animalId?: number;
}
