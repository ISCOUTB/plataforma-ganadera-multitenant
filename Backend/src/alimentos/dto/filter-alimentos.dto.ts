import { IsOptional, IsString, IsIn } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationDto } from '../../common/dto/pagination.dto';

const SORTABLE_COLUMNS = [
  'pk_id_alimento', 'tipo_alimento', 'cantidad_total',
  'costo', 'fecha_inicio', 'creado_en', 'updated_at',
] as const;

export class FilterAlimentosDto extends PaginationDto {
  @ApiPropertyOptional({
    example: 'tipo_alimento',
    enum: SORTABLE_COLUMNS,
    description: 'Campo por el cual ordenar',
  })
  @IsOptional()
  @IsIn(SORTABLE_COLUMNS)
  sortBy?: string;

  @ApiPropertyOptional({ example: 'Pasto', description: 'Filtrar por tipo de alimento' })
  @IsOptional()
  @IsString()
  tipo_alimento?: string;
}
