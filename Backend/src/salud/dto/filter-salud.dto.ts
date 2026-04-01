import { IsOptional, IsString, IsIn } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationDto } from '../../common/dto/pagination.dto';

const SORTABLE_COLUMNS = [
  'id', 'tipo_intervencion', 'fecha_aplicacion',
  'fecha_proxima_aplicacion', 'costo', 'created_at', 'updated_at',
] as const;

export class FilterSaludDto extends PaginationDto {
  @ApiPropertyOptional({
    example: 'fecha_aplicacion',
    enum: SORTABLE_COLUMNS,
    description: 'Campo por el cual ordenar',
  })
  @IsOptional()
  @IsIn(SORTABLE_COLUMNS)
  sortBy?: string;

  @ApiPropertyOptional({
    example: 'vacunacion',
    enum: ['vacunacion', 'vitaminas', 'desparasitacion', 'enfermedad'],
    description: 'Filtrar por tipo de intervención',
  })
  @IsOptional()
  @IsIn(['vacunacion', 'vitaminas', 'desparasitacion', 'enfermedad'])
  tipo_intervencion?: string;
}
