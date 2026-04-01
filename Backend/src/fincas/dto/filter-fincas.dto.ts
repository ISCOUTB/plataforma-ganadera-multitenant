import { IsOptional, IsString, IsIn } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationDto } from '../../common/dto/pagination.dto';

const SORTABLE_COLUMNS = [
  'pk_id_finca', 'nombre_finca', 'ubicacion', 'area_total',
  'fecha_registro', 'creado_en', 'updated_at',
] as const;

export class FilterFincasDto extends PaginationDto {
  @ApiPropertyOptional({
    example: 'creado_en',
    enum: SORTABLE_COLUMNS,
    description: 'Campo por el cual ordenar',
  })
  @IsOptional()
  @IsIn(SORTABLE_COLUMNS)
  sortBy?: string;

  @ApiPropertyOptional({ example: 'Hacienda El Paraíso', description: 'Filtrar por nombre de finca' })
  @IsOptional()
  @IsString()
  nombre_finca?: string;

  @ApiPropertyOptional({ example: 'Córdoba', description: 'Filtrar por ubicación' })
  @IsOptional()
  @IsString()
  ubicacion?: string;
}
