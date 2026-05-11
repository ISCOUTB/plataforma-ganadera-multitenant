import { IsOptional, IsString, IsIn } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationDto } from '../../common/dto/pagination.dto';

const SORTABLE_COLUMNS = [
  'pk_id_finanza', 'tipo_movimiento', 'categoria',
  'monto', 'fecha', 'creado_en', 'updated_at',
] as const;

export class FilterFinanzasDto extends PaginationDto {
  @ApiPropertyOptional({
    example: 'fecha',
    enum: SORTABLE_COLUMNS,
    description: 'Campo por el cual ordenar',
  })
  @IsOptional()
  @IsIn(SORTABLE_COLUMNS)
  sortBy?: string;

  @ApiPropertyOptional({
    example: 'ingreso',
    enum: ['ingreso', 'gasto'],
    description: 'Filtrar por tipo de movimiento',
  })
  @IsOptional()
  @IsIn(['ingreso', 'gasto'])
  tipo_movimiento?: string;

  @ApiPropertyOptional({ example: 'venta_ganado', description: 'Filtrar por categoría' })
  @IsOptional()
  @IsString()
  categoria?: string;

  @ApiPropertyOptional({
    example: 'F1',
    description:
      'Filtrar por finca (id de finca). Cuando se omite, devuelve movimientos de todas las fincas del tenant.',
  })
  @IsOptional()
  @IsString()
  fincaId?: string;
}
